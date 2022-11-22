# Simple webserver #1

cd to dir
make some html
sudo python -m SimpleHTTPServer 80
or
sudo python -n http.server 80

# Simple webserver #2
sudo apt update
sudo apt install -y python3-pip
pip3 install flask
wget https://raw.githubusercontent.com/erjosito/azcli/master/myip.py-O /root/myip.py
pyther3 /root/myip.py

# IP forwarding
https://www.networkinghowtos.com/howto/enable-ip-forwarding-on-ubuntu-13-04/

sudo sysctl -w net.ipv4.ip_forward=1
sysctl net.ipv4.ip_forward

# NAT / internet routing
Ubuntu 18.04 didn't work in last testing
https://medium.com/contino-engineering/azure-egress-nat-with-linux-vm-595f6abd2f77
https://github.com/fluffy-cakes/azure_egress_nat/blob/main/ubuntu_hub/routing.sh
https://www.microcloud.nl/azure-nat-with-ubuntu-linux/

# TCP dump

tcpdump -i eth1 port not 22 and host 1.2.3.4
sudo tcpdump not port 22 and not host 168.63.129.16
sudo tcpdump -nn 'port 80 and dst net 10.1.0.0/16 and src net 10.1.0.0/16'

# SQL connection
https://serverfault.com/questions/975149/how-do-i-test-connection-from-linux-to-microsoft-sql-server

sudo su
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list > /etc/apt/sources.list.d/mssql-release.list
exit
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install msodbcsql17 mssql-tools
# split here
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install unixodbc-dev

sqlcmd -S setspnswql.database.windows.net -U azadmin -p -Q "SELECT @@VERSION"



