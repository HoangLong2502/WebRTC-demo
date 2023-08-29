from rest_framework import serializers
import string
import random

from meetings.models.meeting import Meeting

def generate_random_string(length):
    characters = string.ascii_letters + string.digits
    return ''.join(random.choice(characters) for _ in range(length))


class MeetingSerializer(serializers.ModelSerializer):
    class Meta:
        model = Meeting
        fields = ['id', 'host_id', 'host_name', 'start_time', 'meeting_users']
    
    def create(self, validated_data):
        host_id = generate_random_string(10)
        validated_data['host_id'] = host_id
        return super().create(validated_data)