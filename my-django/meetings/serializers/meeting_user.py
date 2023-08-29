from rest_framework import serializers
from meetings.models.meeting_user import MeetingUser

class MeetingUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = MeetingUser
        fields = ['id', 'socket_id', 'meeting_id', 'user_id', 'joined', 'name', 'is_alive']