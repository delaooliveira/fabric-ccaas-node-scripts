# LOAD ENVS
. envs.sh

rm canal.block 2> /dev/null
configtxgen -profile Local -outputBlock canal.block -channelID $CHANNEL_NAME

osnadmin channel join --channelID $CHANNEL_NAME \
    --config-block /opt/fabric/canal.block -o localhost:9443 \
    --ca-file /opt/fabric/ca/ca-cert.pem \
    --client-cert /opt/fabric/ca/tls/server.crt \
    --client-key /opt/fabric/ca/tls/server.key

sleep 2

FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=/opt/fabric/ca/admin/msp peer channel join -b canal.block \
    --cafile /opt/fabric/ca/ca-cert.pem \
    --orderer localhost:7050 \
    --ordererTLSHostnameOverride localhost \
    --tls

sleep 2

FABRIC_CFG_PATH=peer peer channel fetch config config_block.pb \
    -o localhost:7050 \
    --ordererTLSHostnameOverride localhost \
    -c $CHANNEL_NAME --tls --cafile /opt/fabric/ca/ca-cert.pem \
    --clientauth --certfile /opt/fabric/ca/peer/tls/signcerts/cert.pem \
    --keyfile /opt/fabric/ca/peer/tls/keystore/server.key

configtxlator proto_decode --input config_block.pb --type common.Block --output config_block.json
jq .data.data[0].payload.data.config config_block.json > config.json
jq '.channel_group.groups.Application.groups.LocalMSP.values += {"AnchorPeers":{"mod_policy": "Admins","value":{"anchor_peers": [{"host": "localhost","port": 7051}]},"version": "0"}}' config.json > modified_config.json
configtxlator proto_encode --input config.json --type common.Config --output original_config.pb
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
configtxlator compute_update --channel_id $CHANNEL_NAME --original original_config.pb --updated modified_config.pb --output config_update.pb
configtxlator proto_decode --input config_update.pb --type common.ConfigUpdate --output config_update.json
echo '{"payload":{"header":{"channel_header":{"channel_id":"'${CHANNEL_NAME}'", "type":2}},"data":{"config_update":'$(cat config_update.json)'}}}' | jq . >config_update_in_envelope.json
configtxlator proto_encode --input config_update_in_envelope.json --type common.Envelope --output anchors.tx

FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=/opt/fabric/ca/admin/msp peer channel update -o localhost:7050 --ordererTLSHostnameOverride localhost \
    -c $CHANNEL_NAME -f anchors.tx --tls --cafile /opt/fabric/ca/ca-cert.pem \
    --clientauth --certfile /opt/fabric/ca/peer/tls/signcerts/cert.pem \
    --keyfile /opt/fabric/ca/peer/tls/keystore/server.key

rm anchors.tx config_block.json config_block.pb config_update_in_envelope.json config_update.json config_update.pb config.json modified_config.json modified_config.pb original_config.pb 