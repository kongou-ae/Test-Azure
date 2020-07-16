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

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "stdlb" }){
            Param($Name,$Zones)
            $Zones | Should -Be $null
        }           
        
        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "zonepinnedstdlb" }){
            Param($Name,$Zones)
            $Zones | Should -Not -Be $null
        }     
    }
}