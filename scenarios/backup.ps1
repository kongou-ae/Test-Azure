$ErrorActionPreference = "stop"

Describe "Backup" {

    Context "Enable VM backup" {
    
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

    Context "Latest backup is within 24 hours" {
    
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
}