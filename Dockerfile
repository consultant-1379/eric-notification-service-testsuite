FROM armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles:3.16.0-22 as base_image

RUN zypper ar -C -G -f https://arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/3.3.0-14?ssl_verify=no LDC-CBO-SLES \
    && zypper ref -f -r LDC-CBO-SLES \
    && zypper install -l -y python3 \
    && zypper install -l -y python3-pip \
    && pip install --upgrade pip \
    && pip install --no-cache-dir --trusted-host pypi.org flask flask_api

COPY testsuite/src /test_client

ENTRYPOINT [ "python3" ]
CMD [ "/test_client/testclient.py" ]
