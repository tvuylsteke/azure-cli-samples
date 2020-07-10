
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
  peer 51.105.202.56
    address 51.105.202.56
    pre-shared-key Microsoft123!
    exit
  peer 51.105.205.73
    address 51.105.205.73
    pre-shared-key Microsoft123!
    exit
  peer 40.127.152.155
    address 40.127.152.155
    pre-shared-key Microsoft123!
    exit
  peer 40.127.152.147
    address 40.127.152.147
    pre-shared-key Microsoft123!
    exit
  exit
!
crypto ikev2 profile azure-profile
  match address local interface GigabitEthernet1
  match identity remote address 51.105.202.56 255.255.255.255
  match identity remote address 51.105.205.73 255.255.255.255
  match identity remote address 40.127.152.155 255.255.255.255
  match identity remote address 40.127.152.147 255.255.255.255
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
 tunnel destination 51.105.202.56
 tunnel protection ipsec profile azure-vti
exit
!
interface Tunnel1
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 51.105.205.73
 tunnel protection ipsec profile azure-vti
exit

interface Tunnel2
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 40.127.152.155
 tunnel protection ipsec profile azure-vti
exit

interface Tunnel3
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 40.127.152.147
 tunnel protection ipsec profile azure-vti
exit
!
router bgp 65050
 bgp router-id interface GigabitEthernet1
 bgp log-neighbor-changes
 network 10.50.0.0 mask 255.255.0.0
 neighbor 10.101.10.13 remote-as 65515
 neighbor 10.101.10.13 ebgp-multihop 5
 neighbor 10.101.10.13 update-source GigabitEthernet1
 neighbor 10.101.10.12 remote-as 65515
 neighbor 10.101.10.12 ebgp-multihop 5
 neighbor 10.101.10.12 update-source GigabitEthernet1
 neighbor 10.102.10.12 remote-as 65515
 neighbor 10.102.10.12 ebgp-multihop 5
 neighbor 10.102.10.12 update-source GigabitEthernet1
 neighbor 10.102.10.13 remote-as 65515
 neighbor 10.102.10.13 ebgp-multihop 5
 neighbor 10.102.10.13 update-source GigabitEthernet1
!
ip route 10.50.0.0 255.255.0.0 10.50.1.1
ip route 10.101.10.12 255.255.255.255 Tunnel0
ip route 10.101.10.13 255.255.255.255 Tunnel1
ip route 10.102.10.12 255.255.255.255 Tunnel2
ip route 10.102.10.13 255.255.255.255 Tunnel3
!
end
!