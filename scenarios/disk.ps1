Describe "Disk" {
    
    Context "Disk should be used" {
        $disks = Get-AzDisk

        $disks | ForEach-Object {
            $disk = $_
            $asrDisk = $false
            $disk.Tags.Keys | ForEach-Object {
                if ($_ -match "ASR-ReplicaDisk"){
                    $asrDisk = $true
                }
            }

            if ($disk.Tags["TestAzure"] -eq "skip") {
                it "$($disk.Name)" -Skip {
                    # Diskが誰かにマウントされている
                    $disk.ManagedBy -ne $null -or `
                    # または、ASRのタグがついてる　のいずれかがTrue
                    $asrDisk -eq $true | Should -BeTrue
                }
            } else {
                it "$($disk.Name)"{
                    $disk.ManagedBy -ne $null -or `
                    $asrDisk -eq $true | Should -BeTrue
                }
            }
        }
    }
}