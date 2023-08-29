from django.urls import path
from meetings.views import *
urlpatterns = [
    path('', MeetingView.as_view()),
    path('<int:pk>/', MeetingDetailView.as_view()),
    path('meeting_user/', MeetingUsersView.as_view()),
]