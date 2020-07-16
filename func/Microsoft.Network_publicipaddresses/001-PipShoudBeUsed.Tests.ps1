$ErrorActionPreference = "stop"

Describe "Microsoft.Network/publicipaddresses" {

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

        it "<Name>" -TestCases $TestCases{
            Param($Name,$IpConfiguration)
            $IpConfiguration | Should -Not -Be $Null
        }   
    }
}

