from django.db import models
from django.utils import timezone
# Create your models here.
from meetings.models.meeting_user import MeetingUser

class Meeting(models.Model):
    host_id = models.CharField(max_length=512, null=False, blank=False)
    host_name = models.CharField(max_length=512, null=False, blank=False)
    start_time = models.DateTimeField(default=timezone.now)
    meeting_users = models.ManyToManyField(MeetingUser, blank=True)