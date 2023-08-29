import json
from channels.generic.websocket import WebsocketConsumer
from channels.generic.websocket import async_to_sync


class ChatConsumer(WebsocketConsumer):
    def connect(self):
        user_id = self.scope['url_route']['kwargs']['user_id']
        self.room_group_name = f'chat_room_id/{user_id}'

        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )

        self.accept()
    
    def disconnect(self, code):
        async_to_sync(self.channel_layer.group_discard)(
            self.room_group_name,
            self.channel_name
        )
        print('Disconnected!')

    def receive(self, text_data=None, bytes_data=None):
        receive_dict = json.loads(text_data)
        # message = receive_dict['message']
        # receive_dict['message']['receiver_channel_name'] = self.channel_name

        async_to_sync(self.channel_layer.group_send)(
            self.room_group_name,
            {
                'type': 'send_spd',
                'receive_dict': receive_dict
            }
        )
    
    def send_spd(self, event):
        receive_dict = event['receive_dict']

        self.send(text_data=json.dumps(receive_dict))

class MeetingConsumer(WebsocketConsumer):
    def connect(self):
        user_id =  self.scope['url_route']['kwargs']['user_id']
        self.room_group_name = f'chat_room_id_{user_id}'

        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )
        self.accept()

    def receive(self, text_data=None, bytes_data=None):
        user_id = self.scope['url_route']['kwargs']['user_id']
        data = json.loads(text_data)
        
        if data['type'] == 'create_meeting':
            callee_id = data['callee_id']
            sdp_offer = data['sdp_offer']
            async_to_sync(self.channel_layer.group_send)(
                f'chat_room_id_{callee_id}',
                {
                    'type' : 'new_meeting',
                    'message': {
                        'type' : 'new_meeting',
                        'sdp_offer' : sdp_offer,
                        'caller_id' : user_id,
                    },
                }
            )
        elif data['type'] == 'answer_meeting':
            sdp_answer = data['sdp_answer']
            caller_id = data['caller_id']
            async_to_sync(self.channel_layer.group_send)(
                f'chat_room_id_{caller_id}',
                {
                    'type' : 'meeting_answered',
                    'message': {
                        'type' : 'meeting_answered',
                        'sdp_answer' : sdp_answer,
                    }
                }
            )
        elif data['type'] == 'ice_candidate':
            ice_candidate = data['ice_candidate']
            callee_id = data['callee_id']
            async_to_sync(self.channel_layer.group_send)(
                f'chat_room_id_{callee_id}',
                {
                    'type' : 'ice_candidate',
                    'message': {
                        'type' : 'ice_candidate',
                        'ice_candidate' : ice_candidate,
                    }
                }
            )

        return super().receive(text_data, bytes_data)
    
    # utils.helper.sendMessage
    def new_meeting(self, event):
        data = json.dumps(event['message'])
        print(f"=====new_meeting: {data}")
        self.send(text_data=data)

    def meeting_answered(self, event):
        data = json.dumps(event['message'])
        self.send(text_data=data)
    
    def ice_candidate(self, event):
        data = json.dumps(event['message'])
        self.send(text_data=data)
