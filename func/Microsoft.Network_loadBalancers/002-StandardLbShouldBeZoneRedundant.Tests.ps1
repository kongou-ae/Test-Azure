$ErrorActionPreference = "stop"

Describe "Microsoft.Network/loadBalancers" {

    $lbs = $global:lbs | ConvertFrom-Json -Depth 100
    $lbs = $lbs | where-object { $_.Sku.Name -eq "Standard" }
    $TestCases = New-Object System.Collections.ArrayList

    Context "Standard LB should be zone redundant" {

        $lbs | ForEach-Object {
            $tmp = @{
                "Name" = $_.Name
                "Zones" = $_.FrontendIpConfigurations[0].Zones
            }
            $TestCases.Add($tmp) | Out-Null
        }

        it "<Name>" -TestCases $TestCases{
            Param($Name,$Zones)
            $Zones | Should -Be $null
        }                
    }
}