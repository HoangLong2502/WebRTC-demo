from rest_framework import serializers
from .models import *
from products.serializers.media_serializer import MediaSerializer
from account.serializers import AccountSerializer

class MessageSerializer(serializers.ModelSerializer):
    
    user_created_data = AccountSerializer(source='user_created', read_only=True)

    class Meta:
        model = MessageModel
        fields = [
            'content', 
            'user_created', 
            'user_created_data', 
            'created_at',
        ]

class RoomSerializer(serializers.ModelSerializer):

    image_data = MediaSerializer(source='image', read_only=True)
    members_data = AccountSerializer(source='members', read_only=True, many=True)
    host_data = AccountSerializer(source='host', read_only=True)
    media_data = MediaSerializer(source='media', read_only=True, many=True)
    conversation_data = MessageSerializer(source='conversation', read_only=True, many=True)
    user_created_data = AccountSerializer(source='user_created', read_only=True)
    
    class Meta:
        model = RoomModel
        fields = [
            'title', 
            'code', 
            'isOnline', 
            'image', 
            'image_data',
            'members', 
            'members_data',
            'host', 
            'host_data',
            'media', 
            'media_data'
            'conversation', 
            'conversation_data',
            'user_created', 
            'user_created_data',
            'created_at', 
            'updated_at',
        ]

    
    def create(self, validated_data):
        return super().create(validated_data)