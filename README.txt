This README contains instruction about how to build, run and test a docker image for the Test Client component of the Notification Service test environment.


Test Client image build and run

To build the image, first clone the notification service repo (eric-notification-service):
git clone ssh://<signum>@gerrit.ericsson.se:29418/OSS/com.ericsson.oss.common.service/eric-notification-service-testsuite

$ cd eric-notification-service-testsuite

Create the image with a docker build:
docker build -t eric-ns-test-client:1.0 .

Run the image, making test client to expose endpoints on a free port (9999 port is used here):
docker run -d -p 9999:3000 eric-ns-test-client:1.0


Test Client unit test

To test the newly created image, execute the following steps.

Go to the test directory:
cd eric-notification-service/testsuite/test

Execute unit test, passing to it the port chosen above:
./executeUnitTest.sh 9999

Check that the last line of the output of the previous command is the following:
Unit Test Successful

By looking at the contents of the file unitTest.sh (called by executeUnitTest.sh), you may get an idea of how the test client operates.
