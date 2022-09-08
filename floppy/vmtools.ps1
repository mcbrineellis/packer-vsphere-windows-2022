$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

$systemVendor = (Get-WmiObject Win32_ComputerSystemProduct Vendor).Vendor
if ($systemVendor -eq 'VMware, Inc.') {
    Write-Output 'Installing VMware Tools...'
    # silent install without rebooting.
    E:\setup64.exe /s /v '/qn reboot=r' `
        | Out-String -Stream
}