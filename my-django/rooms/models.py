from django.db import models
from django.utils import timezone
from products.models import MediaModel
from account.models import Account
# Create your models here.

class MessageModel(models.Model):
    user_created    = models.ForeignKey(Account, on_delete=models.SET_NULL, null=True, blank=True)
    content         = models.CharField(max_length=512, blank=True, null=False)
    created_at      = models.DateTimeField(default=timezone.now)

class RoomModel(models.Model):
    title           = models.CharField(max_length=512, null=False, blank=False)
    code            = models.CharField(max_length=128, null=False, blank=False)
    isOnline        = models.BooleanField(default=False)
    image           = models.ForeignKey(MediaModel, on_delete=models.SET_NULL, null=True, blank=True, related_name='r_image')
    members         = models.ManyToManyField(Account, blank=True, related_name='members')
    host            = models.ForeignKey(Account, on_delete=models.SET_NULL, null=True, blank=True, related_name='host')
    media           = models.ManyToManyField(MediaModel, blank=True, related_name='r_media')
    conversation    = models.ManyToManyField(MessageModel, blank=True)
    user_created    = models.ForeignKey(Account, on_delete=models.SET_NULL, null=True, blank=True, related_name='user_created')
    created_at      = models.DateTimeField(default=timezone.now)
    updated_at      = models.DateTimeField(default=None, null=True, blank=True)
    
    def __str__(self) -> str:
        return self.title


