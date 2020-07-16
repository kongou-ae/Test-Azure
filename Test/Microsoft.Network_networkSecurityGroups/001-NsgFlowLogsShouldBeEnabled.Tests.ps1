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
    
        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "bastion" }){
            Param($Name,$flowLogStatus)
            $flowLogStatus | Should -BeTrue
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "bastion2" }){
            Param($Name,$flowLogStatus)
            $flowLogStatus | Should -BeFalse
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "fg-hcduddgb4lp24-NSG" }){
            Param($Name,$flowLogStatus)
            $flowLogStatus | Should -BeTrue
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "ml-wu2c09083361eabe" }){
            Param($Name,$flowLogStatus)
            $flowLogStatus | Should -BeFalse
        }
    }
}