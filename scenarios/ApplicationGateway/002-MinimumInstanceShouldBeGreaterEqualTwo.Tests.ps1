$ErrorActionPreference = "stop"

Describe "ApplicationGateway" {

    $appgws = Get-AzApplicationGateway

    Context "Minimum instance should be greater than two" {

        $appgws | ForEach-Object {
            $flag = $false
            $appgw = $_

            # v2 and manual scale
            if ( $appgw.AutoscaleConfiguration -eq $null ){
                if ( $appgw.Sku.Capacity -ge 2 ){
                    $flag = $true
                }
            # v2 and auto scale
            } else {
                if ( $appgw.AutoscaleConfiguration.MinCapacity -ge 2 ){
                    $flag = $true
                }
            }

            it "$($appgw.Name)"{
                $flag | Should -BeTrue
            }
        }
    }
}