from django.contrib import admin
from meetings.models.meeting import Meeting
from meetings.models.meeting_user import MeetingUser
# Register your models here.
admin.site.register(Meeting)
admin.site.register(MeetingUser)