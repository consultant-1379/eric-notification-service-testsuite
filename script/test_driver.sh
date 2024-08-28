#!/bin/bash

function check_values() {
    while [[ $# -gt 0 ]]; do
        key="${1}"
        case ${key} in
            -net|--numeventype)
                number_eventType="${2}"
                shift
                ;;
            -ne|--numevent)
                number_event_per_eventType="${2}"
                shift
                ;;
            -nsub|--numsub)
                number_subscriptions="${2}"
                shift
                ;;
            -t|--topic)
                topic="${2}"
                shift
                ;;
            -n|--namespace)
                namespace="${2}"
                shift
                ;;
            -u|--testurl)
                test_client_url="${2}"
                shift
                ;;
            *)    # unknown option
                shift # past argument
                ;;
        esac
    done
    [ -z "$number_eventType" ] && help_and_exit
    [ -z "$number_event_per_eventType" ] && help_and_exit
    [ -z "$number_subscriptions" ] && help_and_exit
    [ -z "$topic" ] && help_and_exit
    [ -z "$namespace" ] && help_and_exit
    [ -z "$test_client_url" ] && help_and_exit
}

function help_and_exit() {
    echo "
usage:
    $0 
       [ -net  (--numeventype ) <number event types>  
         -ne   (--numevent )    <number events per event type>  
         -nsub (--numsub )      <number subscriptions per event type> 
         -t    (--topic )       <kafka topic> 
         -n    (--namespace )   <namespace> 
         -u    (--testurl )     <test client url> ]

    "
    exit 1
}


function createEvent() {
  event_id=$((event_id+1))
  case $testType in
      1) #No filter No Projection
        eventStream={\"eventID\":\"$event_id\",\"eventTime\":\"2020-11-16T16:42:25-04:00\",\"eventType\":\"ServiceOrderCreateEvent_$eventType\",\"tenant\":\"tenant_main\",\"payLoad\":\"{\\"\"id\\"\":\\"\"device_$event\\"\",\\"\"timestamp\\"\":\\"\"2020-11-16T01:08:00Z\\"\",\\"\"data\\"\":{\\"\"type\\"\":\\"\"pressure_$event\\"\",\\"\"units\\"\":\\"\"psi_$event\\"\",\\"\"value\\"\":108.$event}}\"}
        ;;
      2) #Filter
        eventStream={\"eventID\":\"$event_id\",\"eventTime\":\"2020-11-16T16:42:25-04:00\",\"eventType\":\"FilterServiceOrderCreateEvent_$eventType\",\"tenant\":\"tenant_main\",\"payLoad\":\"{\\"\"id\\"\":\\"\"device_$event\\"\",\\"\"timestamp\\"\":\\"\"2020-11-16T01:08:00Z\\"\",\\"\"data\\"\":{\\"\"type\\"\":\\"\"pressure_$event\\"\",\\"\"units\\"\":\\"\"psi_$event\\"\",\\"\"value\\"\":108.$event}}\"}
        ;;
      3) #Projection
        eventStream={\"eventID\":\"$event_id\",\"eventTime\":\"2020-11-16T16:42:25-04:00\",\"eventType\":\"ProjectServiceOrderCreateEvent_$eventType\",\"tenant\":\"tenant_main\",\"payLoad\":\"{\\"\"id\\"\":\\"\"device_$event\\"\",\\"\"timestamp\\"\":\\"\"2020-11-16T01:08:00Z\\"\",\\"\"data\\"\":{\\"\"type\\"\":\\"\"pressure_$event\\"\",\\"\"units\\"\":\\"\"psi_$event\\"\",\\"\"value\\"\":108.99}}\"}
        ;;
      4) #Filter and Projection
        eventStream={\"eventID\":\"$event_id\",\"eventTime\":\"2020-11-16T16:42:25-04:00\",\"eventType\":\"FilProjServiceOrderCreateEvent_$eventType\",\"tenant\":\"tenant_main\",\"payLoad\":\"{\\"\"id\\"\":\\"\"device_$event\\"\",\\"\"timestamp\\"\":\\"\"2020-11-16T01:08:00Z\\"\",\\"\"data\\"\":{\\"\"type\\"\":\\"\"pressure_$event\\"\",\\"\"units\\"\":\\"\"psi_$event\\"\",\\"\"value\\"\":108.99}}\"}
        ;;
  esac
  
  kubectl exec eric-data-message-bus-kf-0 -n $namespace -- bash -c "echo '$eventStream' | kafka-console-producer --broker-list eric-data-message-bus-kf:9092 --topic $topic"
}



function notificationCheck() {
case $testType in
    1) #No filter No Projection
      eventPayload="{\"id\":\"device_$event\",\"timestamp\":\"2020-11-16T01:08:00Z\",\"data\":{\"type\":\"pressure_$event\",\"units\":\"psi_$event\",\"value\":108.$event}}"
      ;;
    2) #Filter
      eventPayload="{\"id\":\"device_1\",\"timestamp\":\"2020-11-16T01:08:00Z\",\"data\":{\"type\":\"pressure_1\",\"units\":\"psi_1\",\"value\":108.1}}"
      ;;
    3) #Projection
      eventPayload="{\"id\":\"device_$event\",\"data\":{\"value\":108.99}}"
      ;;
    4) #Filter and Projection
      eventPayload="{\"id\":\"device_1\"}"
      ;;
