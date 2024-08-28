import requests
import logging
import json
import subprocess
import uuid
from base64 import b64encode
from os import urandom
from ..constants import keys
from pytest_bdd import scenario, given, when, then

LOG = logging.getLogger(__name__)


@scenario("dispatch_notifications.feature", "Dispatch NoFilter OK",
          example_converters=dict(net=int, ne=int, nsub=int, t=str, total=int)
)
def test_dispatch_notifications_NoFilter_ok():
    pass

@given("Test Client is healthy")
def Client_Health_Check(ns_server_params):
    healthCheck = Tc_Health_Check(ns_server_params)
    assert healthCheck.status_code == 200

@given("Test Client is reset")
def Client_Reset(ns_server_params):
    reset = Tc_Reset(ns_server_params)
    assert reset.status_code == 200
    
@given("events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with No Filter and No Projection and <t> Kafka Topic")
def create_Event_NoFilter(ns_server_params, net, ne, t):
    LOG.info("**Create Events with No Filter**")
    for eventType in range(net):
        for event in range(ne):
            eventStream = json.dumps({
	        "eventID": "{}".format(uuid.uuid4()),
	        "eventTime": "2020-11-16T16:42:25-04:00",
	        "eventType": "ServiceOrderCreateEvent_{}".format(eventType+1),
	        "tenant": "tenant_main",
	        "payLoad": json.dumps({
		        "id": "device_{}".format(event+1),
		        "timestamp": "2020-11-16T01:08:00Z",
		        "data": {
			        "type": "pressure_{}".format(event+1),
			        "units": "psi_{}".format(event+1),
			        "value": "108.{}".format(event+1)
		        }
	          })
            })
            create_Event(ns_server_params, eventStream, t)
    return True

@then("we expect <total> Notifications with No Filter and No Projection are dispatched to clients subscribed")
def check_Notification_NoFilter(ns_server_params, net, ne, nsub, total):
    valid_responses = 0
    for eventType in range(net):
        for event in range(ne):
            for client in range(nsub):
                eventPayload = json.dumps({
		        "id": "device_{}".format(event+1),
		        "timestamp": "2020-11-16T01:08:00Z",
		        "data": {
			        "type": "pressure_{}".format(event+1),
			        "units": "psi_{}".format(event+1),
			        "value": "108.{}".format(event+1)
		          }
	            })
                LOG.info("eventPayload to check : %s", eventPayload)
                projection = False
                response = check_Notification_Request(ns_server_params, client+1, projection, json.loads(eventPayload))
                data = json.loads(response.content)
                if ((response.status_code == 200) and (data["success"] == True)):
                    valid_responses += 1
    LOG.info("Dispatched Notifications with No Filter Expected : %s", total)
    LOG.info("Dispatched Notifications with No Filter Verified : %s", valid_responses)
    assert valid_responses == total
    
    
##########################################################

@scenario("dispatch_notifications.feature", "Dispatch Filter OK",
          example_converters=dict(net=int, ne=int, nsub=int, t=str, total=int)
)
def test_dispatch_notifications_Filter_ok():
    pass

    
@given("events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with Filter and <t> Kafka Topic")
def create_Event_Filter(ns_server_params, net, ne, t):
    LOG.info("**Create Events with Filter**")
    for eventType in range(net):
        for event in range(ne):
            eventStream = json.dumps({
	        "eventID": "{}".format(uuid.uuid4()),
	        "eventTime": "2020-11-16T16:42:25-04:00",
	        "eventType": "FilterServiceOrderCreateEvent_{}".format(eventType+1),
	        "tenant": "tenant_main",
	        "payLoad": json.dumps({
		        "id": "device_{}".format(event+1),
		        "timestamp": "2020-11-16T01:08:00Z",
		        "data": {
			        "type": "pressure_{}".format(event+1),
			        "units": "psi_{}".format(event+1),
			        "value": "108.{}".format(event+1)
		        }
	          })
            })
            create_Event(ns_server_params, eventStream, t)
    return True

