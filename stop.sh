#! /bin/bash

kill $(ps -e | grep fabric-ca-server | grep -v grep | awk '{ print $1  }') 2> /dev/null
kill $(ps -e | grep couchdb | grep -v grep | awk '{ print $1  }') 2> /dev/null
kill $(ps -e | grep "peer node start" | grep -v grep | awk '{ print $1  }') 2> /dev/null
kill $(ps -e | grep "orderer start" | grep -v grep | awk '{ print $1  }') 2> /dev/null
