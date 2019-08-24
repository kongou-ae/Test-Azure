$ErrorActionPreference = "stop"

Describe "Disk" {
    
    $disks = Get-AzDisk

    Context "Disk should be used" {

        $disks | ForEach-Object {
            $disk = $_
            $asrDisk = $false
            $disk.Tags.Keys | ForEach-Object {
                if ($_ -match "ASR-ReplicaDisk"){
                    $asrDisk = $true
                }
            }

            it "$($disk.Name)"{
                $disk.ManagedBy -ne $null -or `
                $asrDisk -eq $true | Should -BeTrue
            }
        }
    }
}
