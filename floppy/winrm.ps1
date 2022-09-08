$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# Move all non-domain network interfaces into the private profile.
Get-NetConnectionProfile `
    | Where-Object {$_.NetworkCategory -ne 'DomainAuthenticated'} `
    | Set-NetConnectionProfile -NetworkCategory Private

# Configure WinRM.
Write-Output 'Configuring WinRM...'
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/service/auth '@{CredSSP="true"}'

# Set the WinRM service startup type to delayed-auto, not auto (default in 2019).
$result = sc.exe config WinRM start= delayed-auto
if ($result -ne '[SC] ChangeServiceConfig SUCCESS') {
    throw "sc.exe config failed with $result"
}

# Print the WinRM configuration details.
Write-Output 'WinRM Configuration:'
winrm enumerate winrm/config/listener
winrm get winrm/config
winrm id

# Disable the UAC remote restrictions.
# see https://support.microsoft.com/en-us/help/951016/description-of-user-account-control-and-remote-restrictions-in-windows
# see https://docs.microsoft.com/en-us/windows/desktop/wmisdk/user-account-control-and-wmi#handling-remote-connections-under-uac
# see https://www.packer.io/docs/communicators/winrm

New-ItemProperty `
    -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' `
    -Name LocalAccountTokenFilterPolicy `
    -Value 1 `
    -Force `
    | Out-Null

# Create a firewall rule for WinRM
New-NetFirewallRule `
    -DisplayName WINRM-ALLOW-PACKER `
    -Direction Inbound `
    -Action Allow `
    -Protocol TCP `
    -LocalPort 5985 `
    | Out-Null