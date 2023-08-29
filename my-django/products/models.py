from django.db import models
from django.utils import timezone
# from django_backblaze_b2 import BackblazeB2Storage
from django_backblaze_b2 import BackblazeB2Storage
# Create your models here.
from account.models import Account


class Category(models.Model):
    title           = models.CharField(max_length=512)
    create_at       = models.DateTimeField(default=timezone.now)
    user_created    = models.ForeignKey(Account, on_delete=models.SET_NULL, null=True, blank=True)
    # product         = models.ManyToOneRel(Product, on_delete=models.SET_NULL, null=True, blank=True)
    def __str__(self):
        return self.title

# class MediaProduct(models.Model):
#     image       = models.ImageField(upload_to='product/image/')
#     create_at   = models.DateTimeField(default=timezone.now)

class MediaModel(models.Model):
    # alt         = models.CharField(max_length=255, null=True, blank=True, default='')
    image  = models.FileField(upload_to="products/image")
    # created_at      = models.DateTimeField(default=timezone.now)

class Product(models.Model):
    title           = models.CharField(max_length=512)
    images          = models.ManyToManyField(MediaModel,blank=True)
    description     = models.CharField(null=True, blank=True, max_length=512)
    price_sell      = models.FloatField(null=False, blank=False, max_length=10)
    category        = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True)
    is_active       = models.BooleanField(default=True)
    user_created    = models.ForeignKey(Account, on_delete=models.SET_NULL, null=True, blank=True)
    created_at      = models.DateTimeField(default=timezone.now)
    updated_at      = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return self.title