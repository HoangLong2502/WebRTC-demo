from django.urls import path
from .views import *

urlpatterns = [
    path('', accountListCreateView),
    path('login/', accountLoginView),
    path('register/', accountRegisterView),
]