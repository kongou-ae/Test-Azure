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

function Convert-IndivisualResult {
    param (
        $result
    )
    return $result.Tests | Select-Object `
    @{Label="Describe"; Expression={$_.Path[0]}}, `
    @{Label="Context"; Expression={$_.Path[1]}}, `
    ExpandedName, Result
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

$TestResult = New-Object System.Collections.ArrayList


##############################################################
# Microsoft.Compute
##############################################################

$global:vms = Get-AzVm | Convertto-json -Depth 100

if ($null -ne $global:vms){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Compute\001-BootdiagShouldBeEnabled.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
    
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Compute\002-OsDiskShouldBeManagedDisk.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}

##############################################################
# Microsoft.Compute/Disks
##############################################################

$global:disks = Get-AzDisk | Convertto-json -Depth 100

if ($null -ne $global:disks){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Compute_Disks\001-DiskShoudBeGreaterThanStandardSSD.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}

##############################################################
# Microsoft.Network/networkSecurityGroups
##############################################################

$global:nsgs = Get-AzNetworkSecurityGroup | Convertto-json -Depth 100

$networkWatchers =  Get-AzNetworkWatcher
$global:nsgFlowLogsStatus = New-Object System.Collections.ArrayList
$networkWatchers | ForEach-Object {
    $nsgFlowLog = Get-AzNetworkWatcherFlowLog -NetworkWatcher $_

    $nsgFlowLog | ForEach-Object {
        $global:nsgFlowLogsStatus.Add($_) | Out-Null
    }
}
$global:nsgFlowLogsStatus = $global:nsgFlowLogsStatus | ConvertTo-Json -Depth 100

if ($null -ne $global:nsgs){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_networkSecurityGroups\001-NsgFlowLogsShouldBeEnabled.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }

    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_networkSecurityGroups\002-NsgShouldHasAllDenyRuleInTheLastRow.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}

##############################################################
# Microsoft.Network/loadBalancers
##############################################################

$global:lbs = Get-AzLoadBalancer | Convertto-json -Depth 100
if ($null -ne $global:lbs){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_loadBalancers\001-LbSouldBeStandardSku.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }

    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_loadBalancers\002-StandardLbShouldBeZoneRedundant.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}

##############################################################
# Microsoft.Network/publicipaddresses
##############################################################

$global:pips = Get-AzPublicIpAddress | ConvertTo-Json -Depth 100

if ($null -ne $global:pips){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_publicipaddresses\001-PipShoudBeUsed.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}


##############################################################
# Microsoft.Network/virtualNetworkGateways
##############################################################

$global:vpnGateways = Get-AzResourceGroup | Get-AzVirtualNetworkGateway | ConvertTo-json -Depth 100
if ($null -ne $global:vpnGateways){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_virtualNetworkGateways\001-VpnGwShouldBeGreaterThanBasic.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}

##############################################################
# Microsoft.Network/virtualNetworks
##############################################################

$global:vnets = Get-AzVirtualNetwork | ConvertTo-json -Depth 100
if ($null -ne $global:vnets){
    $result = Invoke-Pester -PassThru -Show None -path "func\Microsoft.Network_virtualNetworks\001-GatewaysubnetShouldBe27.Tests.ps1"
    (Convert-IndivisualResult $result) | ForEach-Object {
        $TestResult.Add($_) | Out-Null
    }
}


# ToDo: ファイルに書き出す処理を足す
#$TestResult | ConvertTo-Json -Depth 100 | out-file "test-result.json"

if ($null -ne $TestResult){
    if( $json -eq $true ){
        $TestResult | ConvertTo-Json 
    } else {
        # カテゴリを抽出する
        $describes = ($TestResult | Select-Object Describe | Sort-Object -Property Describe -Unique).Describe
    
        # カテゴリごとに処理をループ
        $describes | ForEach-Object {
            $describe = $_
            Write-Output "-----------------------------------------------------"
            Write-Output "$describe"
            Write-Output "-----------------------------------------------------"
    
            # カテゴリ内のテスト項目を抽出
            $contexts = ($TestResult | Where-Object { $_.Describe -eq $describe } | Select-Object Context | Sort-Object -Property Context -Unique).Context
    
            # テスト項目ごとに処理をループ
            $contexts | ForEach-Object {
                $context = $_ 
                Write-Output "$context"
    
                # 全件からカテゴリとテスト項目に該当するものを抽出してループ
                $TestResult | Where-Object { $_.Describe -eq $describe -and $_.Context -eq $context } | ForEach-Object {
                    $a = $_.Result
                    $b = $_.ExpandedName
                    switch ($a) {
                        "Passed" {
                            Out-Log "  $($a) $($b)" "Green"
                        }
                        "Failed" {
                            Out-Log "  $($a) $($b)" "Red"
                        }
                    }
                }
            }
        }
    }
    
}