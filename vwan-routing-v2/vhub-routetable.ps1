Connect-AzAccount
$subscription="Azure CXP FTA Internal Subscription THOVUY SETSPN"
$rg="az-vwan-routing"
$vwan="vwan-routing-lab"
$hub="we-hub"  

Select-AzSubscription -SubscriptionName $subscription
Get-AzVHubRouteTable -ResourceGroupName $rg -HubName $hub

$RT = "WE-DEV-RT"
$label = "dev"

$route1 = New-AzVHubRoute -Name "private-traffic" -Destination @("10.30.0.0/16", "10.40.0.0/16") -DestinationType "CIDR" -NextHop $firewall.Id -NextHopType "ResourceId"
#New-AzVHubRouteTable -ResourceGroupName $rg -VirtualHubName $hub -Name $RT -Label @("$label") -Route @($route1) 
New-AzVHubRouteTable -ResourceGroupName $rg -VirtualHubName $hub -Name $RT -Label @("$label")

$connection = "we-spoke-vnet-01"
$connectionObj = Get-AzVirtualHubVnetConnection -ResourceGroupName $rg -VirtualHubName $hub -Name $connection

$route1 = New-AzVHubRoute -Name "private-traffic" -Destination @("10.30.0.0/16", "10.40.0.0/16") -DestinationType "CIDR" -NextHop $connectionObj.Id -NextHopType "ResourceId"
