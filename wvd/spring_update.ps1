
#preview only
#Register-PSRepository -Name WvdRepository -SourceLocation "C:\Users\thovuy\Downloads" -PackageManagementProvider Nuget -InstallationPolicy Trusted 
#Install-Module -Name Az.Accounts -RequiredVersion 1.6.3 
#Install-Module -Name Az.Resources 
#Install-Module -Name Az.DesktopVirtualization -Repository WvdRepository 

Install-Module -Name Az.DesktopVirtualization
Import-Module -Name Az.DesktopVirtualization
Connect-AzAccount 

$sub = "182b812e-c741-4b45-93c6-26bdc3e4353b"
$rg = "wvd-spring-update"
$ws = "thovuy-ws"
$hp = "thovuy-pool"

Select-AzSubscription -SubscriptionId $sub



$dag = Get-AzResource -ResourceGroupName $rg -Name demo-pool-dag
Get-AzRoleAssignment -Scope $dag.Id 





Get-AzWvdWorkspace -SubscriptionId $sub -ResourceGroupName $rg
Get-AzWvdHostPool -SubscriptionId $sub

$hosts = Get-AzWvdSessionHost -HostPoolName $hp -ResourceGroupName $rg -SubscriptionId $sub
$hosts | fl 

Get-AzWvdUserSession -HostPoolName $hp -ResourceGroupName $rg




subscription="MSDN THOVUY P130b"
az account set --subscription "$subscription"

logws_name=wvdlogsetspn
rg=wvd-spring-update
logws_id=$(az resource list -g $rg -n $logws_name --query '[].id' -o tsv)

azwvdws_id="/subscriptions/182b812e-c741-4b45-93c6-26bdc3e4353b/resourceGroups/wvd-spring-update/providers/Microsoft.DesktopVirtualization/workspaces/demo-ws"
az monitor diagnostic-settings create -n clitest --resource $azwvdws_id --workspace $logws_id \
    --logs '[{"category": "Checkpoint", "enabled": true, "retentionPolicy": {"days": 0, "enabled": false}}, 
        {"category": "Error", "enabled": true, "retentionPolicy": {"days": 0, "enabled": false}}, 
        {"category": "Management", "enabled": true, "retentionPolicy": {"days": 0, "enabled": false}}, 
            {"category": "Feed", "enabled": true, "retentionPolicy": {"days": 0, "enabled": false}}]' >/dev/null

