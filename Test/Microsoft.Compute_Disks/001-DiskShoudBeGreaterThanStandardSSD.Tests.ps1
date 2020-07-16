$ErrorActionPreference = "stop"

Describe "Microsoft.Compute/Disks" {

    $disks = $global:disks | ConvertFrom-Json -Depth 100
    $TestCases = New-Object System.Collections.ArrayList

    $disks | ForEach-Object {
        $tmp = @{
            "Name" = $_.Name
            "sku" = $_.Sku.Name
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "Disk should be greater than Standard SSD" {

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "ml-wu2c09083361eabe_osDisk" }){
            Param($Name,$sku)
            $sku | Should -Be "Standard_LRS"
        }

        it "<Name>" -TestCases ($TestCases | Where-Object { $_.Name -eq "gamehost-osdisk-20200223-015408" }){
            Param($Name,$sku)
            $sku | Should -Not -Be "Standard_LRS"
        }
    }
}