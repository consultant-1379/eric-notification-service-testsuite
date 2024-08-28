
Create Subscriptions
--------------------
usage:
    ./create_subscriptions.sh 
       [ -net  (--numeventype ) <number event types>  
         -nsub (--numsub )      <number subscriptions per event type> 
         -u    (--nsurl )       <notification service url> ]

The script will create "nsub" subscriptions for each of "net" event type specified using the notfication
service specified in the "u" url without filter and projection applied.
Then it will create the same number of subscriptions with a filter applied.
Then it will create the same number of subscriptions with a projection applied.
Then it will create the same number of subscriptions with a filter and a projection applied.


Example : ./create_subscriptions.sh -net 10 -nsub 4 -u localhost:8080
The eventType created is "ServiceOrderCreateEvent_$e" ($e from 1 to "net") in case without Filter and Projection
The eventType created is "FilterServiceOrderCreateEvent_$e" ($e from 1 to "net") in case of Filter
The eventType created is "ProjectServiceOrderCreateEvent_$e" ($e from 1 to "net") in case of Projection
The eventType created is "FilProjServiceOrderCreateEvent_$e" ($e from 1 to "net") in case of Filter and Projection
The address of each client subscription is http://eric-ns-test-client:3000/client/$s ($s from 1 to "nsub")

___________________________________________________________________________________________________

Test Driver
-----------
usage:
    ./test_driver.sh 
       [ -net  (--numeventype ) <number event types>  
         -ne   (--numevent )    <number events per event type>  
         -nsub (--numsub )      <number subscriptions per event type> 
         -t    (--topic )       <kafka topic> 
         -n    (--namespace )   <namespace> 
         -u    (--testurl )     <test client url> ]

The script will generate a queue of Events to Kafka bus according "net" event types , "ne" number event for event type
and "nsub" subscriptions.
Then it will verify that all the notifications for each event produced have been dispatched to each client subscribed.

The procedure is executed four times :
The first time for No Filter and Projection case.
The second time for Filter case.
The third time for Projection case.
The fourth time for Filter and Projection case.

Example : ./test_driver.sh -net 2 -ne 5 -nsub 4 -t event -n <namespace> -u localhost:9999

_____________________________________________________________________________________________________

Delete Subscriptions
--------------------
usage:
    ./delete_subscriptions.sh 
       [-u    (--nsurl )       <notification service url> ]

The script will perform the following actions for the Notification Service specified in the "u" url :
1. Get of all subscriptions stored in the database returning the numbers and the UUID of each one 
2. In case at least one subscription is got, it will performed the deletion of all those subscriptions one by one
(returning the UUID of each one)
