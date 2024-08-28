#!/bin/bash

function check_values() {
    while [[ $# -gt 0 ]]; do
        key="${1}"
        case ${key} in
            -net|--numeventype)
                number_eventType="${2}"
                shift
                ;;
            -nsub|--numsub)
                number_subscriptions="${2}"
                shift
                ;;
            -u|--nsurl)
                ns_url="${2}"
                shift
                ;;
            *)    # unknown option
                shift # past argument
                ;;
        esac
    done
    [ -z "$number_eventType" ] && help_and_exit
    [ -z "$number_subscriptions" ] && help_and_exit
    [ -z "$ns_url" ] && help_and_exit
}

function help_and_exit() {
    echo "
usage:
    $0 
       [ -net  (--numeventype ) <number event types>  
         -nsub (--numsub )      <number subscriptions per event type> 
         -u    (--nsurl )       <notification service url> ]

    "
    exit 1
}


function main() {
  check_values "$@"
  error_count=0
  
  for ((testType=1;testType<=4;testType++)) 
  do
    for ((e=1;e<=$number_eventType;e++)) 
    do
      for ((s=1;s<=$number_subscriptions;s++))
      do
        case $testType in
           1) 
             echo "No Filter"
             sub_body="{\"subscriptionFilter\":[{\"eventType\":\"ServiceOrderCreateEvent_$e\",\"filterCriteria\":null,\"fields\":null}],\"address\":\"http://eric-ns-test-client:3000/client/$s\",\"tenant\":\"tenant_main\"}"
             ;;
           2) 
             echo "Filter"
             sub_body="{\"subscriptionFilter\":[{\"eventType\":\"FilterServiceOrderCreateEvent_$e\",\"filterCriteria\":\"data.units==psi_1\",\"fields\":null}],\"address\":\"http://eric-ns-test-client:3000/client/$s\",\"tenant\":\"tenant_main\"}"
             ;;
           3) 
            echo "Projection"
             sub_body="{\"subscriptionFilter\":[{\"eventType\":\"ProjectServiceOrderCreateEvent_$e\",\"filterCriteria\":null,\"fields\":\"id,data.value\"}],\"address\":\"http://eric-ns-test-client:3000/client/$s\",\"tenant\":\"tenant_main\"}"
             ;;
           4) 
             echo "Filter and Projection"
             sub_body="{\"subscriptionFilter\":[{\"eventType\":\"FilProjServiceOrderCreateEvent_$e\",\"filterCriteria\":\"data.units==psi_1\",\"fields\":\"id\"}],\"address\":\"http://eric-ns-test-client:3000/client/$s\",\"tenant\":\"tenant_main\"}"
             ;;
        esac
        RESPONSE=$(curl -s -k -o /dev/null -w "%{http_code}" -X POST "$ns_url/notification/v1/subscriptions" -H  "accept: application/json" -H  "Content-Type: application/json" -d $sub_body)
        case $RESPONSE in
           201)
               echo "$RESPONSE Subscription $s eventType $e created"
               ;;
           400)
               echo "$RESPONSE Subscription $s eventType $e request contains incorrect subscription info"
               error_count=$((error_count+1)) 
               ;;
           409)
               echo "$RESPONSE Subscription $s eventType $e a subscription with the same eventType and destination already exists"
               ;;
           501)
               echo "$RESPONSE Subscription $s eventType $e request Not Yet Implemented" 
               error_count=$((error_count+1))
               ;;
           *)
               echo "$RESPONSE Subscription $s eventType $e request Error"
               error_count=$((error_count+1))
               ;;
        esac    
      done
    done
  done
  if [ "$error_count" -eq 0 ]
  then
     echo "Subscriptions Creation completed with success"
     exit 0
  else 
     echo "Subscriptions Creation completed with $error_count errors"
     exit 1
  fi 
}


main "$@"