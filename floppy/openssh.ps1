$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service and set it to start automatically
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'