@then("we expect <total> Notifications with Filter are dispatched to clients subscribed")
def check_Notification_Filter(ns_server_params, net, nsub, total):
    valid_responses = 0
    for eventType in range(net):
        for client in range(nsub):
            eventPayload = json.dumps({
		    "id": "device_1",
		    "timestamp": "2020-11-16T01:08:00Z",
		    "data": {
			    "type": "pressure_1",
			    "units": "psi_1",
			    "value": "108.1"
		        }
	        })
            LOG.info("eventPayload to check : %s", eventPayload)
            projection = False
            response = check_Notification_Request(ns_server_params, client+1, projection, json.loads(eventPayload))
            data = json.loads(response.content)
            if ((response.status_code == 200) and (data["success"] == True)):
                valid_responses += 1
    LOG.info("Dispatched Notifications with Filter Expected : %s", total)
    LOG.info("Dispatched Notifications with Filter Verified : %s", valid_responses)
    assert valid_responses == total
    
    
##########################################################

@scenario("dispatch_notifications.feature", "Dispatch Projection OK",
          example_converters=dict(net=int, ne=int, nsub=int, t=str, total=int)
)
def test_dispatch_notifications_Projection_ok():
    pass
    
@given("events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with Projection and <t> Kafka Topic")
def create_Event_Projection(ns_server_params, net, ne, t):
    LOG.info("**Create Events with Projection**")
    for eventType in range(net):
        for event in range(ne):
            eventStream = json.dumps({
	        "eventID": "{}".format(uuid.uuid4()),
	        "eventTime": "2020-11-16T16:42:25-04:00",
	        "eventType": "ProjectServiceOrderCreateEvent_{}".format(eventType+1),
	        "tenant": "tenant_main",
	        "payLoad": json.dumps({
		        "id": "device_{}".format(event+1),
		        "timestamp": "2020-11-16T01:08:00Z",
		        "data": {
			        "type": "pressure_{}".format(event+1),
			        "units": "psi_{}".format(event+1),
			        "value": "108.99"
		        }
	          })
            })
            create_Event(ns_server_params, eventStream, t)
    return True

@then("we expect <total> Notifications with Projection are dispatched to clients subscribed")
def check_Notification_Projection(ns_server_params, net, ne, nsub, total):
    valid_responses = 0
    for eventType in range(net):
        for event in range(ne):
            for client in range(nsub):
                eventPayload = json.dumps({
	            "id":"device_{}".format(event+1),
	            "data":{
		            "value":"108.99"
	                }
                })
                LOG.info("eventPayload to check : %s", eventPayload)
                eventPayload_mod = json.dumps(eventPayload).replace(" ","")
                projection = True
                response = check_Notification_Request(ns_server_params, client+1, projection, json.loads(eventPayload_mod))
                data = json.loads(response.content)
                if ((response.status_code == 200) and (data["success"] == True)):
                    valid_responses += 1
    LOG.info("Dispatched Notifications with Projection Expected : %s", total)
    LOG.info("Dispatched Notifications with Projection Verified : %s", valid_responses)
    assert valid_responses == total
    
    
##########################################################
@scenario("dispatch_notifications.feature", "Dispatch FilterProjection OK",
          example_converters=dict(net=int, ne=int, nsub=int, t=str, total=int)
)
def test_dispatch_notifications_FilterProjection_ok():
    pass

    
@given("events in Kafka are created according to number of eventType <net> , number of event per eventType <ne> , number of subscriptions for eventType <nsub> with Filter and Projection and <t> Kafka Topic")
def create_Event_FilterProjection(ns_server_params, net, ne, t):
    LOG.info("**Create Events with Filter and Projection**")
    for eventType in range(net):
        for event in range(ne):
            eventStream = json.dumps({
	        "eventID": "{}".format(uuid.uuid4()),
	        "eventTime": "2020-11-16T16:42:25-04:00",
	        "eventType": "FilProjServiceOrderCreateEvent_{}".format(eventType+1),
	        "tenant": "tenant_main",
	        "payLoad": json.dumps({
		        "id": "device_{}".format(event+1),
		        "timestamp": "2020-11-16T01:08:00Z",
		        "data": {
			        "type": "pressure_{}".format(event+1),
			        "units": "psi_{}".format(event+1),
			        "value": "108.99"
		        }
	          })
            })
            create_Event(ns_server_params, eventStream, t)
    return True

