$ErrorActionPreference = "stop"

Describe "Microsoft.Network/networkSecurityGroups" {

    $nsgs = $global:nsgs | ConvertFrom-Json -Depth 100
    $TestCases = New-Object System.Collections.ArrayList

    $nsgs | ForEach-Object {
        $nsg = $_

        $inboundFlag = $false
        $outboundFlag = $false
        $validation = $false

        $lastInboundRules = $nsg.SecurityRules | where-object { $_.Direction -eq "Inbound" } | Sort-Object Priority | Select-object -Last 1
        $lastOutboundRules = $nsg.SecurityRules | where-object { $_.Direction -eq "Outbound" } | Sort-Object Priority | Select-object -Last 1

        if (
            $lastInboundRules.Protocol -join "," -eq "*" -and `
            $lastInboundRules.DestinationPortRange -join ","  -eq "*" -and `
            $lastInboundRules.SourceAddressPrefix -join ","  -eq "*" -and `
            $lastInboundRules.DestinationAddressPrefix -join ","  -eq "*" -and `
            $lastOutboundRules.Access -eq "Deny"
        ){
            $inboundFlag = $true
        }

        if (
            $lastOutboundRules.Protocol -join ","  -eq "*" -and `
            $lastOutboundRules.DestinationPortRange -join ","  -eq "*" -and `
            $lastOutboundRules.SourceAddressPrefix -join ","  -eq "*" -and `
            $lastOutboundRules.DestinationAddressPrefix -join ","  -eq "*" -and `
            $lastOutboundRules.Access -eq "Deny"
        ){
            $outboundFlag = $true
        }

        if ( $inboundFlag -eq $true -and $outboundFlag -eq $true ){
            $validation = $true
        }

        $tmp = @{
            "Name" = $_.Name
            "Validation" = $validation
        }
        $TestCases.Add($tmp) | Out-Null

    }

    Context "NSG Should have an all deny rule in the last row" {

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "bastion" }){
            Param($Name,$Validation)
            $Validation | Should -BeFalse
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "bastion2" }){
            Param($Name,$Validation)
            $Validation | Should -BeTrue
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "fg-hcduddgb4lp24-NSG" }){
            Param($Name,$Validation)
            $Validation | Should -BeTrue
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "ml-wu2c09083361eabe" }){
            Param($Name,$Validation)
            $Validation | Should -BeFalse
        }
    }
}