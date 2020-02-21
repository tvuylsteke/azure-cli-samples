crypto ikev2 proposal azure-proposal
  encryption aes-cbc-256 aes-cbc-128 3des
  integrity sha1
  group 2
  exit
!
crypto ikev2 policy azure-policy
  proposal azure-proposal
  exit
!
crypto ikev2 keyring azure-keyring
  peer 51.138.68.18
    address 51.138.68.18
    pre-shared-key Microsoft123!
    exit  
  exit
!
crypto ikev2 profile azure-profile
  match address local interface GigabitEthernet1
  match identity remote address 51.138.68.18 255.255.255.255  
  authentication remote pre-share
  authentication local pre-share
  keyring local azure-keyring
  exit
!
crypto ipsec transform-set azure-ipsec-proposal-set esp-aes 256 esp-sha-hmac
 mode tunnel
 exit

crypto ipsec profile azure-vti
  set transform-set azure-ipsec-proposal-set
  set ikev2-profile azure-profile
  set security-association lifetime kilobytes 102400000
  set security-association lifetime seconds 3600 
 exit
!
interface Tunnel0
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 51.138.68.18
 tunnel protection ipsec profile azure-vti
exit
!
ip route 10.70.0.0 255.255.0.0 10.70.1.1
ip route 10.60.0.0 255.255.0.0 Tunnel0
ip route 10.50.0.0 255.255.0.0 Tunnel0
ip route 10.101.11.0 255.255.255.0 Tunnel0
ip route 10.101.12.0 255.255.255.0 Tunnel0
ip route 10.101.13.0 255.255.255.0 Tunnel0
!
end
!