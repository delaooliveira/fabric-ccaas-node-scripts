#!/bin/bash

. envs.sh

PACKAGE_ID=$(cat pkgid)
SEQUENCE=$(cat sequence)
((SEQUENCE=SEQUENCE+1))
echo -n $SEQUENCE > sequence

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
    ${DADOS_PRIVADOS}

sleep 1

FABRIC_CFG_PATH=peer peer lifecycle chaincode checkcommitreadiness \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME} \
    --version $CHAINCODE_VERSION \
    --sequence $SEQUENCE \
    --output json \
    ${DADOS_PRIVADOS}

FABRIC_CFG_PATH=peer CORE_PEER_MSPCONFIGPATH=../ca/admin/msp peer lifecycle chaincode commit \
    -o localhost:7050 \
    --ordererTLSHostnameOverride localhost \
    --tls \
    --cafile /opt/fabric/ca/ca-cert.pem \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME} \
    --version $CHAINCODE_VERSION \
    --sequence $SEQUENCE \
    ${DADOS_PRIVADOS}

FABRIC_CFG_PATH=peer peer lifecycle chaincode querycommitted \
    --channelID ${CHANNEL_NAME} \
    --name ${CHAINCODE_NAME}
