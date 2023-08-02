#! /bin/bash

. envs.sh
. ./stop.sh

couchdb &
PID=$!
sleep 5

for seq in sequence-*; do
    CHANNEL=$(basename "$seq" | sed 's/^sequence-//')
    echo $CHANNEL
    FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=/opt/fabric/ca/admin/msp peer node unjoin -c $CHANNEL
done

kill -9 $PID

rm -rf /opt/fabric/ca/{*.pem,Issuer*,fabric-ca-server.db,msp,tls}
rm -rf /opt/fabric/ca/{admin,orderer,peer,client,orgadmin}
rm -rf /opt/fabric/peer/{data,snapshots}
rm -rf /opt/fabric/orderer/{blocks,etcdraft}
rm -rf /opt/fabric/ccbuilder/{*.tar.gz,data}
rm -rf /opt/fabric/{canal.block,pkgid*,sequence*}

echo "TEARDOWN COMPLETE"