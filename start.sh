#! /bin/bash

cd orderer; orderer start &
couchdb &
cd ../ca; fabric-ca-server start &
sleep 5
cd ../peer; peer node start &
