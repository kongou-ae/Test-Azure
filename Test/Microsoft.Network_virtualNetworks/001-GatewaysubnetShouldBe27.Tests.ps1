$ErrorActionPreference = "stop"

Describe "Microsoft.Network/virtualNetworks" {

    $vnets = $global:vnets | ConvertFrom-Json -Depth 100 
    $TestCases = New-Object System.Collections.ArrayList

    Context "Gateway subnet should be /27" {

        $vnets | ForEach-Object {
            $vnet = $_
            $gatewaySubnet = $vnet.Subnets | Where-Object { $_.Name -like "GatewaySubnet"}
            if ( $null -ne $gatewaySubnet ){
                $tmp = @{
                    "Name" = $_.Name
                    "prefix" = $gatewaySubnet.AddressPrefix -join ""
                }
                $TestCases.Add($tmp) | Out-Null
            }
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "fgnew" }){
            Param($Name,$prefix)
            $prefix | Should -BeLike "*/27"
        } 
    }
}