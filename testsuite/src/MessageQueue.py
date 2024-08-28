from queue import Queue

class MessageQueue():
  def __init__(self):
    self.msgQueue = Queue(maxsize = 0)

  def reset(self):
    del self.msgQueue
    self.msgQueue = Queue(maxsize = 0)

  def compare(self, expected_message):
    if (not(self.msgQueue.empty())):
      if (expected_message == "any"):
        self.msgQueue.get_nowait()
        return True
      else:
        return (self.msgQueue.get_nowait() == expected_message)
    else:
      return (expected_message == "")

  def enqueueMessage(self, message):
    self.msgQueue.put(message)

  def dequeueMessage(self):
    if (not(self.msgQueue.empty())):
      return self.msgQueue.get()
    else:
      return ""
      
  def peekMessage(self):
    if (not(self.msgQueue.empty())):
      bufque = self.msgQueue.queue
      message = bufque.popleft()
      bufque.appendleft(message)
      return message
    else:
      return ""
  
  def isQueueEmpty(self):
    return self.msgQueue.empty()
