$ErrorActionPreference = "stop"

Describe "NetworkSecurityGroup" {

    $watcheres = Get-AzNetworkWatcher
    $nsgs = Get-AzNetworkSecurityGroup

    Context "NSG Flow Logs should be enabled" {
    
        $nsgs | ForEach-Object {
            $nsg = $_
            $watcher = $watcheres | Where-Object { $_.Location -eq $nsg.Location }
            $flowLogStatus = Get-AzNetworkWatcherFlowLogStatus -NetworkWatcher $watcher -TargetResourceId $_.Id
            $_.Id -match "networkSecurityGroups/(.*)?" | Out-Null
            $nsgName = $Matches[1]

            it "$nsgName" {
                $flowLogStatus.Enabled | Should -BeTrue
            }
        }
    }
}