from django.db import models
# from meetings.models.meeting import Meeting

class MeetingUser(models.Model):
    socket_id = models.CharField(max_length=512)
    # meeting_id = models.ForeignKey(Meeting, on_delete=models.SET_NULL, null=True, blank=True)
    user_id = models.CharField(max_length=512, null=False, blank=False)
    joined = models.BooleanField(default=False)
    name = models.CharField(max_length=512, blank=False, null=False)
    is_alive = models.BooleanField(default=False)
