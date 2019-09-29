$ErrorActionPreference = "stop"

Describe "AppService" {

    $AppsPlans = Get-AzAppServiceplan

    Context "App Service Plan should be greater equal Basic" {

        $AppsPlans | ForEach-Object {
            $flag = $true
            $AppsPlan = $_

            if ( $AppsPlan.Sku.Tier -eq "Shared" -or $AppsPlan.Sku.Tier -eq "Free" ){
                $flag = $false
            }

            it "$($AppsPlan.Name)" {
                $flag | Should -be $true
            } 
        }
    }
}