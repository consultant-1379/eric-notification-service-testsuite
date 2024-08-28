#!/bin/bash
#
#
# Check that PORT was entered
#
#
export PORT=$1
if [ -z $PORT ]
then
  echo "Usage: ./test/ClientUnitTest.sh <port>"
  exit
fi
#
#
# Check Health
#
#
curl -X GET --header 'Content-Type: application/json' localhost:$PORT/health
#
#
# Reset all queues
#
#
curl -X POST --header 'Content-Type: application/json' localhost:$PORT/reset
#
#
# POST /client/x, first time (just one message per queue, only to test reset)
#
#
for i in {1..10}
do
# Test one endpoint out of 5, for 50 endpoints: 5 10 ... 45 50
let "k = $i*5"
curl -X POST -d "{ 'Key${k}1' : 'Msg${k}1' }" --header 'Content-Type: application/json' localhost:$PORT/client/$k
done
#
#
# Test /reset POST endpoint (and test "none" string handling by test client)
#
#
# Reset client, second time
curl -X POST --header 'Content-Type: application/json' localhost:$PORT/reset
# Check reset
for i in {1..10}
do
let "k = $i*5"
curl -X POST -d "none" --header 'Content-Type: application/json' localhost:$PORT/test/$k
done
#
#
# Test client/x POST endpoints (one out of five)
#
#
for i in {1..10}
do
let "k = $i*5"
for j in {1..4}
do
curl -X POST -d "{ 'Key${k}${j}' : 'Msg${k}${j}' }" --header 'Content-Type: application/json' localhost:$PORT/client/$k
done
done
#
#
# Test client/x GET endpoints (one out of five)
#
#
for i in {1..10}
do
let "k = $i*5"
curl -X GET --header 'Content-Type: application/json' localhost:$PORT/client/$k
done
#
#
# Test test/x POST endpoints (one out of five), in reverse order
#
#
for i in {10..1}
do
let "k = $i*5"
for j in {1..4}
do
curl -X POST -d "{ 'Key${k}${j}' : 'Msg${k}${j}' }" --header 'Content-Type: application/json' localhost:$PORT/test/$k
done
done
#
# Check that all the queues have been correctly emptied
#
for i in {1..10}
do
curl -X POST -d "none" --header 'Content-Type: application/json' localhost:$PORT/test/$i
done
#
#
# Test "none" string (passed in expected_message) handling by test client
#
#
# Fill queues again (again, use one out of 5 /client/x endpoints)
for i in {1..10}
do
let "k = $i*5"
for j in {1..4}
do
curl -X POST -d "{ 'Key${k}${j}' : 'Msg${k}${j}' }" --header 'Content-Type: application/json' localhost:$PORT/client/$k
done
done
# Empty queues, check that you get 4 messages on each, don't check the contents
for i in {1..10}
do
let "k = $i*5"
for j in {1..4}
do
curl -X POST -d "any" --header 'Content-Type: application/json' localhost:$PORT/test/$k
done
done
# Check that all the queues have been correctly emptied
for i in {1..10}
do
let "k = $i*5"
curl -X POST -d "none" --header 'Content-Type: application/json' localhost:$PORT/test/$k
done