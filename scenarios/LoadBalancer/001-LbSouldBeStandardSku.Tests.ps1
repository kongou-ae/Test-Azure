$ErrorActionPreference = "stop"

Describe "LoadBalancer" {

    $lbs = Get-AzLoadBalancer

    Context "LB should be standard SKU" {

        $lbs | ForEach-Object {
            $lb = $_

            it "$($lb.Name)" {
                $lb.Sku.Name | Should -Be "Standard"
            }                
        }
    }
}