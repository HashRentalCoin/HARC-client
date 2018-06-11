# Check if is root
if [ "$(whoami)" != "root" ]; then
  echo "Script must be run as user: root"
  exit -1
fi

# Check for systemd
systemctl --version >/dev/null 2>&1 || { echo "systemd is required. Are you using Ubuntu 16.04 (Xenial)?"  >&2; exit 1; }

# Gather input from user
KEY=$1
if [ "$KEY" == "" ]; then
    echo "Enter your Masternode Private Key"
    read -e -p "(e.g. 7edfjLCUzGczZi3JQw8GHp434R9kNY33eFyMGeKRymkB56G4324h) : " KEY
    if [[ "$KEY" == "" ]]; then
        echo "WARNING: No private key entered, exiting!!!"
        echo && exit
    fi
fi
IP=$(curl http://icanhazip.com --ipv4)
PORT="7883"
if [[ "$IP" == "" ]]; then
    read -e -p "VPS Server IP Address: " IP
fi
echo "Your IP and Port is $IP:$PORT"
if [ -z "$2" ]; then
echo && echo "Pressing ENTER will use the default value for the next prompts."
    echo && sleep 3
    read -e -p "Add swap space? (Recommended) [Y/n] : " add_swap
fi
if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
    if [ -z "$2" ]; then
        read -e -p "Swap Size [2G] : " swap_size
    fi
    if [[ "$swap_size" == "" ]]; then
        swap_size="2G"
    fi
fi
if [ -z "$2" ]; then
    read -e -p "Install Fail2ban? (Recommended) [Y/n] : " install_fail2ban
    read -e -p "Install UFW and configure ports? (Recommended) [Y/n] : " UFW
fi

# Add swap if needed
if [[ ("$add_swap" == "y" || "$add_swap" == "Y" || "$add_swap" == "") ]]; then
    if [ ! -f /swapfile ]; then
        echo && echo "Adding swap space..."
        sleep 3
        sudo fallocate -l $swap_size /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        sudo sysctl vm.swappiness=10
        sudo sysctl vm.vfs_cache_pressure=50
        echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
        echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
    else
        echo && echo "WARNING: Swap file detected, skipping add swap!"
        sleep 3
    fi
fi


# Update system 
echo && echo "Upgrading system..."
sleep 3
sudo apt-get -y update
sudo apt-get -y upgrade

# Install required packages
echo && echo "Installing base packages..."
sleep 3
sudo apt-get -y install \
unzip \
python-virtualenv
sudo apt -y update && sudo apt -y install build-essential libssl-dev libdb++-dev && sudo apt -y install libboost-all-dev libcrypto++-dev libqrencode-dev && sudo apt -y install libminiupnpc-dev libgmp-dev libgmp3-dev autoconf && sudo apt -y install autogen automake libtool autotools-dev pkg-config && sudo apt -y install bsdmainutils software-properties-common && sudo apt -y install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev && sudo add-apt-repository ppa:bitcoin/bitcoin -y && sudo apt-get update && sudo apt-get install libdb4.8-dev libdb4.8++-dev -y && sudo apt-get install unzip -y
sudo apt-get dist-upgrade -y
sudo apt-get install nano mc htop git ufw p7zip-full libtool autotools-dev automake pkg-config libevent-dev bsdmainutils software-properties-common -y 
sudo apt-get install libdb-dev autoconf-archive -y
sudo apt-get install libdb5.3++ libgmp3-dev libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev
sudo add-apt-repository ppa:bitcoin/bitcoin -y
sudo apt-get update -y
sudo apt-get install libdb4.8-dev libdb4.8++-dev -y

# Install fail2ban if needed
if [[ ("$install_fail2ban" == "y" || "$install_fail2ban" == "Y" || "$install_fail2ban" == "") ]]; then
    echo && echo "Installing fail2ban..."
    sleep 3
    sudo apt-get -y install fail2ban
    sudo service fail2ban restart 
fi

# Install firewall if needed
if [[ ("$UFW" == "y" || "$UFW" == "Y" || "$UFW" == "") ]]; then
    echo && echo "Installing UFW..."
    sleep 3
    sudo apt-get -y install ufw
    echo && echo "Configuring UFW..."
    sleep 3
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw allow ssh
    sudo ufw allow 10773/tcp
    sudo ufw allow 7883/tcp
    echo "y" | sudo ufw enable
    echo && echo "Firewall installed and enabled!"
fi

# Create config for hashrentalcoin
echo && echo "Putting The HashRentalCoin..."
sleep 3
sudo mkdir /root/.hashrentalcoin #jm

rpcuser=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
rpcpassword=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo touch /root/.hashrentalcoin/hashrentalcoin.conf
echo '
rpcuser='$rpcuser'
rpcpassword='$rpcpassword'
rpcallowip=127.0.0.1
listen=1
server=1
rpcport=10773
daemon=0 # required for systemd
logtimestamps=1
maxconnections=256
externalip='$IP:$PORT'
masternodeprivkey='$KEY'
masternode=1
' | sudo -E tee /root/.hashrentalcoin/hashrentalcoin.conf


#Download pre-compiled hashrentalcoin and run
mkdir hashrentalcoin 
mkdir hashrentalcoin/src
cd hashrentalcoin/src
#Select OS architecture
    if [ `getconf LONG_BIT` = "64" ]
        then
            wget https://github.com/HashRentalCoin/hashrentalcoin/releases/download/1/ubuntu_auto.zip
            unzip ubuntu_auto.zip
    else
        wget wget https://github.com/HashRentalCoin/hashrentalcoin/releases/download/1/ubuntu_auto.zip
        unzip unzip ubuntu_auto.zip
    fi
chmod +x hashrentalcoind
chmod +x hashrentalcoin-cli
chmod +x hashrentalcoin-tx

# Move binaries do lib folder
sudo mv hashrentalcoin-cli /usr/bin/hashrentalcoin-cli
sudo mv hashrentalcoin-tx /usr/bin/hashrentalcoin-tx
sudo mv hashrentalcoind /usr/bin/hashrentalcoind

#run daemon
hashrentalcoind -daemon -datadir=/root/.hashrentalcoin

TOTALBLOCKS=$(curl http://95.181.230.26:3001/api/getblockcount)

sleep 10

# Download and install sentinel
echo && echo "Installing Sentinel..."
sleep 3
cd
sudo apt-get -y install python3-pip
sudo pip3 install virtualenv
sudo git clone https://github.com/HashRentalCoin/sentinel /root/sentinel
cd /root/sentinel
virtualenv venv
. venv/bin/activate
pip install -r requirements.txt
export EDITOR=nano
(crontab -l -u root 2>/dev/null; echo '* * * * * cd /root/sentinel && ./venv/bin/python bin/sentinel.py >/dev/null 2>&1') | sudo crontab -u root -

# Create a cronjob for making sure hashrentalcoind runs after reboot
if ! crontab -l | grep "@reboot hashrentalcoind -daemon"; then
  (crontab -l ; echo "@reboot hashrentalcoind -daemon") | crontab -
fi

# cd to hashrentalcoin-cli for final, no real need to run cli with commands as service when you can just cd there
echo && echo "hashrentalcoin Masternode Setup Complete!"
echo && echo "Now we will wait until the node get full sync."

$COUNTER=0
sleep 10

while [ $COUNTER -lt $TOTALBLOCKS ]; do
    echo The current progress is $COUNTER/$TOTALBLOCKS
    let COUNTER=$(hashrentalcoin-cli getblockcount)
    sleep 5
done
echo "Sync complete"
if [ -n "$2" ]; then
    echo "Saving IP"
fi
