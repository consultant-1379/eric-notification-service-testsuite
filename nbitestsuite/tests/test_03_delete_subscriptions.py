import requests
import logging
import json
from base64 import b64encode
from os import urandom
from ..constants import keys
from pytest_bdd import scenario, given, when, then

LOG = logging.getLogger(__name__)


@scenario("delete_subscriptions.feature", "Subscription deletion OK")
def test_delete_subscriptions_ok():
    pass


@given("get subscriptions is done", target_fixture="get_subscriptions_response")
def get_all_subscriptions(ns_server_params):
    LOG.info("get subscriptions.....")
    ns_url = "{}/notification/v1/subscriptions".format(ns_server_params[keys.BASE_URL])
    response = requests.get(ns_url)
    if (response.status_code == 200):
        LOG.info("response_status :%s subscriptions found :%s", response.status_code, len(response.json()))
    else:
        LOG.error("response_status :%s ", response.status_code)
    return response
    

@then("all subscriptions found are deleted")
def delete_all_subscriptions(ns_server_params, get_subscriptions_response):
    number_subscriptions_to_delete = 0
    number_subscriptions_deleted = 0
    if (get_subscriptions_response.status_code == 200):
        number_subscriptions_to_delete = len(get_subscriptions_response.json())
        LOG.info("Subscriptions to be deleted : %s", number_subscriptions_to_delete)
    else:
        assert False
    if (number_subscriptions_to_delete > 0):
        data = json.loads(get_subscriptions_response.content)
        for nsub in range(number_subscriptions_to_delete):
            delete_id = data[nsub]['id']
            deleted_sub = delete_subscription(ns_server_params, delete_id)
            if (deleted_sub.status_code == 204):
                number_subscriptions_deleted += 1
    else:
        LOG.info("No Subscriptions to be deleted") 
    LOG.info("Number Subscriptions to delete Expected : %s", number_subscriptions_to_delete)
    LOG.info("Number Subscriptions to delete Verified : %s", number_subscriptions_deleted)
    assert number_subscriptions_deleted == number_subscriptions_to_delete
    

##########################################################
def delete_subscription(ns_server_param, id):
    ns_url = "{}/notification/v1/subscriptions/{}".format(ns_server_param[keys.BASE_URL],id)
    LOG.debug("Send delete request to %s for subscription id : %s",ns_server_param[keys.BASE_URL],id)
    response = requests.delete(ns_url)
    LOG.debug("Send delete request. response: %s",response.text.encode("utf8"))
    if (response.status_code == 204):
        LOG.info("response_status:%s Subscription id : %s deleted with success",response.status_code,id)
    elif (response.status_code == 404):
        LOG.error("response_status:%s Subscription id : %s not found !",response.status_code,id)
    else:
        LOG.error("response_status:%s Subscription id : %s delete error !",response.status_code,id)
    return response
        

