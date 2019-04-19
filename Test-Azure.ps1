$ErrorActionPreference = "stop"

function Write-ColorOutput {
    param (
        $msg,
        $color
    )

    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $color
    Write-Output $msg
    $host.UI.RawUI.ForegroundColor = $fc
}

function showResult {
    param (
        $result,
        $context
    )

    Write-ColorOutput "  $context" "Green"
    $result.TestResult | Where-Object { $_.Context -eq "$context" } | ForEach-Object {
        if ($_.Result -eq "Passed" ){ Write-ColorOutput "    PASS $($_.Name)" "Green" } 
        if ($_.Result -eq "Failed" ){ Write-ColorOutput "    FAIL $($_.Name)" "Red" }
    }
}

Write-ColorOutput "Test Backup" "Green"
$result = Invoke-Pester .\scenarios\backup.ps1 -PassThru -Show None 
showResult $result "Enable VM backup"
showResult $result "Latest backup is within 24 hours"

Write-ColorOutput "Test Network" "Green"
$result = Invoke-Pester .\scenarios\network.ps1  -PassThru -Show None
showResult $result "Enable NSG Flow Logs"

