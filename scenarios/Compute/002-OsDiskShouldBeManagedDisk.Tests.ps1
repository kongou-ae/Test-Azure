$ErrorActionPreference = "stop"

Describe "Compute" {

    $vms = Get-AzVm

    Context "OS Disk Should be managed disk" {

        $vms | ForEach-Object {
            $vm = $_

            it "$($vm.Name)"{
                $vm.StorageProfile.OsDisk.ManagedDisk.Id | Should -BeTrue
            }
        }
    }
}