Describe "Microsoft.Compute" {

    $vms = $global:vms | ConvertFrom-Json -Depth 100
    $TestCases = New-Object System.Collections.ArrayList

    $vms | ForEach-Object {
        $tmp = @{
            "Name" = $_.Name
            "ManagedDiskId" = $_.StorageProfile.OsDisk.ManagedDisk.Id
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "OS Disk Should be managed disk" {

        it "<Name>" -TestCases $TestCases{
            Param($Name,$ManagedDiskId)
            $ManagedDiskId | Should -Not -BeNullOrEmpty
        }
    }
}