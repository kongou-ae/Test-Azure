$ErrorActionPreference = "stop"

Describe "Backup" {

    $vaults = Get-AzRecoveryServicesVault
    $vms = Get-azvm

    Context "VM backup should be enabled" {
    
        $backupedVms = New-Object System.Collections.ArrayList

        $vaults | ForEach-Object {
            $items = Get-AzRecoveryServicesBackupContainer -ContainerType AzureVM -VaultId $_.ID -Status Registered
            $items | ForEach-Object {
                $backupedVms.add($_) | Out-Null
            }
        }
       
        $vms | ForEach-Object {
            $vm = $_
            it "$($vm.Name)" {
                $backupedVms | Where-Object { $_.FriendlyName -eq $vm.Name -and $_.ResourceGroupName -eq $vm.ResourceGroupName } | Should -BeTrue
            }
        }
    }
}