#! /bin/bash

. envs.sh

PACKAGE_ID=$(cat pkgid-$CHAINCODE_NAME)
echo $PACKAGE_ID

cd ${CHAINCODE_PATH}; npm run build; CORE_CHAINCODE_LOGGING_LEVEL=INFO npx fabric-chaincode-node server \
    --chaincode-address=localhost:$CHAINCODE_PORT \
    --chaincode-id=$PACKAGE_ID \
    --chaincode-tls-cert-file=/opt/fabric/ca/peer/tls/signcerts/cert.pem \
    --chaincode-tls-key-file=/opt/fabric/ca/peer/tls/keystore/server.key
