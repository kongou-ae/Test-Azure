$ErrorActionPreference = "stop"

Describe "VpnGateway" {

    $vpngw = Get-AzResource -ResourceType "Microsoft.Network/virtualNetworkGateways" -ExpandProperties

    Context "VPN Gateway should be greater than basic" {
        $vpngw | ForEach-Object {
            $vpngw = $_

            it "$($vpngw.Name)" {
                $vpngw.Properties.sku.tier | Should -Not -Be "Basic"
            }
        }
    }
}