esac
echo $eventPayload
HTTP_RESPONSE=$(curl -s -k --write-out "HTTPSTATUS:%{http_code}" -X POST "$test_client_url/test/$client" -H  "accept: application/json" -H  "Content-Type: application/json" -d $eventPayload)
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo STATUS $HTTP_STATUS
echo BODY $HTTP_BODY 
  case $HTTP_STATUS in
      200)
          CHECK_SUCCESS=$(echo $HTTP_BODY | jq '.success')
          if [ "$CHECK_SUCCESS" == "true" ]
          then
              echo "eventType $eventType event $event client $client check success"
          else
              echo "eventType $eventType event $event client $client check failed"
              error_count=$((error_count+1))
          fi
          ;;
      *)
          echo "$HTTP_STATUS eventType $eventType event $event client $client ERROR on check..probably communication issue with test client"
          error_count=$((error_count+1))
          ;;
  esac
}

function testClientEmptyQueueCheck() {
HTTP_RESPONSE=$(curl -s -k --write-out "HTTPSTATUS:%{http_code}" -X POST "$test_client_url/test/$client" -H  "accept: application/json" -H  "Content-Type: application/json" -d "none")
HTTP_BODY=$(echo $HTTP_RESPONSE | sed -e 's/HTTPSTATUS\:.*//g')
HTTP_STATUS=$(echo $HTTP_RESPONSE | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
echo STATUS $HTTP_STATUS
echo BODY $HTTP_BODY 
  case $HTTP_STATUS in
      200)
          CHECK_SUCCESS=$(echo $HTTP_BODY | jq '.success')
          if [ "$CHECK_SUCCESS" == "true" ]
          then
              echo "client $client empty queue check success"
          else
              echo "client $client empty queue check failed"
              error_count=$((error_count+1))
          fi
          ;;
      *)
          echo "$HTTP_STATUS client $client empty queue ERROR on check..probably communication issue with test client"
          error_count=$((error_count+1))
          ;;
  esac
}

function testClientHealthCheck() {
  RESPONSE=$(curl -s -k -o /dev/null -w "%{http_code}" -X GET "$test_client_url/health")
    case $RESPONSE in
       200)
           echo "$RESPONSE testClient is healthy"
           ;;
       *)
           echo "$RESPONSE testClient is unealthy and/or doesn't respond !"
           exit 1
           ;;
    esac    
}

function testClientReset() {
  RESPONSE=$(curl -s -k -o /dev/null -w "%{http_code}" -X POST "$test_client_url/reset" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{}")
    case $RESPONSE in
       200)
           echo "$RESPONSE testClient reset with success"
           ;;
       *)
           echo "$RESPONSE testClient reset error ...test suite cannot continue!"
           exit 1
           ;;
    esac    
}


function main(){
  check_values "$@"
  error_count=0
  testClientHealthCheck
  
  event_id=0
  for ((testType=1;testType<=4;testType++))
  do
    case $testType in
       1) echo -e "\nNo Filter No Projection Case....."
          ;;
       2) echo -e "\nFilter Case....."
          ;;
       3) echo -e "\nProjection Case....."
          ;;
       4) echo -e "\nFilter and Projection Case....."
          ;;
    esac
    testClientReset
    #Create Event Streams Queue
    echo -e "\nSending Events Queue to Kafka......."
    for ((eventType=1;eventType<=$number_eventType;eventType++))
    do
      for ((event=1;event<=$number_event_per_eventType;event++))
      do
        createEvent
      done
    done

    #Notification Queue Check
    if [ "$testType" -eq 1 ] || [ "$testType" -eq 3 ]
    then
        echo -e "\nChecking Queue Notifications Dispatched by Notification Service to clients......"
        for ((eventType=1;eventType<=$number_eventType;eventType++))
        do
          for ((event=1;event<=$number_event_per_eventType;event++))
          do
            for ((client=1;client<=$number_subscriptions;client++))
            do
              notificationCheck
            done
          done
        done
    else
        echo -e "\nChecking Queue Notifications Dispatched by Notification Service to clients......"
        for ((eventType=1;eventType<=$number_eventType;eventType++))
        do
          for ((client=1;client<=$number_subscriptions;client++))
          do
            event=1
            notificationCheck
          done
        done
    fi
  done
  
  #Notification Queue Empty Check at the end
  for ((client=1;client<=$number_subscriptions;client++))
  do
    testClientEmptyQueueCheck
  done
  
  #Final Report
  if [ "$error_count" -eq 0 ]
  then
     echo Test Suite Completed with success
     exit 0
  else 
     echo Test Suite Completed with $error_count errors
     exit 1
  fi 
}

main "$@"