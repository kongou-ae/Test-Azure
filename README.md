# Test-Azure

PowerShell script to validate Azure environment.

<img src="media/image001.png" width="400px">

## Usage 

- Open PowerShell
- git clone https://github.com/kongou-ae/Test-Azure
- Login Azure scription which you want to validate.
- ./Test-Azure.ps1 # Readable output
- ./Test-Azure.ps1 -json # JSON

## The points which are validated by this script

### Recovery Service Vault

- VM backup should be enabled
- Latest backup should be within 24 hours
- Backup alert for VM backup should be configured

### Network

- NSG Flow Logs should be enabled
- Unused nic should be deleted
- Unused public ip address should be deleted
- Runninng VM should be protected by NSG
- VPN Gateway should be more than basic
- NSG Should has all deny rule in the last row

### Load Balancer

- LB should be Standard SKU
- Standard LB should be zone redundant

### Disk 

- Unused disk should be deleted
- Disk should be more than Standard HDD

### Compute

- Boot diag should be enabled
- OS Disk Should be managed disk