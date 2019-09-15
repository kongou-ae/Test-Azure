$ErrorActionPreference = "stop"

Describe "Backup" {

    $vaults = Get-AzRecoveryServicesVault

    Context "Recovery Service Vault should be GRS" {
    
        $vaults | ForEach-Object {
            $vault = $_
            $vaultProperty = Get-AzRecoveryServicesBackupProperties -Vault $vault

            it "$($vault.Name)" {
                $vaultProperty.BackupStorageRedundancy | Should -Be "GeoRedundant"
            }
        }
    }
}