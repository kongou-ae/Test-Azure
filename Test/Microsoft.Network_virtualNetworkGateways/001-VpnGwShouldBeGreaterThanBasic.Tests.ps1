$ErrorActionPreference = "stop"

Describe "Microsoft.Network/virtualNetworkGateways" {

    $vpnGateways = $global:vpnGateways | ConvertFrom-Json -Depth 100 | Where-Object { $_.GatewayType -eq "Vpn"}
    $TestCases = New-Object System.Collections.ArrayList

    Context "VPN Gateway should be greater than VpnGw1" {

        $vpnGateways | ForEach-Object {
            $tmp = @{
                "Name" = $_.Name
                "sku" = $_.Sku.Tier
            }
            $TestCases.Add($tmp) | Out-Null
        }

        Write-host ( $TestCases | ConvertTo-Json )

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "basicvpngw" }){
            Param($Name,$sku)
            $sku | Should -Be "Basic"
        } 

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "zonegw" }){
            Param($Name,$sku)
            $sku | Should -Not -Be "Basic"
        } 
    }
}