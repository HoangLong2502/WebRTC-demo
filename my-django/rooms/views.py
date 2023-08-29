from django.shortcuts import render
from rest_framework.views import APIView, Response
# Create your views here.
from general.general import *

class RoomsView(APIView):
    def get(self, request, *arg, **kwargs):
        return Response(convert_response('success', 200))

rooms_view = RoomsView.as_view()