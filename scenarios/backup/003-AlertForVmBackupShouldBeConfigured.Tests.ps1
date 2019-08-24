$ErrorActionPreference = "stop"

Describe "Backup" {

    $vaults = Get-AzRecoveryServicesVault
    $vms = Get-azvm

    Context "Backup alert for VM backup should be configured" {

        $azContext = Get-AzContext
        $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
        $token = $profileClient.AcquireAccessToken($azContext.Tenant.TenantId)

        $authHeader = "Bearer " + $token.AccessToken
        $requestHeader = @{
            "Authorization" = $authHeader
            "Accept" = "application/json"
        }

        $vaults | ForEach-Object {
            $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            if ( $container ) {
                $res = Invoke-RestMethod -Method GET -Uri "https://management.azure.com$($_.ID)/monitoringConfigurations/notificationConfiguration?api-version=2017-07-01-preview" -Headers $requestHeader -ContentType "application/json;charset=utf-8"

                it "$($_.Name)" {
                    $res.properties.areNotificationsEnabled -eq $true -and `
                    $res.properties.hasValidEmailAddresses -eq $true -and `
                    $res.properties.severitiesToNotifyFor -Contains(1) | Should -BeTrue
                }
            }
        }
    }
}