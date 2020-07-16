Describe "Microsoft.Compute/virtualMachines" {

    $vms = $global:vms | ConvertFrom-Json -Depth 100
    $TestCases = New-Object System.Collections.ArrayList

    $vms | ForEach-Object {
        $tmp = @{
            "Name" = $_.Name
            "BootDiagnostics" = $_.DiagnosticsProfile.BootDiagnostics.Enabled
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "Boot diag should be enabled" {

        it "<Name>" -TestCases $TestCases {
            Param($Name,$BootDiagnostics)
            $BootDiagnostics | Should -BeTrue
        }
    }
}