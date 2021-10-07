
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
  peer 13.77.220.155
    address 13.77.220.155
    pre-shared-key Microsoft123!
    exit
  peer 13.77.223.26
    address 13.77.223.26
    pre-shared-key Microsoft123!
    exit
  exit
!
crypto ikev2 profile azure-profile
  match address local interface GigabitEthernet1
  match identity remote address 13.77.220.155 255.255.255.255
  match identity remote address 13.77.223.26 255.255.255.255
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
 tunnel destination 13.77.220.155
 tunnel protection ipsec profile azure-vti
exit
!
interface Tunnel1
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 13.77.223.26
 tunnel protection ipsec profile azure-vti
exit

!
router bgp 65002
 bgp router-id interface GigabitEthernet1
 bgp log-neighbor-changes
 network 10.50.0.0 mask 255.255.0.0
 neighbor 192.168.12.12 remote-as 65515
 neighbor 192.168.12.12 ebgp-multihop 5
 neighbor 192.168.12.12 update-source GigabitEthernet1
 neighbor 192.168.12.13 remote-as 65515
 neighbor 192.168.12.13 ebgp-multihop 5
 neighbor 192.168.12.13 update-source GigabitEthernet1
!
ip route 10.12.10.0 255.255.255.0 10.11.10.1
ip route 192.168.12.13 255.255.255.255 Tunnel0
ip route 192.168.12.12 255.255.255.255 Tunnel1
!
end
!
