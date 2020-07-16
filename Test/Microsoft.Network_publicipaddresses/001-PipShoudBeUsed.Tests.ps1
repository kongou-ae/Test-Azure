$ErrorActionPreference = "stop"

Describe "Microsoft.Network_publicipaddresses" {

    $pips = $global:pips | ConvertFrom-Json -Depth 100 
    $TestCases = New-Object System.Collections.ArrayList

    Context "Public ip address should be used" {

        $pips | ForEach-Object {
            $tmp = @{
                "Name" = $_.Name
                "IpConfiguration" = $_.IpConfiguration
            }
            $TestCases.Add($tmp) | Out-Null
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "10.0.1.100" }){
            Param($Name,$IpConfiguration)
            $IpConfiguration | Should -Be $Null
        } 

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "azureFirewalls-ip" }){
            Param($Name,$IpConfiguration)
            $IpConfiguration | Should -Be $Null
        } 

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "std" }){
            Param($Name,$IpConfiguration)
            $IpConfiguration | Should -Be $Null
        } 

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "gamehost-pip-5d10fb099d3d47ba9ed22cdb1a42fc8b" }){
            Param($Name,$IpConfiguration)
            $IpConfiguration | Should -Not -Be $Null
        } 

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "ml-wu2c09083361eabe" }){
            Param($Name,$IpConfiguration)
            $IpConfiguration | Should -Not -Be $Null
        } 
    }
}

