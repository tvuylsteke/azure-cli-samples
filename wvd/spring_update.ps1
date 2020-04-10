
Register-PSRepository -Name WvdRepository -SourceLocation "C:\Users\thovuy\Downloads" -PackageManagementProvider Nuget -InstallationPolicy Trusted 

Install-Module -Name Az.Accounts -RequiredVersion 1.6.3 
Install-Module -Name Az.Resources 
Install-Module -Name Az.DesktopVirtualization -Repository WvdRepository 
Connect-AzAccount 

$sub = "182b812e-c741-4b45-93c6-26bdc3e4353b"
$rg = "wvd-spring-update"

Get-AzWvdWorkspace -SubscriptionId $sub -ResourceGroupName $rg

$ws = "thovuy-ws"

Get-AzWvdHostPool -SubscriptionId $sub

$hp = "thovuy-pool"

$hosts = Get-AzWvdSessionHost -HostPoolName $hp -ResourceGroupName $rg -SubscriptionId $sub