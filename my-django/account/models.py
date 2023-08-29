from django.db import models
from django.utils import timezone
from django.contrib.auth.models import AbstractUser, AbstractBaseUser, BaseUserManager, PermissionsMixin
from .custommanager import CustomUserManager
# Create your models here.

class Account(AbstractUser):
    phone           = models.CharField(max_length=20, unique=True)
    full_name       = models.CharField(null=True, blank=True, max_length=512)
    email           = models.EmailField(null=True, blank=True, max_length=512)
    created_at	    = models.DateTimeField(default=timezone.now)
    USERNAME_FIELD  = 'phone'
    REQUIRED_FIELDS = ['username']

    object = CustomUserManager()

    def __str__(self):
        return self.phone or ''


# class UserManager(BaseUserManager):
#     """Manager for user.s"""

#     def create_user(self, email, password=None, **extra_field):
#         """Create, save and return a new user."""
#         user = self.model(email=email, **extra_field)
#         user.set_password(password)
#         user.save(using=self._db)

#         return user

# class User(AbstractBaseUser, PermissionsMixin):
#     email = models.EmailField(max_length=255, unique=True)
#     name = models.CharField(max_length=255)
#     is_active = models.BooleanField(default=True)
#     is_staff = models.BooleanField(default=False)

#     USERNAME_FIELD = 'email'