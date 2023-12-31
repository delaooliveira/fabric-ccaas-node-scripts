#!/bin/bash

. envs.sh

PACKAGE_ID=$(cat pkgid-$CHAINCODE_NAME)
SEQUENCE=$(cat sequence-$CHANNEL_NAME)
((SEQUENCE=SEQUENCE+1))
echo -n $SEQUENCE > sequence-$CHANNEL_NAME

echo $PACKAGE_ID

FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=../ca/admin/msp peer lifecycle chaincode queryinstalled --output json --peerAddresses localhost:7051 --tlsRootCertFiles /opt/fabric/ca/ca-cert.pem
FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=../ca/admin/msp peer lifecycle chaincode install ccbuilder/${CHAINCODE_NAME}.tar.gz

sleep 1

FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=../ca/admin/msp peer lifecycle chaincode approveformyorg \
    -o localhost:7050 \
    --ordererTLSHostnameOverride localhost \
    --tls \
    --cafile /opt/fabric/ca/ca-cert.pem \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME} \
    --version $CHAINCODE_VERSION \
    --package-id "${PACKAGE_ID}" \
    --sequence $SEQUENCE \
    ${PRIVATE_DATA}

sleep 1

FABRIC_CFG_PATH=peer peer lifecycle chaincode checkcommitreadiness \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME} \
    --version $CHAINCODE_VERSION \
    --sequence $SEQUENCE \
    --output json \
    ${PRIVATE_DATA}

FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=../ca/admin/msp peer lifecycle chaincode commit \
    -o localhost:7050 \
    --ordererTLSHostnameOverride localhost \
    --tls \
    --cafile /opt/fabric/ca/ca-cert.pem \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME} \
    --version $CHAINCODE_VERSION \
    --sequence $SEQUENCE \
    ${PRIVATE_DATA}

FABRIC_CFG_PATH=peer peer lifecycle chaincode querycommitted \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME}
