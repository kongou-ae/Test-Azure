$ErrorActionPreference = "stop"

Describe "NetworkSecurityGroup" {

    $nsgs = Get-AzNetworkSecurityGroup

    Context "NSG Should has all deny rule in the last row" {
        $nsgs | ForEach-Object {
            $nsg = $_

            $inboundFlag = $false
            $outboundFlag = $false
            $validation = $false

            $lastInboundRules = $nsg.SecurityRules | where-object { $_.Direction -eq "Inbound" } | Select-object -Last 1
            $lastOutboundRules = $nsg.SecurityRules | where-object { $_.Direction -eq "Outbound" } | Select-object -Last 1

            if (
                $lastInboundRules.Protocol -eq "*" -and `
                $lastInboundRules.DestinationPortRange -eq "*" -and `
                $lastInboundRules.SourceAddressPrefix -eq "*" -and `
                $lastInboundRules.DestinationAddressPrefix -eq "*" -and `
                $lastOutboundRules.Access -eq "Deny"
            ){
                $inboundFlag = $true
            }

            if (
                $lastOutboundRules.Protocol -eq "*" -and `
                $lastOutboundRules.DestinationPortRange -eq "*" -and `
                $lastOutboundRules.SourceAddressPrefix -eq "*" -and `
                $lastOutboundRules.DestinationAddressPrefix -eq "*" -and `
                $lastOutboundRules.Access -eq "Deny"
            ){
                $outboundFlag = $true
            }

            if ( $inboundFlag -eq $true -and $outboundFlag -eq $true ){
                $validation = $true
            }

            it "$($nsg.Name)" {
                $validation | Should -Be $true
            }
        }
    }
}