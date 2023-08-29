import json
from channels.generic.websocket import WebsocketConsumer

class RealtimeConsumer(WebsocketConsumer):
    def connect(self):
        self.accept()
        self.send(text_data=json.dumps({
            'type': 'connection_established',
            'message': 'Welcome to my channel web socket!'
        }))
        # return super().connect()

    # def receive(self, text_data=None, bytes_data=None):
    #     return super().receive(text_data, bytes_data)