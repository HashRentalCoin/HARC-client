sudo apt -y update && sudo apt -y install build-essential libssl-dev libdb++-dev && sudo apt -y install libboost-all-dev libcrypto++-dev libqrencode-dev && sudo apt -y install libminiupnpc-dev libgmp-dev libgmp3-dev autoconf && sudo apt -y install autogen automake libtool autotools-dev pkg-config && sudo apt -y install bsdmainutils software-properties-common && sudo apt -y install libzmq3-dev libminiupnpc-dev libssl-dev libevent-dev && sudo add-apt-repository ppa:bitcoin/bitcoin -y && sudo apt-get update && sudo apt-get install libdb4.8-dev libdb4.8++-dev -y && sudo apt-get install unzip -y && sudo apt-get install nano git -y
chmod -R 755 /usr/local/bin/hashrentalcoind
chmod -R 755 /usr/local/bin/hashrentalcoin-cli
mkdir /root/.hashrentalcoincore
crontab -l > tempcron
echo "@reboot sleep 30 && /usr/local/bin/hashrentalcoind -daemon" >> tempcron
crontab tempcron
rm tempcron
chmod -R 755 /root/.hashrentalcoincore
sudo apt-get install -y pwgen
GEN_PASS=`pwgen -1 20 -n`
IP_ADD=`curl ipinfo.io/ip`
echo -e "rpcuser=hashrentalcoinrpc\nrpcpassword=${GEN_PASS}\nserver=1\nlisten=1\nmaxconnections=256\ndaemon=1\nrpcallowip=127.0.0.1\nexternalip=${IP_ADD}" > /root/.hashrentalcoincore/hashrentalcoin.conf
hashrentalcoind
sleep 10
masternodekey=$(hashrentalcoin-cli masternode genkey)
hashrentalcoin-cli stop
echo -e "masternode=1\nmasternodeprivkey=$masternodekey" >> /root/.hashrentalcoincore/hashrentalcoin.conf
echo "Your Masternode IP address: ${IP_ADD}:7883"
echo "Masternode private key: $masternodekey"
echo "Welcome to the hashrentalcoin!"
