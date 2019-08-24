$ErrorActionPreference = "stop"

Describe "Network" {

    $nics = Get-AzNetworkInterface

    Context "Nic should be used" {

        $nics | ForEach-Object {
            $nic = $_

            it "$($nic.Name)" {
                $nic.VirtualMachine | Should -Not -Be $null
            }                
        }
    }
}