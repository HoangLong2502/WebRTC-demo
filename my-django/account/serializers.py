from rest_framework import serializers
from django.contrib.auth.hashers import make_password
from .models import Account

class AccountSerializer(serializers.ModelSerializer):
    class Meta:
        model = Account
        fields = [
            'id',
            'phone',
            'full_name',
            'email',
            'created_at',
            'password',
        ]

        extra_kwargs = {
            "password": {"write_only": True},
            "full_name": {"required": True},
        }
    
    def create(self, validated_data):
        validated_data['password'] = make_password(validated_data['password'])
        validated_data['username'] = validated_data['phone']
        return super().create(validated_data)
