$ErrorActionPreference = "stop"

Describe "ApplicationGateway" {

    $appgws = Get-AzApplicationGateway

    Context "Application Gateway should be v2" {

        $appgws | ForEach-Object {
            $flag = $false
            $appgw = $_

            if ($appgw.Sku.Name -eq "Standard_v2" -or $appgw.Sku.Name -eq "WAF_v2"){
                $flag = $True
            }

            it "$($appgw.Name)"{
                $flag | Should -Be $true
            }
        }
    }
}