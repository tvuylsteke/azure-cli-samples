
```

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
  peer 51.105.182.45
    address 51.105.182.45
    pre-shared-key Microsoft123!
    exit
  peer 51.144.62.96
    address 51.144.62.96
    pre-shared-key Microsoft123!
    exit
  peer 52.158.125.242
    address 52.158.125.242
    pre-shared-key Microsoft123!
    exit
  peer 52.155.232.124
    address 52.155.232.124
    pre-shared-key Microsoft123!
    exit
  exit
!
crypto ikev2 profile azure-profile
  match address local interface GigabitEthernet1
  match identity remote address 51.105.182.45 255.255.255.255
  match identity remote address 51.144.62.96 255.255.255.255
  match identity remote address 52.158.125.242 255.255.255.255
  match identity remote address 52.155.232.124 255.255.255.255
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
 tunnel destination 51.105.182.45
 tunnel protection ipsec profile azure-vti
exit
!
interface Tunnel1
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 51.144.62.96
 tunnel protection ipsec profile azure-vti
exit

interface Tunnel2
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 52.158.125.242
 tunnel protection ipsec profile azure-vti
exit

interface Tunnel3
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination 52.155.232.124
 tunnel protection ipsec profile azure-vti
exit
!
router bgp 65000
 bgp router-id interface GigabitEthernet1
 bgp log-neighbor-changes
 neighbor 10.101.10.13 remote-as 65515
 neighbor 10.101.10.13 ebgp-multihop 5
 neighbor 10.101.10.13 update-source GigabitEthernet1
 neighbor 10.101.10.12 remote-as 65515
 neighbor 10.101.10.12 ebgp-multihop 5
 neighbor 10.101.10.12 update-source GigabitEthernet1
 neighbor 10.101.20.12 remote-as 65515
 neighbor 10.101.20.12 ebgp-multihop 5
 neighbor 10.101.20.12 update-source GigabitEthernet1
 neighbor 10.101.20.13 remote-as 65515
 neighbor 10.101.20.13 ebgp-multihop 5
 neighbor 10.101.20.13 update-source GigabitEthernet1
!
ip route 10.101.10.12 255.255.255.255 Tunnel0
ip route 10.101.10.13 255.255.255.255 Tunnel1
ip route 10.101.20.12 255.255.255.255 Tunnel2
ip route 10.101.20.13 255.255.255.255 Tunnel3
!
end
!


```