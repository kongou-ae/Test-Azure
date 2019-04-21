Describe "Network" {

    Context "NSG Flow Logs should be enabled" {
    
        $watcheres = Get-AzNetworkWatcher
        $nsgs = Get-AzNetworkSecurityGroup

        $nsgs | ForEach-Object {
            $nsg = $_
            $watcher = $watcheres | Where-Object { $_.Location -eq $nsg.Location }
            $flowLogStatus = Get-AzNetworkWatcherFlowLogStatus -NetworkWatcher $watcher -TargetResourceId $_.Id
            $_.Id -match "networkSecurityGroups/(.*)?" | Out-Null
            $nsgName = $Matches[1]

            it "$nsgName"{
                $flowLogStatus.Enabled | Should -BeTrue
            }
        }
    }

    Context "Nic should be used" {
        $nics = Get-AzNetworkInterface

        $nics | ForEach-Object {
            $nic = $_
            it "$($nic.Name)" {
                $nic.VirtualMachine | Should -Not -Be $null
            }
        }
    }

    Context "Public ip address should be used" {
        $pips = Get-AzPublicIpAddress

        $pips | ForEach-Object {
            $pip = $_
            it "$($pip.Name)" {
                $pip.IpConfiguration | Should -Not -Be $null
            }
        }
    }

    Context "Runninng VM should be protected by NSG" {
        $usedNics = Get-AzNetworkInterface | Where-Object { $_.VirtualMachine -ne $null }
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