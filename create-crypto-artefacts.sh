#!/bin/bash

ROOT_CA=/opt/fabric/ca/ca-cert.pem
HOSTNAME=$(hostname)

mkdir ca/{admin,peer,orderer,client,orgadmin,tls}

FABRIC_CA_CLIENT_HOME=/opt/fabric/ca/admin
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname LocalCA --tls.certfiles /opt/fabric/ca/tls-cert.pem

# ################################ REGISTER
fabric-ca-client register --caname LocalCA --id.name peer --id.secret peerpw --id.type peer --tls.certfiles $ROOT_CA
fabric-ca-client register --caname LocalCA --id.name user --id.secret userpw --id.type client --tls.certfiles $ROOT_CA
fabric-ca-client register --caname LocalCA --id.name orgadmin --id.secret orgadminpw --id.type admin --tls.certfiles $ROOT_CA
fabric-ca-client register --caname LocalCA --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles $ROOT_CA

################################ ENROLL
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/admin/msp \
    --tls.certfiles $ROOT_CA
# TLS
fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/admin/tls \
    --enrollment.profile tls --csr.hosts $HOSTNAME --csr.hosts localhost \
    --tls.certfiles $ROOT_CA

fabric-ca-client enroll -u https://peer:peerpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/peer/msp \
    --tls.certfiles $ROOT_CA
# TLS
fabric-ca-client enroll -u https://peer:peerpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/peer/tls \
    --enrollment.profile tls --csr.hosts $HOSTNAME --csr.hosts localhost \
    --tls.certfiles $ROOT_CA

fabric-ca-client enroll -u https://user:userpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/client/msp \
    --tls.certfiles $ROOT_CA
# TLS
fabric-ca-client enroll -u https://user:userpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/client/tls \
    --enrollment.profile tls --csr.hosts $HOSTNAME --csr.hosts localhost \
    --tls.certfiles $ROOT_CA

fabric-ca-client enroll -u https://orgadmin:orgadminpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/orgadmin/msp \
    --tls.certfiles $ROOT_CA
# TLS
fabric-ca-client enroll -u https://orgadmin:orgadminpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/orgadmin/tls \
    --enrollment.profile tls --csr.hosts $HOSTNAME --csr.hosts localhost \
    --tls.certfiles $ROOT_CA

fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7054 --caname LocalCA \
    -M /opt/fabric/ca/orderer/msp \
    --tls.certfiles $ROOT_CA
# TLS
fabric-ca-client enroll -u https://orderer:ordererpw@localhost:7054 --caname LocalCA \
-M /opt/fabric/ca/orderer/tls \
--enrollment.profile tls --csr.hosts $HOSTNAME --csr.hosts localhost \
--tls.certfiles $ROOT_CA


echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-LocalCA.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-LocalCA.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-LocalCA.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-LocalCA.pem
    OrganizationalUnitIdentifier: orderer' > /opt/fabric/ca/admin/msp/config.yaml

############################### COPYING STUFF
mkdir -p /opt/fabric/ca/{admin,peer,client,orgadmin,orderer}/msp/tlscacerts
cp $ROOT_CA /opt/fabric/ca/admin/msp/tlscacerts/ 
cp $ROOT_CA /opt/fabric/ca/peer/msp/tlscacerts/ 
cp $ROOT_CA /opt/fabric/ca/client/msp/tlscacerts/ 
cp $ROOT_CA /opt/fabric/ca/orgadmin/msp/tlscacerts/ 
cp $ROOT_CA /opt/fabric/ca/orderer/msp/tlscacerts/ 

cp /opt/fabric/ca/admin/msp/config.yaml /opt/fabric/ca/peer/msp/
cp /opt/fabric/ca/admin/msp/config.yaml /opt/fabric/ca/client/msp/
cp /opt/fabric/ca/admin/msp/config.yaml /opt/fabric/ca/orgadmin/msp/
cp /opt/fabric/ca/admin/msp/config.yaml /opt/fabric/ca/orderer/msp/

cp /opt/fabric/ca/orderer/tls/tlscacerts/* /opt/fabric/ca/tls/ca.crt
cp /opt/fabric/ca/orderer/tls/signcerts/* /opt/fabric/ca/tls/server.crt
cp /opt/fabric/ca/orderer/tls/keystore/* /opt/fabric/ca/tls/server.key

mv /opt/fabric/ca/admin/msp/keystore/* /opt/fabric/ca/admin/msp/keystore/server.key
mv /opt/fabric/ca/client/msp/keystore/* /opt/fabric/ca/client/msp/keystore/server.key
mv /opt/fabric/ca/client/tls/keystore/* /opt/fabric/ca/client/tls/keystore/server.key
mv /opt/fabric/ca/orderer/msp/keystore/* /opt/fabric/ca/orderer/msp/keystore/server.key
mv /opt/fabric/ca/orderer/tls/keystore/* /opt/fabric/ca/orderer/tls/keystore/server.key
mv /opt/fabric/ca/orgadmin/msp/keystore/* /opt/fabric/ca/orgadmin/msp/keystore/server.key
mv /opt/fabric/ca/orgadmin/tls/keystore/* /opt/fabric/ca/orgadmin/tls/keystore/server.key
mv /opt/fabric/ca/peer/msp/keystore/* /opt/fabric/ca/peer/msp/keystore/server.key
mv /opt/fabric/ca/peer/tls/keystore/* /opt/fabric/ca/peer/tls/keystore/server.key
