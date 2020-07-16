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

        it "<Name>" -TestCases $TestCases{
            Param($Name,$sku)
            $sku | Should -Not -Be "Basic"
        }      
    }
}