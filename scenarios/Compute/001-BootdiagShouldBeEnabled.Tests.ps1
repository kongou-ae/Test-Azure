$ErrorActionPreference = "stop"

Describe "Compute" {

    $vms = Get-AzVm

    Context "Boot diag should be enabled" {

        $vms | ForEach-Object {
            $vm = $_

            it "$($vm.Name)"{
                $vm.DiagnosticsProfile.BootDiagnostics.Enabled | Should -BeTrue
            }
        }
    }
}