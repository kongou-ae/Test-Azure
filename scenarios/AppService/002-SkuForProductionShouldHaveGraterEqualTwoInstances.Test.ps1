$ErrorActionPreference = "stop"

Describe "AppService" {

    $AppsPlans = Get-AzAppServiceplan

    Context "Sku for production should have grater equal two instances" {

        $AppsPlans | ForEach-Object {
            $flag = $true
            $AppsPlan = $_

            if ( $AppsPlan.Sku.Tier -eq "Shared" -or $AppsPlan.Sku.Tier -eq "Free" -or $AppsPlan.Sku.Tier -eq "Dynamic"){
                
            } else {
                it "$($AppsPlan.Name)" {
                    $AppsPlan.Sku.Capacity | Should -BeGreaterOrEqual 2 
                }     
            }
        }
    }
}