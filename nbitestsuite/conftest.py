import logging
from pytest import fixture
from .constants import keys

LOG = logging.getLogger(__name__)


def pytest_addoption(parser):
    parser.addoption(
        "--url",
        action="store",
        dest="url",
        required=True,
        help="URL address where NS deployed. Testsuite will run against this NS address")
    parser.addoption(
        "--tc_url",
        action="store",
        dest="tc_url",
        required=True,
        help="URL address where Test Client deployed. Testsuite will run against this TC address")
    parser.addoption(
        "--k8s_config",
        action="store",
        dest="k8s_config",
        required=True,
        help="k8s config file to use to connect to Kafka pod")
    parser.addoption(
        "--k8s_namespace",
        action="store",
        dest="k8s_namespace",
        required=True,
        help="k8s namespace to use to connect to Kafka pod")

@fixture
def ns_server_params(request):
    return {
        keys.BASE_URL: request.config.option.url,
        keys.TEST_CLIENT_URL: request.config.option.tc_url,
        keys.K8S_CONFIG: request.config.option.k8s_config,
        keys.K8S_NAMESPACE: request.config.option.k8s_namespace,
        keys.REQUEST_HEADERS: {
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
    }