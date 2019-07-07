param (
    [switch]$network,
    [switch]$backup,
    [switch]$disk,
    [switch]$compute,
    [switch]$PassThru,
    [switch]$export
)

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
        if ($_.Result -eq "Skipped" ){ Write-ColorOutput "    SKIP $($_.Name)" "Yellow" }
    }
}

$resultList = New-Object System.Collections.ArrayList

if ( `
    $network.IsPresent -eq $false -and `
    $disk.IsPresent -eq $false -and `
    $backup.IsPresent -eq $false -and `
    $compute.IsPresent -eq $false
) {
    $network = $true
    $disk = $true
    $backup = $true
    $compute = $true
}

if ( $backup ){
    Write-ColorOutput "Test Backup" "Green"
    $result = Invoke-Pester .\scenarios\backup.ps1 -PassThru -Show None
    $result.TestResult | ForEach-Object {
        $resultList.Add($_) | Out-Null
    }
    showResult $result "VM backup should be enabled"
    showResult $result "Latest backup should be within 24 hours"
    showResult $result "Backup alert for VM backup should be configured"
}

if ( $network ){
    Write-ColorOutput "Test Network" "Green"
    $result = Invoke-Pester .\scenarios\network.ps1 -PassThru -Show None
    $result.TestResult | ForEach-Object {
        $resultList.Add($_) | Out-Null
    }
    showResult $result "NSG Flow Logs should be enabled"
    showResult $result "Nic should be used"
    showResult $result "Public ip address should be used"
    showResult $result "Runninng NIC should be protected by NSG"
    showResult $result "VPN Gateway should be more than basic"
}

if ( $disk ){
    Write-ColorOutput "Test Disk" "Green"
    $result = Invoke-Pester .\scenarios\disk.ps1 -PassThru -Show None
    $result.TestResult | ForEach-Object {
        $resultList.Add($_) | Out-Null
    }
    showResult $result "Disk should be used"
    showResult $result "Disk should be more than Standard HDD"    
}

if ( $compute ){
    Write-ColorOutput "Test compute" "Green"
    $result = Invoke-Pester .\scenarios\compute.ps1 -PassThru -Show None
    $result.TestResult | ForEach-Object {
        $resultList.Add($_) | Out-Null
    }
    showResult $result "Boot diag should be enabled"
    showResult $result "OS Disk Should be managed disk"
}

if ( $export ) {
    $FileName = "Test-Azure_$(Get-Date -Format yyyyMMdd-hhmmss).html"
    $resultList | Select-Object Describe, Context, Name, Result | ConvertTo-Json -Depth 100 | Out-File $FileName -Encoding utf8    
}

$total = $resultList.Count
$pass = ($resultList | Where-Object {$_.Result -eq "Passed"}).Count
$fail = ($resultList | Where-Object {$_.Result -eq "Failed"}).Count
$skip = ($resultList | Where-Object {$_.Result -eq "Skipped"}).Count
Write-Output "Total:$total, Passed:$pass, Failed:$fail, Skipped:$skip"

if ( $PassThru ){
    return $resultList
}