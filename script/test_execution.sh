#!/usr/bin/env bash

while [[ $# -gt 0 ]]
do
key="${1}"

case ${key} in
    -n|--namespace)
        NAMESPACE="${2}"
        shift # past argument with no value
        ;;
    -k|--kubeconfig)
        KUBECONFIG="${2}"
        shift # past argument with no value
        ;;
    -p|--port)
        BASE_PORT="${2}"
        shift # past argument with no value
        ;;
    -s|--service-port)
        SVC_PORT="${2}"
        shift # past argument with no value
        ;;
    -f|--filter)
        FILTER="${2}"
        shift # past argument with no value
        ;;
    -t|--test)
        TEST="${2}"
        shift # past argument with no value
        ;;
    *)    # unknown option
        shift # past argument
        ;;
  esac
done

function help_and_exit() {
    echo "
usage:
    $0 
       [ -n  (--namespace)    <namespace>  
         -p  (--port)         <base port> 
         -s  (--service-port) <service port> 
         -f  (--filter)       <filter name>
         -t  (--test)         <test-type> ]

    "
    exit 1
}

[ -z "$NAMESPACE" ] && help_and_exit
[ -z "$BASE_PORT" ] && help_and_exit
[ -z "$SVC_PORT" ] && help_and_exit
[ -z "$FILTER" ] && help_and_exit

function find_available () {
    port=$1
    isfree=$(netstat -taln | grep $port)
    max=10
    i=1

    while [[ -n "$isfree" ]]; do
        [[ $i -gt $max ]] && echo "Not found available ports for forwarding" && exit 1
        port=$[port+1]
        isfree=$(netstat -taln | grep $port)
        i=$[i+1]
    done

    echo "Port-forwarding on $port"
    PORT=$port
    echo "Port" ${PORT}
}

# globals
PORT=

find_available $BASE_PORT

POD=$(kubectl get pod -n $NAMESPACE | grep $FILTER | grep -v database)
POD_NAME=${POD%% *}
echo $POD_NAME

# port-forward in background taking note of the PID
kubectl port-forward $POD_NAME $PORT:$SVC_PORT -n $NAMESPACE > /dev/null & 
PID=$!
echo "Pid: " $PID

echo "waiting for port-forwarding"
ID=1
while [[ $ID -lt 30 ]]; do
    echo "trying $ID ..."
    ANS=$(curl -o /dev/null -s -k -w "%{http_code}" "localhost:$PORT/actuator/health")
    [ "$ANS" != "000" ] && break
    sleep 1
    ID=$((ID + 1))
done
[ "$ID" == 30 ] && echo "port-forward not successful after 30s - exiting" && exit 1

if [ "$TEST" == "subscriptions" ]
then    
    ./script/create_subscriptions.sh -net 3 -nsub 5 -u "localhost:$PORT"
elif [ "$TEST" == "delsubscriptions" ]
then
    ./script/delete_subscriptions.sh -u "localhost:$PORT"
else
    ./script/test_driver.sh -net 3 -ne 5 -nsub 5 -t event -n $NAMESPACE -u "localhost:$PORT"
fi
SCRIPT_RESULT=$?
kill -9 $PID
ps -aef | grep port-forward
if [ "$SCRIPT_RESULT" -eq 0 ]
then
    exit 0
else
    exit 1
fi
