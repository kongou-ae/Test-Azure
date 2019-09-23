$ErrorActionPreference = "stop"

Describe "Subscription" {

    $alerts = Get-AzResource -ResourceType microsoft.insights/activityLogAlerts -ExpandProperties
    $subscriptionId = (Get-Azcontext).Subscription.Id

    Context "The alert about health advisories should be configured" {
    
        $flag = $false
        $alerts | ForEach-Object {

            $condition1 = [ordered]@{
                "allOf" = @(
                    [ordered]@{
                        "field" = "category";
                        "equals" = "ServiceHealth";
                        "containsAny" = $null;
                        "odata.type" =  $null;
                    }
                )
                "odata.type" =  $null;
            } | ConvertTo-Json -Depth 100
            
            $condition2 = [ordered]@{
                "allOf" = @(
                    [ordered]@{
                        "field" = "category";
                        "equals" = "ServiceHealth";
                        "containsAny" = $null;
                        "odata.type" =  $null;
                    },
                    [ordered]@{
                        "anyOf" = @(
                            [ordered]@{
                                "field" = "properties.incidentType";
                                "equals" = "Informational";
                                "containsAny" = $null;
                                "odata.type" =  $null;
                            },
                            [ordered]@{
                                "field" = "properties.incidentType";
                                "equals" = "ActionRequired";
                                "containsAny" = $null;
                                "odata.type" =  $null;
                            }
                        )
                        "odata.type" =  $null;
                    }
                )
                "odata.type" =  $null;
            } | ConvertTo-Json -Depth 100

            $alert = $_
            # All alert is configured
            if ( ($alert.Properties.condition | convertto-json -depth 100) -eq $condition1 ){
                $flag = $true
            }

            # Specific alert is configured
            if ( ($alert.Properties.condition | convertto-json -depth 100) -eq $condition2 ){
                $flag = $true
            }
        }

        it "$subscriptionId" {
            $flag | Should -BeTrue
        }

    }
}