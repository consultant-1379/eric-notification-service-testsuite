from flask import Flask, jsonify, request
from flask_api import status
from MessageQueue import MessageQueue
from queue import Queue
import datetime
import sys
import os

app = Flask(__name__)
msgQueue = []

def initMessageQueueList(maxNumClient):
    for i in range(maxNumClient):
        msgQueue.append(MessageQueue())

# Check that test client is up
@app.route('/health')
def health():
    ts = int(datetime.datetime.now().timestamp())
    return jsonify(timestamp=ts), status.HTTP_200_OK

# Reset all queues
@app.route('/reset', methods=['POST'])
def reset():
    for i in range(NUM_CLIENT):
        msgQueue[i].reset()
    ts = int(datetime.datetime.now().timestamp())
    return jsonify(timestamp=ts), status.HTTP_200_OK

# /clientx POST endpoints
@app.route('/client/<id>', methods=['POST'])
def post_client(id):
    if (int(id) > NUM_CLIENT):
        return jsonify(message='ERROR: client_id out of range'), status.HTTP_400_BAD_REQUEST
    notification = request.get_data(as_text=True)
#    print(notification)
    ts = int(datetime.datetime.now().timestamp())
    if notification is None:
        return jsonify(message='received empty notification'), status.HTTP_400_BAD_REQUEST
    else:
        msgQueue[int(id)-1].enqueueMessage(notification)
        print("content: " + notification)
        return jsonify(timestamp=ts), status.HTTP_200_OK

# /clientx GET endpoints
@app.route('/client/<id>', methods=['GET'])
def get_client(id):
    if (int(id) > NUM_CLIENT):
        return jsonify(message='ERROR: client_id out of range'), status.HTTP_400_BAD_REQUEST
    last_notification = msgQueue[int(id)-1].peekMessage()
    print("last notification: " + last_notification)
    return jsonify(last_notification=last_notification), status.HTTP_200_OK

# /testx (POST) endpoints
@app.route('/test/<id>', methods=['POST'])
def post_test(id):
    if (int(id) > NUM_CLIENT):
        return jsonify(message='ERROR: client_id out of range'), status.HTTP_400_BAD_REQUEST
    expected_result = request.get_data(as_text=True)
    if (expected_result == "none"):
        if (msgQueue[int(id)-1].isQueueEmpty()):
            success=True
        else:
            success=False
    else:
        success = msgQueue[int(id)-1].compare(expected_result)
    return jsonify(success=success), status.HTTP_200_OK

if __name__ == '__main__':
    # Determine the number of clients to be instantiated
    if (len(sys.argv) == 1):
        if (os.getenv('NUM_OF_CLIENTS')):
            NumberOfClients=os.getenv('NUM_OF_CLIENTS')
        else:
            NumberOfClients=50
    else:
        NumberOfClients=sys.argv[1]
    numClientStr=str(NumberOfClients)
    print("Number of Clients = " + numClientStr)
    NUM_CLIENT=int(NumberOfClients)
    initMessageQueueList(NUM_CLIENT)
    app.run(debug=True, host='0.0.0.0', port=3000)
