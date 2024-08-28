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
    -v|--volume)
        VOLUME="${2}"
        shift # past argument with no value
        ;;
    -p|--port)
        BASE_PORT="${2}"
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
         -k  (--kubeconfig)   <k8s config file>
         -v  (--volume)       <testsuite dir to mount>
         -p  (--port)         <base port for forwarding> 
          ]

    "
    exit 1
}

[ -z "$NAMESPACE" ] && help_and_exit
[ -z "$KUBECONFIG" ] && help_and_exit
[ -z "$VOLUME" ] && help_and_exit
[ -z "$BASE_PORT" ] && help_and_exit

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

function health_check () {
    ID=1
    while [[ $ID -lt 30 ]]; do
        echo "trying $ID ..."
        ANS=$(curl -o /dev/null -s -k -w "%{http_code}" "localhost:$PORT/actuator/health")
        [ "$ANS" != "000" ] && break
        sleep 1
        ID=$((ID + 1))
    done
}

# copy k8 config file to testsuite folder in order to be used also by docker kubectl
cp $KUBECONFIG $VOLUME
chmod 644 $VOLUME/config

chmod -R 777 $VOLUME/conftest/

# port-forward for notification service
PORT=

find_available $BASE_PORT

POD_NS=$(kubectl --kubeconfig $KUBECONFIG get pod -n $NAMESPACE | grep eric-oss-notification-service | grep -v database)
POD_NS_NAME=${POD_NS%% *}
echo $POD_NS_NAME

kubectl --kubeconfig $KUBECONFIG port-forward $POD_NS_NAME $PORT:8080 -n $NAMESPACE > /dev/null & 
PID_NS=$!
echo "Pid ns: " $PID_NS

echo "waiting for notification service health-check"
health_check
PORT_NS=$PORT
[ "$ID" == 30 ] && echo "health-check for notification service not successful after 30s - exiting" && kill -9 $PID_NS && exit 1

# port-forward for test client
PORT=

find_available $BASE_PORT

POD_TC=$(kubectl --kubeconfig $KUBECONFIG get pod -n $NAMESPACE | grep eric-ns-test-client)
POD_TC_NAME=${POD_TC%% *}
echo $POD_TC_NAME
DESCPOD=$(kubectl --kubeconfig $KUBECONFIG describe pod $POD_TC_NAME -n $NAMESPACE)
echo $DESCPOD

kubectl --kubeconfig $KUBECONFIG port-forward $POD_TC_NAME $PORT:3000 -n $NAMESPACE > /dev/null & 
PID_TC=$!
echo "Pid tc: " $PID_TC

echo "waiting for test client health-check"
health_check
PORT_TC=$PORT
[ "$ID" == 30 ] && echo "health-check for test client not successful after 30s - exiting" && kill -9 $PID_TC && exit 1

echo $DESCPOD

#run pytest-bdd testsuite
docker run --rm --network host --workdir /mnt --volume $VOLUME:/mnt armdocker.rnd.ericsson.se/sandbox/photon/py3bddkube:1.0 pytest . --url http://localhost:$PORT_NS --tc_url http://localhost:$PORT_TC --k8s_config /mnt/config --k8s_namespace $NAMESPACE --cucumber-json=conftest/conftest_output.json -p no:cacheprovider
TESTSUITE_RESULT=$?

kill -9 $PID_NS
kill -9 $PID_TC
ps -aef | grep port-forward 

ls -la nbitestsuite/
ls -la nbitestsuite/conftest/

if [ "$TESTSUITE_RESULT" -eq 0 ]
then
    exit 0
else
    exit 1
fi