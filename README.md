# HARC-client
Daemon V 1.0.2 >>> Linux Ubuntu 16.04 , 64 bit

# MN-setup

```
git clone https://github.com/HashRentalCoin/HARC-client.git

cd HARC-client

strip hashrentalcoind

cp hashrentalcoind /usr/local/bin

strip hashrentalcoin-cli

cp hashrentalcoin-cli /usr/local/bin

cd /usr/local/bin

chmod -R 755 hashrentalcoind

chmod -R 755 hashrentalcoin-cli
```

cd

```
cd HARC-client

chmod -R 755 install.sh

./install.sh
```

cd

```
cd .hashrentalcoincore
```
************
```
sudo nano hashrentalcoin.conf
```
replace with your genkey masternodeprivkey = 

Ctrl+o 

Ctrl+x

************

```
hashrentalcoind -daemon -reindex
```
tests

```
hashrentalcoin-cli getinfo

hashrentalcoin-cli mnsync status
```
wait 5 minutes (the client is synchronized)
correct answer

{
  "AssetID": 999,
  "AssetName": "MASTERNODE_SYNC_FINISHED",
  "AssetStartTime": 1528585631,
  "Attempt": 0,
  "IsBlockchainSynced": true,
  "IsMasternodeListSynced": true,
  "IsWinnersListSynced": true,
  "IsSynced": true,
  "IsFailed": false
}

*****
in the desktop wallet, run the masternode
*****
```
hashrentalcoin-cli masternode start
```
