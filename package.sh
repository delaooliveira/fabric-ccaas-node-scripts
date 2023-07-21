#!/bin/bash

. envs.sh

tempdir="ccbuilder/data"
rm -Rf "$tempdir"
mkdir ccbuilder/data 2>/dev/null


mkdir -p "$tempdir/src"
CERT=$(perl -p -e 's/\n/\\n/' /opt/fabric/ca/ca-cert.pem )
cat > "$tempdir/src/connection.json" <<CONN_EOF
{
  "address": "localhost:7100",
  "domain": "localhost",
  "dial_timeout": "10s",
  "tls_required": true,
  "client_auth_required": false,
  "root_cert": "$CERT"
}
CONN_EOF


mkdir -p "$tempdir/pkg"
cat << METADATA-EOF > "$tempdir/pkg/metadata.json"
{
    "type": "ccaas",
    "label": "${CHAINCODE_NAME}_${CHAINCODE_VERSION}"
}
METADATA-EOF

cp /opt/fabric/ca/ca-cert.pem $tempdir/src
cp -r $CHAINCODE_PATH/META-INF $tempdir/src
tar -C "$tempdir/src" -czf "$tempdir/pkg/code.tar.gz" .
tar -C "$tempdir/pkg" -czf "ccbuilder/${CHAINCODE_NAME}.tar.gz" metadata.json code.tar.gz
# rm -Rf "$tempdir"

PACKAGE_ID=$(FABRIC_CFG_PATH=peer peer lifecycle chaincode calculatepackageid ccbuilder/${CHAINCODE_NAME}.tar.gz)
echo -n $PACKAGE_ID > pkgid

echo -n $PACKAGE_ID
