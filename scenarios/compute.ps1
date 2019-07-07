Describe "Compute" {

    $script:vms = Get-AzVm

    Context "Boot diag should be enabled" {

        $script:vms | ForEach-Object {
            $vm = $_

            if ($vm.Tags["TestAzure"] -eq "skip") {
                it "$($vm.Name)" -Skip {
                    $vm.DiagnosticsProfile.BootDiagnostics.Enabled | Should -BeTrue
                }
            } else {
                it "$($vm.Name)"{
                    $vm.DiagnosticsProfile.BootDiagnostics.Enabled | Should -BeTrue
                }
            }
        }
    }

    Context "OS Disk Should be managed disk" {

        $script:vms | ForEach-Object {
            $vm = $_

            if ($vm.Tags["TestAzure"] -eq "skip") {
                it "$($vm.Name)" -Skip {
                    $vm.StorageProfile.OsDisk.ManagedDisk.Id | Should -BeTrue
                }
            } else {
                it "$($vm.Name)"{
                    $vm.StorageProfile.OsDisk.ManagedDisk.Id | Should -BeTrue
                }
            }
        }
    }
}