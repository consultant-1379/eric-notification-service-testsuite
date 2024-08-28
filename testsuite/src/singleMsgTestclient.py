from flask import Flask, jsonify, request
from flask_api import status
from Message import Message
import datetime

app = Flask(__name__)

message = [ Message(), Message(), Message(), Message() ]

@app.route('/health')
def health():
    ts = int(datetime.datetime.now().timestamp())
    return jsonify(timestamp=ts), status.HTTP_200_OK

@app.route('/reset', methods=['POST'])
def reset():
    for i in range(4):
        message[i].reset()
    ts = int(datetime.datetime.now().timestamp())
    return jsonify(timestamp=ts), status.HTTP_200_OK

#/client1-4 endpoints
def post_client(client):
    notification = request.get_data(as_text=True)
#    print(notification)
    ts = int(datetime.datetime.now().timestamp())
    if notification is None:
        return jsonify(message='received empty notification'), status.HTTP_400_BAD_REQUEST
    else:
        message[client-1].setMessage(notification)
        print("content: " + message[client-1].getMessage())
        return jsonify(timestamp=ts), status.HTTP_200_OK

@app.route('/client1', methods=['POST'])
def post_client1():
    message, status = post_client(1)
    return message, status

@app.route('/client2', methods=['POST'])
def post_client2():
    message, status = post_client(2)
    return message, status

@app.route('/client3', methods=['POST'])
def post_client3():
    message, status = post_client(3)
    return message, status

@app.route('/client4', methods=['POST'])
def post_client4():
    message, status = post_client(4)
    return message, status

def get_client(client):
    last_notification = message[client-1].getMessage()
    print("last notification: " + last_notification)
    return jsonify(last_notification=last_notification), status.HTTP_200_OK

@app.route('/client1', methods=['GET'])
def get_client1():
    message, status = get_client(1)
    return message, status

@app.route('/client2', methods=['GET'])
def get_client2():
    message, status = get_client(2)
    return message, status

@app.route('/client3', methods=['GET'])
def get_client3():
    message, status = get_client(3)
    return message, status

@app.route('/client4', methods=['GET'])
def get_client4():
    message, status = get_client(4)
    return message, status

#/test1-4 endpoints
def post_test(client):
    expected_result = request.get_data(as_text=True)
    success = message[client-1].compare(expected_result)
    return jsonify(success=success), status.HTTP_200_OK

@app.route('/test1', methods=['POST'])
def post_test1():
    message, status = post_test(1)
    return message, status

@app.route('/test2', methods=['POST'])
def post_test2():
    message, status = post_test(2)
    return message, status

@app.route('/test3', methods=['POST'])
def post_test3():
    message, status = post_test(3)
    return message, status

@app.route('/test4', methods=['POST'])
def post_test4():
    message, status = post_test(4)
    return message, status

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=3000)
