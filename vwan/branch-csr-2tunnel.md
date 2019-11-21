Configure CSR
https://github.com/erjosito/azure-wan-lab/#deploy-configuration-manually

<VWAN-0-PIP>            first public IP of the VWAN
<VWAN-0-PeerAddress>    first private (BGP Peer) address of the VWAN
<VWAN-1-PIP>            second public IP of the VWAN
<VWAN-1-PeerAddress>    second private (BGP Peer) address of the VWAN

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
  peer <VWAN-0-PIP>
    address <VWAN-0-PIP>
    pre-shared-key Microsoft123!
    exit
  peer <VWAN-1-PIP>
    address <VWAN-1-PIP>
    pre-shared-key Microsoft123!
    exit
  exit
!
crypto ikev2 profile azure-profile
  match address local interface GigabitEthernet1
  match identity remote address <VWAN-0-PIP> 255.255.255.255
  match identity remote address <VWAN-1-PIP> 255.255.255.255
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
 tunnel destination <VWAN-0-PIP>
 tunnel protection ipsec profile azure-vti
exit
!
interface Tunnel1
 ip unnumbered GigabitEthernet1 
 ip tcp adjust-mss 1350
 tunnel source GigabitEthernet1
 tunnel mode ipsec ipv4
 tunnel destination <VWAN-1-PIP>
 tunnel protection ipsec profile azure-vti
exit

!
router bgp 65000
 bgp router-id interface GigabitEthernet1
 bgp log-neighbor-changes
 neighbor <VWAN-0-PeerAddress> remote-as 65515
 neighbor <VWAN-0-PeerAddress> ebgp-multihop 5
 neighbor <VWAN-0-PeerAddress> update-source GigabitEthernet1
 neighbor <VWAN-1-PeerAddress> remote-as 65515
 neighbor <VWAN-1-PeerAddress> ebgp-multihop 5
 neighbor <VWAN-1-PeerAddress> update-source GigabitEthernet1
!
ip route <VWAN-1-PeerAddress> 255.255.255.255 Tunnel0
ip route <VWAN-0-PeerAddress> 255.255.255.255 Tunnel1
!
end
!
wr mem

```