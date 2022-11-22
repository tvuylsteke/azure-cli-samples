# Stop an existing firewall

$rg = "sentinel"

$azfw = Get-AzFirewall -Name "azfw" -ResourceGroupName $rg
$azfw.Deallocate()
Set-AzFirewall -AzureFirewall $azfw

# Start the firewall
$rg = "sentinel"
$azfw = Get-AzFirewall -Name "azfw" -ResourceGroupName $rg
$vnet = Get-AzVirtualNetwork -ResourceGroupName $rg -Name "hub-vnet"
$publicip1 = Get-AzPublicIpAddress -Name "azfw-pip" -ResourceGroupName $rg
#$publicip2 = Get-AzPublicIpAddress -Name "Public IP2 Name" -ResourceGroupName $rg
#$azfw.Allocate($vnet,@($publicip1,$publicip2))
$azfw.Allocate($vnet,@($publicip1))

Set-AzFirewall -AzureFirewall $azfw


CEF
logger -p local4.warn -P 514 -n 127.0.0.1 --rfc3164 -t CEF"0|Mock-test|MOCK|common=event-format-test|end|TRAFFIC|1|rt=$common=event-formatted-receive_time"

tcpdump -I any port 514 -A vv &