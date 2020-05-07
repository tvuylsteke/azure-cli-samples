Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"

$t = "WVD-ADO"
$hp = "wvdpool2"

$hostpoolname = (Get-RdsHostPool -TenantName $tenantname).HostPoolName

Get-RdsAppGroup -TenantName $t -HostPoolName $hp

$ag = "Desktop Application Group"
Get-RdsAppGroupUser -TenantName $t -HostPoolName $hp -AppGroupName $ag
Add-RdsAppGroupUser $t $hp $ag  -UserPrincipalName wvd1@setspn.tk

Get-RdsRemoteApp -TenantName $t -HostPoolName $hp -AppGroupName ...
Get-RdsRemoteDesktop -TenantName $t -HostPoolName $hp -AppGroupName "Desktop Application Group"

Get-RdsSessionHost -TenantName $t -HostPoolName $hp
get-RdsUserSession -tenantname $t -HostPoolName $hp

#test users
for($i = 20; $i -lt 40; $i++){
	$uname = "wvd$i"
	$password = "Microsoft123!" | ConvertTo-SecureString -AsPlainText -Force
	New-ADUser -Name "$uname" -GivenName "$uname" -SamAccountName "$uname" -UserPrincipalName "$uname@setspn.tk" -Path "OU=setspn,DC=setspn,DC=local" -AccountPassword $password -Enabled $true
}
