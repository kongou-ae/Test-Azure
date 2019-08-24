$ErrorActionPreference = "stop"

Describe "Network" {

    $usedNics = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine -ne $null }

    Context "Used NIC should be protected by NSG" {
        $usedNics | ForEach-Object {
            $usedNic = $_
            $usedNic.VirtualMachine.id -match "resourceGroups/(.*)/providers/Microsoft.Compute/virtualMachines/(.*)?"
            $vm = Get-AzVm -ResourceGroupName $Matches[1] -Name $Matches[2] -Status 
            if ( $vm.Statuses[1].Code -eq "PowerState/running" ){
                # A warning message raised if vm is not running
                $EffectiveNetworkSecurityGroup = Get-AzEffectiveNetworkSecurityGroup -NetworkInterfaceName $usedNic.Name -ResourceGroupName $usedNic.ResourceGroupName -WarningAction 'SilentlyContinue'
                it "$($usedNic.Name)" {
                    $EffectiveNetworkSecurityGroup | Should -Not -Be $null
                }
            }
        }
    }
}
