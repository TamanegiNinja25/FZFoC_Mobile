# Runs the two-process local multiplayer test on 127.0.0.1 (no firewall prompt).
param([string]$Godot = "Godot_v4.7.2-stable_win64_console.exe", [string]$Project = (Join-Path $PSScriptRoot ".."))
$common = @("--headless", "--path", "`"$Project`"", "-s", "res://tests/net_test.gd", "--", "--loopback")
$hostProc = Start-Process -FilePath $Godot -ArgumentList ($common + "--role=host") -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\net_host.txt" -RedirectStandardError "$env:TEMP\net_host_err.txt"
Start-Sleep -Seconds 2
$clientProc = Start-Process -FilePath $Godot -ArgumentList ($common + "--role=client") -NoNewWindow -PassThru -RedirectStandardOutput "$env:TEMP\net_client.txt" -RedirectStandardError "$env:TEMP\net_client_err.txt"
foreach ($p in @($clientProc, $hostProc)) { if (-not $p.WaitForExit(70000)) { $p.Kill() } }
Get-Content "$env:TEMP\net_host.txt", "$env:TEMP\net_host_err.txt", "$env:TEMP\net_client.txt", "$env:TEMP\net_client_err.txt" |
	Where-Object { $_ -match '^ok|FAIL|PASSED|FAILED|SCRIPT ERROR|ERROR' }
