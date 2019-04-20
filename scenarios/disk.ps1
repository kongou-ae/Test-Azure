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
            it "$($disk.Name)" {
                # Diskが誰かにマウントされている
                $disk.ManagedBy -ne $null -or `
                # または、ASRのタグがついてる　のいずれかがTrue
                $asrDisk -eq $true | Should -BeTrue
            }
        }
    }
}