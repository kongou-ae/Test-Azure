$ErrorActionPreference = "stop"

Describe "AppService" {

    $AppsPlans = Get-AzAppServiceplan
    $TestCases = New-Object System.Collections.ArrayList

    $AppsPlans | ForEach-Object {
        $tmp = @{
            "Name" = $_.Name
            "Sku" = $_.Sku.Tier
        }
        $TestCases.Add($tmp) | Out-Null
    }

    Context "App Service Plan should be greater equal Basic" {
            
        BeforeEach {
            $errorSku = @("Shared","Free")
        }

        it "<Name>" -TestCases $TestCases {
            Param($Name,$Sku)
            $Sku | Should -not -BeIn $errorSku
        }
    }
}