Describe "Compute" {
    
    Context "Boot diag should be enabled" {
        $vms = Get-AzVm

        $vms | ForEach-Object {
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
}