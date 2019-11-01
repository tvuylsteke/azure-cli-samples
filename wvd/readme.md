Add-RdsAccount -DeploymentUrl "https://rdbroker.wvd.microsoft.com"
$tenantname = (Get-RdsTenant).TenantName
$hostpoolname = (Get-RdsHostPool -TenantName $tenantname).HostPoolName

$t = "WVD-ADO"
$hp = "wvdpool1"

Get-RdsAppGroup -TenantName $t -HostPoolName $hp

$ag = "Desktop Application Group"
Get-RdsAppGroupUser -TenantName $t -HostPoolName $hp -AppGroupName $ag
Add-RdsAppGroupUser $t $hp $ag  -UserPrincipalName wvd1@setspn.tk