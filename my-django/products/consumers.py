import json
from channels.generic.websocket import WebsocketConsumer, AsyncWebsocketConsumer
from asgiref.sync import async_to_sync

from products.models import Product
from products.serializers.product_serializer import ProductsSerializer
from general.general import *

class ProductDetailConsumer(WebsocketConsumer):

    def connect(self):
        product_id = self.scope['url_route']['kwargs']['product_id']
        self.room_group_name = f'ws_product_{product_id}'
        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )
        self.accept()
        async_to_sync(self.channel_layer.group_send)(
            self.room_group_name,
            {
                'type' : 'send_update',
                'message': "product_json",
                'id': product_id
            }
        )

    async def receive(self, text_data=None, bytes_data=None):
        try:
            data = json.loads(text_data)
            print(f"Message: {data['message']}")
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type' : 'send_update',
                    'message': 'Đã update {data}'
                }
            )
        except:
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    'type' : 'send_update',
                    'message': 'invalid Json'
                }
            )

    def update_title(self, message: str):
        if message:
            self.send(text_data=message)

    def send_update(self, event):
        product_data = Product.objects.filter(pk=event['id']).first()
        product_serializer = ProductsSerializer(product_data)
        self.send(text_data=json.dumps({
            'type': 'title change',
            'data': product_serializer.data,
        }))

class ProductsConsumer(WebsocketConsumer):
    def connect(self):
        self.room_group_name = 'ws_product'
        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )
        self.accept()
        async_to_sync(self.channel_layer.group_send)(
            self.room_group_name,
            {
                'type' : 'send_update',
                'message': "product_json",
            }
        )

    def receive(self, text_data=None, bytes_data=None):
        dataJson = json.loads(text_data)
        print(dataJson)
        data = dataJson['data']
        async_to_sync(self.channel_layer.group_send)(
            self.room_group_name,
            {
                'type' : 'send_image',
                'message': data,
            }
        )
    
    def send_image(self, event):
        self.send(text_data=json.dumps(convert_response('products was updated', 200, event['message'])))
    
    def send_update(self, event=None):
        product_data = Product.objects.all().order_by('id')
        product_serializer = ProductsSerializer(product_data, many=True)
        self.send(text_data=json.dumps(convert_response('products was updated', 200, product_serializer.data)))

