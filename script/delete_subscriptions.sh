#!/bin/bash

function check_values() {
    while [[ $# -gt 0 ]]; do
        key="${1}"
        case ${key} in
            -u|--nsurl)
                ns_url="${2}"
                shift
                ;;
            *)    # unknown option
                shift # past argument
                ;;
        esac
    done
    [ -z "$ns_url" ] && help_and_exit
}

function help_and_exit() {
    echo "
usage:
    $0 
       [-u    (--nsurl )       <notification service url> ]

    "
    exit 1
}

function getSubscriptions() {
  RESPONSE_GET=$(curl -s -k --write-out "HTTPSTATUS:%{http_code}" -X GET "$ns_url/notification/v1/subscriptions" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{}")
  BODY_GET=$(echo $RESPONSE_GET | sed -e 's/HTTPSTATUS\:.*//g')
  STATUS_GET=$(echo $RESPONSE_GET | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  case $STATUS_GET in
      200)
          number_subscriptions=$(echo $BODY_GET | jq 'length')
          echo "Number of subscriptions found : $number_subscriptions "
          ;;
      *)
          echo "$HTTP_STATUS Get Subscriptions ERROR ...probably communication issue with service"
          exit 1
          ;;
  esac
}

function deleteSubscriptions() {
  for ((subscription=1;subscription<=$number_subscriptions;subscription++))
  do
    index=$((subscription-1))
    element=$(echo $BODY_GET | jq '.['$index'].id')
    subscription_to_delete=$(echo $element | tr -d '"')
    RESPONSE=$(curl -s -k -o /dev/null -w "%{http_code}" -X DELETE "$ns_url/notification/v1/subscriptions/$subscription_to_delete" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{}")
    case $RESPONSE in
           204)
               echo "$RESPONSE Subscription $subscription_to_delete deleted with success"
               ;;
           404)
               echo "$RESPONSE a subscription with provided id $subscription_to_delete is not found"
               error_count=$((error_count+1)) 
               ;;
           *)
               echo "$RESPONSE Subscription $subscription_to_delete request Error"
               error_count=$((error_count+1))
               ;;
        esac    
  done
}

function main() {
  check_values "$@"
  error_count=0
  
  getSubscriptions

  if [ "$number_subscriptions" -gt 0 ]
  then
     deleteSubscriptions
  else
     echo "No Subscriptions found to delete....."
  fi

  if [ "$error_count" -eq 0 ]
  then
     echo "Subscriptions delete completed with success"
     exit 0
  else 
     echo "Subscriptions delete completed with $error_count errors"
     exit 1
  fi 
  
}


main "$@"