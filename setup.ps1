param([Boolean]$silent=$false)

# elevate machine-level setup
$start_path = $pwd.path

Write-Host " * Running machine-level setup..."
$process = Start-Process powershell -Wait -PassThru -Verb runas -ArgumentList "-File $start_path/machine_level_setup.ps1"

Write-Host $process.ExitCode
If ($process.ExitCode -ne 0) {
    Write-Warning 'Situation is suboptimal. Machine-level setup failed with error code: $($process.ExitCode)'
    break
}

Write-Host " * Running user-level setup..."
./user_level_setup.ps1