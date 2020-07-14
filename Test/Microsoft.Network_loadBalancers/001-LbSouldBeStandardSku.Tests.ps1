$ErrorActionPreference = "stop"

Describe "Microsoft.Network/loadBalancers" {

    $lbs = $global:lbs | ConvertFrom-Json -Depth 100
    $TestCases = New-Object System.Collections.ArrayList

    Context "LB should be standard SKU" {

        $lbs | ForEach-Object {
            $tmp = @{
                "Name" = $_.Name
                "sku" = $_.Sku.Name
            }
            $TestCases.Add($tmp) | Out-Null
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "stdlb" }){
            Param($Name,$sku)
            $sku | Should -Be "Standard"
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "basiclb" }){
            Param($Name,$sku)
            $sku | Should -Not -Be "Standard"
        }
    }
}