@then("we expect <total> Notifications with Filter and Projection are dispatched to clients subscribed")
def check_Notification_FilterProjection(ns_server_params, net, nsub, total):
    valid_responses = 0
    for eventType in range(net):
        for client in range(nsub):
            eventPayload = json.dumps({
		    "id":"device_1"})
            LOG.info("eventPayload to check : %s", eventPayload)
            eventPayload_mod = json.dumps(eventPayload).replace(" ","")
            projection = True
            response = check_Notification_Request(ns_server_params, client+1, projection, json.loads(eventPayload_mod))
            data = json.loads(response.content)
            if ((response.status_code == 200) and (data["success"] == True)):
                valid_responses += 1
    LOG.info("Dispatched Notifications with Filter and Projection Expected : %s", total)
    LOG.info("Dispatched Notifications with Filter and Projection Verified : %s", valid_responses)
    assert valid_responses == total
    
    
##########################################################




###########################################################
def Tc_Health_Check(ns_server_param):
    tc_url = "{}/health".format(ns_server_param[keys.TEST_CLIENT_URL])
    LOG.debug("Send healthCheck request to %s ", tc_url)
    response = requests.get(tc_url, headers=ns_server_param[keys.REQUEST_HEADERS], json='{}')
    LOG.debug("Send healthCheck request. response: %s", response.text.encode("utf8"))
    if (response.status_code == 200):
        LOG.info("response_status :%s", response.status_code)
    else:
        LOG.error("response_status :%s", response.status_code)
    return response
############################################################
def Tc_Reset(ns_server_param):
    tc_url = "{}/reset".format(ns_server_param[keys.TEST_CLIENT_URL])
    LOG.debug("Send reset request to %s ", tc_url)
    response = requests.post(tc_url, headers=ns_server_param[keys.REQUEST_HEADERS], json='{}')
    LOG.debug("Send reset request. response: %s", response.text.encode("utf8"))
    if (response.status_code == 200):
        LOG.info("response_status :%s", response.status_code)
    else:
        LOG.error("response_status :%s", response.status_code)
    return response

#########################################################################################
def create_Event(ns_server_param, Stream, topic):
    kafkaPortCheck = subprocess.check_output(["kubectl", "--kubeconfig", "{}".format(ns_server_param[keys.K8S_CONFIG]), "get", "svc", "eric-data-message-bus-kf", "-n", "{}".format(ns_server_param[keys.K8S_NAMESPACE])])
    if (str(kafkaPortCheck).find('9093') == -1):
        LOG.info("Creating Event....port 9092")
        subprocess.run(["kubectl", "--kubeconfig", "{}".format(ns_server_param[keys.K8S_CONFIG]), "exec", "eric-data-message-bus-kf-0", "-n", "{}".format(ns_server_param[keys.K8S_NAMESPACE]), "--", "bash", "-c", "echo '{}' | kafka-console-producer --broker-list eric-data-message-bus-kf:9092 --topic {}".format(Stream,topic)])
    else:
        LOG.info("Creating Event....port 9093")
        subprocess.run(["kubectl", "--kubeconfig", "{}".format(ns_server_param[keys.K8S_CONFIG]), "exec", "eric-data-message-bus-kf-0", "-n", "{}".format(ns_server_param[keys.K8S_NAMESPACE]), "--", "bash", "-c", "echo '{}' | kafka-console-producer --broker-list eric-data-message-bus-kf:9093 --producer.config /etc/kafka/readiness.properties --topic {}".format(Stream,topic)])

#########################################################################################
def check_Notification_Request(ns_server_param, client, projection, eventPayload):
    tc_url = "{}/test/{}".format(ns_server_param[keys.TEST_CLIENT_URL],client)
    LOG.debug("Send check request to %s. Payload: %s", tc_url, eventPayload)
    if (projection == True):
        response = requests.post(tc_url, headers=ns_server_param[keys.REQUEST_HEADERS], data=eventPayload)
    else:
        response = requests.post(tc_url, headers=ns_server_param[keys.REQUEST_HEADERS], json=eventPayload)    
    LOG.debug("Send check request. response: %s", response.text.encode("utf8"))
    data = json.loads(response.content)
    if ((response.status_code == 200) and (data["success"] == True)):
        LOG.info("response_status :%s response body :%s", response.status_code, response.json())
    else:
        LOG.error("response_status :%s response body :%s", response.status_code, response.json())
    return response