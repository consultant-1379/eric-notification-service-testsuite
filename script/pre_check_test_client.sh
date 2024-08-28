#!/usr/bin/env bash

while [[ $# -gt 0 ]]
do
key="${1}"

case ${key} in
    -n|--namespace)
        NAMESPACE="${2}"
        shift # past argument with no value
        ;;
    -c|--chart)
        CHART="${2}"
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
         -c  (--chart)        <chart to check>
          ]

    "
    exit 1
}

[ -z "$NAMESPACE" ] && help_and_exit
[ -z "$CHART" ] && help_and_exit


kubectl get pods -n $NAMESPACE | grep $CHART
RESULT=$?

if [ "$RESULT" -eq 0 ]
then
    echo "test-client found..to be removed first !"
    helm delete $CHART -n $NAMESPACE
else
    echo "test-client not found..."
fi

exit 0