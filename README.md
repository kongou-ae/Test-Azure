# Test-Azure

PowerShell script to validate your Azure environment.

<img src="media/image001.png" width="400px">

## Usage 

1. Open PowerShell
2. git clone https://github.com/kongou-ae/Test-Azure
3. Login Azure scription which you want to validate.
4. Validate your Azure
   1. ./Test-Azure.ps1 # Readable output
   2. ./Test-Azure.ps1 -json # JSON

## The points validated by this script

### Microsoft.Compute

- Boot diag should be enabled
- OS Disk Should be managed disk
  
### Microsoft.Compute/Disks

- Disk should be greater equal Standard SSD

### Microsoft.Network/loadbalancers

- LB should be Standard SKU
- Standard LB should be zone redundant

### Microsoft.Network/networkSecurityGroups

- NSG Flow Logs should be enabled

### Microsoft.Network/publicipaddresses

- Public IP Address should be used

### Microsoft.Network/virtualNetworkGateways

- VPN Gateway should be greater than basic SKU

### Microsoft.Network/virtualNetworks

- Gateway subnet should be /27
