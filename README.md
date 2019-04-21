# Test-Azure

PowerShell script to validate Azure environment.

![](https://user-images.githubusercontent.com/3410186/56469912-b65f5700-647a-11e9-9681-99461e4f69d0.PNG)

## Usage 

- Open PowerShell
- git clone https://github.com/kongou-ae/Test-Azure
- Login Azure scription which you want to validate.
- ./Test-Azure.ps1

## The points which are validated by this script

### Backup

- VM backup should be enabled
- Latest backup should be within 24 hours
- Backup alert for VM backup should be configured

### Network

- NSG Flow Logs should be enabled
- Unused nic should be deleted
- Unused public ip address should be deleted

### Disk 

- Unused disk should be deleted
