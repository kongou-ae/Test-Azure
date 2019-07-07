$ErrorActionPreference = "stop"

Describe "Backup" {

    $script:vaults = Get-AzRecoveryServicesVault
    $script:vms = Get-azvm

    Context "VM backup should be enabled" {
    
        $backupedVms = New-Object System.Collections.ArrayList

        $script:vaults | ForEach-Object {
            $items = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            $items | ForEach-Object {
                $backupedVms.add($_) | Out-Null
            }
        }
       
        $script:vms | ForEach-Object {
            $vm = $_

            if ($vm.Tags["TestAzure"] -eq "skip") {            
                it "$($vm.Name)" -Skip {
                    $backupedVms | Where-Object { $_.FriendlyName -eq $vm.Name -and $_.ResourceGroupName -eq $vm.ResourceGroupName } | Should -BeTrue
                }
            } else {
                it "$($vm.Name)" {
                    $backupedVms | Where-Object { $_.FriendlyName -eq $vm.Name -and $_.ResourceGroupName -eq $vm.ResourceGroupName } | Should -BeTrue
                }
            }
        }
    }

    Context "Latest backup should be within 24 hours" {
    
        $backupedItems = New-Object System.Collections.ArrayList

        $script:vaults | ForEach-Object {
            $vault = $_
            $containers = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault.ID -Status Registered
            if ($containers){
                $containers | ForEach-Object {
                    $backupedItems.Add((Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -Container $_ -WorkloadType AzureVM))
                }
            }
        }

        $script:vms | ForEach-Object {
            $vm = $_
            $protectVmDaily = $false
            $backupedItems | Where-Object { $_.VirtualMachineId -eq $vm.Id } | ForEach-Object {
                if ( $_.ProtectionStatus -eq "Healthy" ){
                    # UTC
                    if ( $_.LastBackupTime.AddHours(9) -gt (Get-Date).AddDays(-1) ){
                        $protectVmDaily = $true
                    }
                }

                if ($vm.Tags["TestAzure"] -eq "skip") {
                    it "$($vm.Name)" -Skip {
                        $protectVmDaily | Should -BeTrue
                    }
                } else {
                    it "$($vm.Name)" {
                        $protectVmDaily | Should -BeTrue
                    }                    
                }
            }
        }
    }

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

        $script:vaults | ForEach-Object {
            $container = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            if ( $container ) {
                $res = Invoke-RestMethod -Method GET -Uri "https://management.azure.com$($_.ID)/monitoringConfigurations/notificationConfiguration?api-version=2017-07-01-preview" -Headers $requestHeader -ContentType "application/json;charset=utf-8"

                $vault = Get-AzResource -ResourceId $_.ID -ExpandProperties

                if ($vault.Tags -ne $null -and $vault.Tags["TestAzure"] -eq "skip") {
                    it "$($_.Name)" -Skip {
                        $res.properties.areNotificationsEnabled -eq $true -and `
                        $res.properties.hasValidEmailAddresses -eq $true -and `
                        $res.properties.severitiesToNotifyFor -Contains(1) | Should -BeTrue
                    }
                } else {
                    it "$($_.Name)" {
                        $res.properties.areNotificationsEnabled -eq $true -and `
                        $res.properties.hasValidEmailAddresses -eq $true -and `
                        $res.properties.severitiesToNotifyFor -Contains(1) | Should -BeTrue
                    }                    
                }
            }
        }
    }
}