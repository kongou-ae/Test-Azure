$ErrorActionPreference = "stop"

Describe "Network" {

    $pips = Get-AzPublicIpAddress

    Context "Public ip address should be used" {

        $pips | ForEach-Object {
            $pip = $_

            it "$($pip.Name)" {
                $pip.IpConfiguration | Should -Not -Be $null
            }
        }
    }
}

