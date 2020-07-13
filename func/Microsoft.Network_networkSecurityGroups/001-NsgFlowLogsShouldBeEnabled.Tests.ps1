$ErrorActionPreference = "stop"

Describe "Microsoft.Network/networkSecurityGroups" {

    $nsgFlowLogsStatus = $global:nsgFlowLogsStatus | ConvertFrom-Json -Depth 100
    $nsgs = $global:nsgs | ConvertFrom-Json -Depth 100
    $TestCases = New-Object System.Collections.ArrayList

    $nsgs | ForEach-Object {
        $nsg = $_
        $nsg.id -match "Microsoft.Network/networkSecurityGroups/(.*)" | Out-Null

        if ($nsgFlowLogsStatus | Where-Object { $_.TargetResourceId -eq $nsg.id } ){
            $tmp = @{
                "Name" = $Matches[1]
                "flowLogStatus" = $true
            }
        } else {
            $tmp = @{
                "Name" = $Matches[1]
                "flowLogStatus" = $false
            }
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "NSG Flow Logs should be enabled" {
    
        it "<Name>" -TestCases $TestCases{
            Param($Name,$flowLogStatus)
            $flowLogStatus | Should -BeTrue
        }
    }
}