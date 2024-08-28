#!/bin/bash
export EXP_RES_FILE=./UnitTestExpectedResult.txt
export ACT_RES_FILE=./UnitTestActualResult.txt
if [ -f $EXP_RES_FILE ]; then
  echo "${EXP_RES_FILE} exists."
else
  echo "${EXP_RES_FILE} doesn't exist."
  exit
fi
export PORT=$1
if [ -z $PORT ]
then
  echo "Usage: ./executeUnitTest.sh <port>"
  exit
fi
/bin/rm -f $ACT_RES_FILE
./unitTest.sh $PORT | grep -e success -e last_notification > $ACT_RES_FILE
if cmp --silent "$EXP_RES_FILE" "$ACT_RES_FILE"; then
  echo "Unit Test Successful"
  /bin/rm -f $ACT_RES_FILE
else
  echo "Unit Test Failed"
fi
exit
