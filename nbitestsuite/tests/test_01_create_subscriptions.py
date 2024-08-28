import requests
import logging
import json
from base64 import b64encode
from os import urandom
from ..constants import keys
from pytest_bdd import scenario, given, when, then

LOG = logging.getLogger(__name__)


@scenario("create_subscriptions.feature", "Subscription NoFilter OK",
          example_converters=dict(net=int, nsub=int, total=int)
)
def test_create_subscriptions_NoFilter_ok():
    pass


@given("number of eventType <net> and number of subscriptions for eventType <nsub> with No Filter and No Projection", target_fixture="creation_response")
def create_subscriptions_NoFilter(ns_server_params, net, nsub):
    valid_responses = 0
    for e in range(net):
        for s in range(nsub):
            subscription = json.dumps({
	        'address': "http://eric-ns-test-client:3000/client/{}".format(s+1),
	        'subscriptionFilter': [{
		        'eventType': "ServiceOrderCreateEvent_{}".format(e+1)
	        }],
	        'tenant': "tenant_main"
            })
            response = send_creation_request(ns_server_params, json.loads(subscription))            
            if ((response.status_code == 201) or (response.status_code == 409)):
                valid_responses += 1
    return valid_responses
    

@then("we expect <total> subscriptions NoFilter created with response 201 or 409")
def check_total_subscription_NoFilter(creation_response, total):
    LOG.info("Expected Subscriptions : %s", total)
    LOG.info("Created Subscriptions : %s", creation_response)
    assert creation_response == total
    
##########################################################

@scenario("create_subscriptions.feature", "Subscription Filter OK",
          example_converters=dict(net=int, nsub=int, total=int)
)
def test_create_subscriptions_Filter_ok():
    pass


@given("number of eventType <net> and number of subscriptions for eventType <nsub> with Filter", target_fixture="creation_response")
def create_subscriptions_Filter(ns_server_params, net, nsub):
    valid_responses = 0
    for e in range(net):
        for s in range(nsub):
            subscription = json.dumps({
	        'address': "http://eric-ns-test-client:3000/client/{}".format(s+1),
	        'subscriptionFilter': [{
		        'eventType': "FilterServiceOrderCreateEvent_{}".format(e+1),
                'filterCriteria': "data.units==psi_1"
	        }],
	        'tenant': "tenant_main"
            })
            response = send_creation_request(ns_server_params, json.loads(subscription))            
            if ((response.status_code == 201) or (response.status_code == 409)):
                valid_responses += 1
    return valid_responses
    

@then("we expect <total> subscriptions Filter created with response 201 or 409")
def check_total_subscription_Filter(creation_response, total):
    LOG.info("Expected Subscriptions : %s", total)
    LOG.info("Created Subscriptions : %s", creation_response)
    assert creation_response == total
    
##########################################################

@scenario("create_subscriptions.feature", "Subscription Projection OK",
          example_converters=dict(net=int, nsub=int, total=int)
)
def test_create_subscriptions_Projection_ok():
    pass


@given("number of eventType <net> and number of subscriptions for eventType <nsub> with Projection", target_fixture="creation_response")
def create_subscriptions_Projection(ns_server_params, net, nsub):
    valid_responses = 0
    for e in range(net):
        for s in range(nsub):
            subscription = json.dumps({
	        'address': "http://eric-ns-test-client:3000/client/{}".format(s+1),
	        'subscriptionFilter': [{
		        'eventType': "ProjectServiceOrderCreateEvent_{}".format(e+1),
                'fields': "id,data.value"
	        }],
	        'tenant': "tenant_main"
            })
            response = send_creation_request(ns_server_params, json.loads(subscription))            
            if ((response.status_code == 201) or (response.status_code == 409)):
                valid_responses += 1
    return valid_responses
    

@then("we expect <total> subscriptions Projection created with response 201 or 409")
def check_total_subscription_Projection(creation_response, total):
    LOG.info("Expected Subscriptions : %s", total)
    LOG.info("Created Subscriptions : %s", creation_response)
    assert creation_response == total
    
##########################################################

@scenario("create_subscriptions.feature", "Subscription Filter&Projection OK",
          example_converters=dict(net=int, nsub=int, total=int)
)
def test_create_subscriptions_FilterProjection_ok():
    pass


@given("number of eventType <net> and number of subscriptions for eventType <nsub> with Filter and Projection", target_fixture="creation_response")
def create_subscriptions_FilterProjection(ns_server_params, net, nsub):
    valid_responses = 0
    for e in range(net):
        for s in range(nsub):
            subscription = json.dumps({
	        'address': "http://eric-ns-test-client:3000/client/{}".format(s+1),
	        'subscriptionFilter': [{
		        'eventType': "FilProjServiceOrderCreateEvent_{}".format(e+1),
                'filterCriteria': "data.units==psi_1",
                'fields': "id"
	        }],
	        'tenant': "tenant_main"
            })
            response = send_creation_request(ns_server_params, json.loads(subscription))            
            if ((response.status_code == 201) or (response.status_code == 409)):
                valid_responses += 1
    return valid_responses
    

@then("we expect <total> subscriptions Filter&Projection created with response 201 or 409")
def check_total_subscription_FilterProjection(creation_response, total):
    LOG.info("Expected Subscriptions : %s", total)
    LOG.info("Created Subscriptions : %s", creation_response)
    assert creation_response == total
    


##########################################################
def send_creation_request(ns_server_param, subscription):
    ns_url = "{}/notification/v1/subscriptions".format(ns_server_param[keys.BASE_URL])
    LOG.debug("Send creation request to %s. Payload: %s", ns_url, subscription)
    response = requests.post(ns_url, headers=ns_server_param[keys.REQUEST_HEADERS], json=subscription)
    LOG.debug("Send creation request. response: %s", response.text.encode("utf8"))
    if ((response.status_code == 201) or (response.status_code == 409)):
        LOG.info("response_status :%s", response.status_code)
    else:
        LOG.error("response_status :%s", response.status_code)
    return response
