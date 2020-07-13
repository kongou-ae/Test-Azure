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

$global:vms = Get-AzVm | Convertto-json -Depth 100
$global:disks = Get-AzDisk | Convertto-json -Depth 100
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


$result = Invoke-Pester -path "$PSScriptRoot\func\" -PassThru -Show None

$TestResult = $result.Tests | Select-Object `
    @{Label="Describe"; Expression={$_.Path[0]}}, `
    @{Label="Context"; Expression={$_.Path[1]}}, `
    ExpandedName, Result

# ToDo: ファイルに書き出す処理を足す
#$result | ConvertTo-Json 

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
