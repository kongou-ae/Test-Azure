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
}