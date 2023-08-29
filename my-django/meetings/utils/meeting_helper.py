from meetings.utils.meeting_payload import MeetingPayloadEnum


def join_meeting(meeting_id, socket, payload, meetingServer):
    user_id = payload['user_id']
    name = payload['name']

    