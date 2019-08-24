$ErrorActionPreference = "stop"

Describe "Disk" {
    
    $disks = Get-AzDisk

    Context "Disk should be more than Standard HDD" {

        $disks | ForEach-Object {
            $disk = $_

            it "$($disk.Name)"{
                $disk.Sku.Name | Should -Not -Be "Standard_LRS"
            }
        }
    }
}