$ErrorActionPreference = "stop"

Describe "Compute" {

    $vms = Get-AzVm -Status

    Context "Virtual Machine should not be stopped" {

        $vms | ForEach-Object {
            $vm = $_

            it "$($vm.Name)"{
                $vm.PowerState | Should -Not -Be "VM stopped"
            }
        }
    }
}