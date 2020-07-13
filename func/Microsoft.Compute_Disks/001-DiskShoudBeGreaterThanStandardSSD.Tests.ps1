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

        it "<Name>" -TestCases $TestCases{
            Param($Name,$sku)
            $sku | Should -Not -Be "Standard_LRS"
        }
    }
}