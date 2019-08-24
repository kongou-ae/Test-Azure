$ErrorActionPreference = "stop"

Describe "LoadBalancer" {

    $lbs = Get-AzLoadBalancer
    $lbs = $lbs | where-object { $_.Sku.Name -eq "Standard" }

    Context "Standard LB should be zone redundant" {

        $lbs | ForEach-Object {
            $lb = $_

            it "$($lb.Name)" {
                $lb.FrontendIpConfigurations[0].Zones | Should -Be $null
            }                
        }
    }
}