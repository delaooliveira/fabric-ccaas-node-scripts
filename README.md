# Hyperledger Fabric CCaaS node.js scripts
If you are using MacOS and doesn't like to run a VM to be able to use Docker and wants to boot a Hyperleder Fabric Network, you can use these scripts.

## Pre requisites
- Installed (via [Homebrew](https://brew.sh/index_pt-br) preferably)
    - couchdb
    - yq
    - jq
- Hyperledger Fabric binaries (fabric-ca-server, fabric-ca-client, orderer,peer, osnadmin, configtxgen, configtxlator) on PATH. [Link](https://hyperledger-fabric.readthedocs.io/en/latest/install.html).
- R/W permissions on `/opt/fabric`
- CouchDB with an user configured. (It is expected to be admin/adminpw. if you choose to use another one, you must change `peer/core.yaml` @ `.ledger.state.couchDBConfig.username` and `.ledger.state.couchDBConfig.password`)

## Setup:
- Clonar this repo at `/opt/fabric`. Just run `git clone git@github.com:delaooliveira/fabric-ccaas-node-scripts.git /opt/fabric --depth 1`
- Execute:
    - `fabric-ca-server start` from `/opt/fabric/ca`;
    - `./create-crypto-artefacts.sh` and check for any error messages;
    - Run the other binaries:
        - `couchdb`
        - `peer node start` from `/opt/fabric/peer`
        - `orderer start` from `/opt/fabric/orderer`
    - `./create-channel.sh` and check for any error messages;
    - `./package.sh`
    - `./install-cc.sh`
    - Run the chaincode as a service, either:
        - `./run-chaincode.sh` or;
        - You can create a script on `package.json`, such as:
            ```json
                "scripts": {
                    "debug": "fabric-chaincode-node server --chaincode-address=localhost:7100 --chaincode-id=$(cat /opt/fabric/pkgid) --chaincode-tls-cert-file=/opt/fabric/ca/peer/tls/signcerts/cert.pem --chaincode-tls-key-file=/opt/fabric/ca/peer/tls/keystore/server.key"
                }
            ```
            and then you can attach a debugger. Neat, right?

## 
Once the setup is complete you can boot all of the Fabric infra by running `./start.sh` and can halt them all with `./stop.sh`. The only exception is the Chaincode itself, you must use one of the options given on Setup.


## Contributing
If you are interested in contributing updates to these scripts, feel free to create a Pull Request.

### Tested On
- MacOS Ventura 13.4.1 (c)
- peer/orderer/configtxgen/configtxlator version 2.5.3
- fabric-ca-server/fabric-ca-client 1.5.6
