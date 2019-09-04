$ErrorActionPreference = "stop"

Describe "VpnGateway" {

    $vpngw = Get-AzResource -ResourceType "Microsoft.Network/virtualNetworkGateways" -ExpandProperties

    Context "Diagnostics settings of VPN gateway should be enabled" {
        $vpngw | ForEach-Object {
            $vpngw = $_

            $diagConfig = Get-AzDiagnosticSetting -ResourceId $vpngw.ResourceId -WarningAction SilentlyContinue
            it "$($vpngw.Name)" {
                $diagConfig.Id | Should -Be $true
            }
        }
    }
}