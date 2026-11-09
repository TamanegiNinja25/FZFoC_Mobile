"""Strip unused animations from a .glb and repack its binary buffer.

    python tools/glb_strip.py in.glb out.glb Idle Running_A Hit_A ...

Keeps the named animations (others are dropped with every accessor and
buffer view only they used), leaving meshes, skins and materials untouched.
Used to trim the KayKit characters (76–95 animations each) to the ~15 the
game plays, cutting each file from ~4 MB to under 1 MB.
"""
import json, struct, sys


def read_glb(path):
    data = open(path, "rb").read()
    magic, version, length = struct.unpack_from("<III", data, 0)
    assert magic == 0x46546C67, "not a glb"
    offset = 12
    doc, binary = None, b""
    while offset < length:
        chunk_len, chunk_type = struct.unpack_from("<II", data, offset)
        chunk = data[offset + 8: offset + 8 + chunk_len]
        if chunk_type == 0x4E4F534A:
            doc = json.loads(chunk)
        elif chunk_type == 0x004E4942:
            binary = chunk
        offset += 8 + chunk_len
    return doc, binary


def write_glb(path, doc, binary):
    js = json.dumps(doc, separators=(",", ":")).encode()
    js += b" " * ((4 - len(js) % 4) % 4)
    binary += b"\0" * ((4 - len(binary) % 4) % 4)
    total = 12 + 8 + len(js) + 8 + len(binary)
    with open(path, "wb") as f:
        f.write(struct.pack("<III", 0x46546C67, 2, total))
        f.write(struct.pack("<II", len(js), 0x4E4F534A) + js)
        f.write(struct.pack("<II", len(binary), 0x004E4942) + binary)


def strip(src, dst, keep):
    doc, binary = read_glb(src)
    doc["animations"] = [a for a in doc.get("animations", []) if a["name"] in keep]
    # Accessors still referenced by anything other than dropped animations.
    used = set()
    def mark(i):
        if i is not None:
            used.add(i)
    for mesh in doc.get("meshes", []):
        for prim in mesh["primitives"]:
            mark(prim.get("indices"))
            for v in prim["attributes"].values():
                mark(v)
            for target in prim.get("targets", []):
                for v in target.values():
                    mark(v)
    for skin in doc.get("skins", []):
        mark(skin.get("inverseBindMatrices"))
    for anim in doc["animations"]:
        for sampler in anim["samplers"]:
            mark(sampler["input"])
            mark(sampler["output"])
    accessor_map = {}
    accessors = []
    for i, acc in enumerate(doc["accessors"]):
        if i in used:
            accessor_map[i] = len(accessors)
            accessors.append(acc)
    used_views = sorted({acc["bufferView"] for acc in accessors if "bufferView" in acc} |
                        {img["bufferView"] for img in doc.get("images", []) if "bufferView" in img})
    view_map = {}
    views = []
    new_binary = bytearray()
    for old in used_views:
        view = dict(doc["bufferViews"][old])
        start = view.get("byteOffset", 0)
        chunk = binary[start: start + view["byteLength"]]
        new_binary += b"\0" * ((4 - len(new_binary) % 4) % 4)
        view["byteOffset"] = len(new_binary)
        view["buffer"] = 0
        new_binary += chunk
        view_map[old] = len(views)
        views.append(view)
    for acc in accessors:
        if "bufferView" in acc:
            acc["bufferView"] = view_map[acc["bufferView"]]
    for img in doc.get("images", []):
        if "bufferView" in img:
            img["bufferView"] = view_map[img["bufferView"]]
    remap = lambda i: accessor_map[i]
    for mesh in doc.get("meshes", []):
        for prim in mesh["primitives"]:
            if "indices" in prim:
                prim["indices"] = remap(prim["indices"])
            prim["attributes"] = {k: remap(v) for k, v in prim["attributes"].items()}
            if "targets" in prim:
                prim["targets"] = [{k: remap(v) for k, v in t.items()} for t in prim["targets"]]
    for skin in doc.get("skins", []):
        if "inverseBindMatrices" in skin:
            skin["inverseBindMatrices"] = remap(skin["inverseBindMatrices"])
    for anim in doc["animations"]:
        for sampler in anim["samplers"]:
            sampler["input"] = remap(sampler["input"])
            sampler["output"] = remap(sampler["output"])
    doc["accessors"] = accessors
    doc["bufferViews"] = views
    doc["buffers"] = [{"byteLength": len(new_binary)}]
    write_glb(dst, doc, bytes(new_binary))
    return [a["name"] for a in doc["animations"]]


if __name__ == "__main__":
    kept = strip(sys.argv[1], sys.argv[2], set(sys.argv[3:]))
    print(sys.argv[2], "kept", len(kept), "animations")
