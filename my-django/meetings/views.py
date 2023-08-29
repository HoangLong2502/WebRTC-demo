from django.shortcuts import render
from rest_framework.views import Response, APIView
from django.db.models import Q
from channels.layers import get_channel_layer
from channels.generic.websocket import async_to_sync 
# Create your views here.

from meetings.models.meeting_user import MeetingUser
from meetings.serializers.meeting_user import MeetingUserSerializer
from general.general import *
from meetings.models.meeting import Meeting
from meetings.serializers.meeting import MeetingSerializer
from meetings.utils.meeting_payload import MeetingPayloadEnum

# meeting.service.getAllMeetingUsers:
class MeetingUsersView(APIView):
    def get(self, request, pk):
        try:
            user = MeetingUser.objects.all(Q(meeting_id=pk))
        except MeetingUser.DoesNotExist:
            return Response(convert_response('user not found', 400))
        
        serializers = MeetingUserSerializer(user, many=True)
        return Response(convert_response('success', 200, serializers.data))

class MeetingUserDetailView(APIView):

    # meeting.service.updateMeetingUser 
    def put(self, request, pk):
        user_data = request.data
        try:
            user = MeetingUser.objects.get(pk=pk)
        except MeetingUser.DoesNotExist:
            return Response(convert_response('user not found', 400))
        
        user_serializer = MeetingUserSerializer(user, data=user_data, partial=True)
        if not user_serializer.is_valid(raise_exception=True):
            return Response(convert_response('err', 400))
        user_serializer.save()
        return Response(convert_response('success', 200, user_serializer.data))


# meeting.service.startMeeting -> create new MeetingUser -> add new MeetingUser to Meeting:
class MeetingView(APIView):
    # meeting.service.startMeeting
    def post(self, request, *arg, **kwarg):
        meeting_data = request.data
        meeting_serializer = MeetingSerializer(data=meeting_data)
        if meeting_serializer.is_valid(raise_exception=True):
            new_meeting = meeting_serializer.save()
            return Response(convert_response('success', 201, new_meeting))
        return Response(convert_response('err create meeting', 400))

# meeting.service.joinMeeting
class MeetingDetailView(APIView):
    # meeting.service.isMeetingPresent || getAllMeetingUser
    def get(self, requset, pk):
        meeting_model = Meeting.objects.get(pk=pk)
        if not meeting_model:
            # get channel ws and send message to room_group_name
            channel_layer = get_channel_layer()
            async_to_sync(channel_layer.group_send)(
                'ws_product',  # Tên của room_group_name
                {
                    'type': 'send_update',
                    'message': {'type': MeetingPayloadEnum.NOT_FOUND},
                }
            )
            return Response(convert_response('Invalid Meeting Id', 400))
        meeting_serializer = MeetingSerializer(meeting_model)
        return Response(convert_response('success', 200, meeting_serializer.data))

    # meeting.service.joinMeeting
    def put(self, request, pk):
        meeting_model = Meeting.objects.get(pk=pk)
        meeting_serializer = MeetingSerializer(meeting_model)

        # create user meeting and save to meeting
        meeting_user_data = request.data
        meeting_user_serializer = MeetingUserSerializer(data=meeting_user_data)
        if meeting_user_serializer.is_valid(raise_exception=True):
            new_meeting_user = meeting_user_serializer.save()
            meeting_serializer.meeting_users.add(new_meeting_user)
            return Response(convert_response('success', 201, meeting_serializer.data))
        return Response(convert_response('err create meeting', 400))


