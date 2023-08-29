from django.urls import path
from rooms.views import rooms_view
urlpatterns = [
    path('', rooms_view)
]