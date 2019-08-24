$ErrorActionPreference = "stop"

Describe "Backup" {

    $vaults = Get-AzRecoveryServicesVault
    $vms = Get-azvm

    Context "Latest backup should be within 24 hours" {
    
        $backupedItems = New-Object System.Collections.ArrayList

        $vaults | ForEach-Object {
            $vault = $_
            $containers = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $vault.ID -Status Registered
            if ($containers){
                $containers | ForEach-Object {
                    $backupedItems.Add((Get-AzRecoveryServicesBackupItem -VaultId $vault.ID -Container $_ -WorkloadType AzureVM))
                }
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