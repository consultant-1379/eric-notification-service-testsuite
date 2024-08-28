import json

class Message():
  def __init__(self):
    self.message = ""

  def reset(self):
    self.message = ""

  def compare(self, expected_message):
    return (self.message == expected_message)

  def setMessage(self, message):
    self.message = message

  def getMessage(self):
    return self.message
