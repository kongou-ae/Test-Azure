param (
    [switch]$network,
    [switch]$backup,
    [switch]$disk,
    [switch]$compute,
    [switch]$json,
    [switch]$export
)

Function Out-Log
{
    param(
    [string]$message,
    [string]$Color = 'White'
    )

    Write-Host "$message" -ForegroundColor $Color
}

$ErrorActionPreference = "stop"

$usedModules = @(
    "Az.Network","Az.Websites","Az.Compute","Az.RecoveryServices"
)

$installedModules = Get-module -ListAvailable
$importedModules = Get-module

$usedModules | ForEach-Object {
    Out-Log "Checking the status of $_"
    $testModule = $_

    if (($installedModules | Where-Object {$_.Name -eq $testModule}) -eq $null){
        Write-Output "Install-Module $testModule -scope local"
        Install-Module $testModule -scope currentuser -force
    }    

    if (($importedModules | Where-Object {$_.Name -eq $testModule}) -eq $null){
        Write-Output "Import-Module $testModule -scope local"
        Import-Module $testModule -scope local -force
    }
}

#Install-Module -Name Pester -MinimumVersion 5.0.2 -Force -AllowClobber -Scope CurrentUser
#Import-Module -Name Pester -MinimumVersion 5.0.2 -Scope Local -Force

# Execute Test-Azure with test json files
$global:vms = get-content "Test\Microsoft.Compute\Microsot.Compute.Tests.json"
$global:disks = get-content "Test\Microsoft.Compute_Disks\Microsoft.Compute_Disks.json"
$global:nsgs = get-content "Test\Microsoft.Network_networkSecurityGroups\Microsoft.Network_networkSecurityGroups.json"
$global:nsgFlowLogsStatus = Get-Content "Test\Microsoft.Network_networkSecurityGroups\Microsoft.Network_networkWatchersStatus.json"

$global:lbs = Get-Content "Test\Microsoft.Network_loadBalancers\Microsoft.Network_loadBalancers.json"

$global:pips = Get-Content "Test\Microsoft.Network_publicipaddresses\Microsoft.Network_publicipaddresses.json"

$global:vpnGateways = Get-Content "Test\Microsoft.Network_virtualNetworkGateways\Microsoft.Network_virtualNetworkGateways.json"

$global:result = Invoke-Pester -path "func\" -PassThru -Show None

# Execute the result of Test-Azure 
Invoke-Pester -path "Test\" -show Default