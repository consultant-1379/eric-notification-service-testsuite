#!/bin/bash
export PORT=$1
export CLIENT_ID=$2
if [ -z $PORT ]
then
  echo "Usage: ./test/singleMsgUnitTest.sh <port> <client>"
  exit
fi
if [ -z $CLIENT_ID ]
then
  echo "Usage: ./test/singleMsgUnitTest.sh <port> <client>"
  exit
fi
# Health
curl -X GET --header 'Content-Type: application/json' localhost:$PORT/health
# Reset client
curl -X POST --header 'Content-Type: application/json' localhost:$PORT/reset
# Post client
curl -X POST -d "{ 'SingleMsgTestKey' : 'SingleMsgTestValue' }" --header 'Content-Type: application/json' localhost:$PORT/client/$CLIENT_ID
# Check reset
curl -X GET --header 'Content-Type: application/json' localhost:$PORT/client/$CLIENT_ID
curl -X POST -d "{ 'SingleMsgTestKey' : 'SingleMsgTestValue' }" --header 'Content-Type: application/json' localhost:$PORT/test/$CLIENT_ID
