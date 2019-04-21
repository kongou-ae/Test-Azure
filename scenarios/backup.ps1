$ErrorActionPreference = "stop"

Describe "Backup" {

    Context "VM backup should be enabled" {
    
        $backupedVms = New-Object System.Collections.ArrayList

        $vaults = Get-AzRecoveryServicesVault
        $vms = Get-azvm

        $vaults | ForEach-Object {
            $items = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            $items | ForEach-Object {
                $backupedVms.add($_) | Out-Null
            }
        }
       
        $vms | ForEach-Object {
            $vm = $_
            it "$($vm.Name)"{
                $backupedVms | Where-Object { $_.FriendlyName -eq $vm.Name -and $_.ResourceGroupName -eq $vm.ResourceGroupName } | Should -BeTrue
            }
        }
    }

    Context "Latest backup should be within 24 hours" {
    
        $backupedItems = New-Object System.Collections.ArrayList

        $vaults = Get-AzRecoveryServicesVault
        $vms = Get-azvm

        $vaults | ForEach-Object {
            $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            if ($container){
                $backupedItems.Add((Get-AzRecoveryServicesBackupItem -VaultId $_.ID -Container $container -WorkloadType AzureVM))
            }
        }

        $vms | ForEach-Object {
            $vm = $_
            $protectVmDaily = $false
            $backupedItems | Where-Object { $_.VirtualMachineId -eq $vm.Id } | ForEach-Object {
                if ( $_.ProtectionStatus -eq "Healthy" ){
                    # UTC
                    if ( $_.LastBackupTime.AddHours(9) -gt (Get-Date).AddDays(-1) ){
                        $protectVmDaily = $true
                    }
                }
                it "$($vm.Name)" {
                    $protectVmDaily | Should -BeTrue
                }
            }
        }
    }

    Context "Backup alert for VM backup should be configured" {

        $azContext = Get-AzContext
        $azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
        $profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azProfile)
        $token = $profileClient.AcquireAccessToken($azContext.Tenant.TenantId)
        $token.AccessToken

        $authHeader = "Bearer " + $token.AccessToken
        $requestHeader = @{
            "Authorization" = $authHeader
            "Accept" = "application/json"
        }

        $vaults = Get-AzRecoveryServicesVault
        $vaults | ForEach-Object {
            $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            if ( $container ) {
                $res = Invoke-RestMethod -Method GET -Uri "https://management.azure.com$($_.ID)/monitoringConfigurations/notificationConfiguration?api-version=2017-07-01-preview" -Headers $requestHeader -ContentType "application/json;charset=utf-8"

                it "$($_.Name)" {
                    $res.properties.areNotificationsEnabled -eq $true -and `
                    $res.properties.hasValidEmailAddresses -eq $true -and `
                    $res.properties.severitiesToNotifyFor.Contains(1) | Should -BeTrue
                }
            }
        }
    }
}