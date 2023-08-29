from django.shortcuts import render
from rest_framework import generics
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAdminUser
from rest_framework.authtoken.models import Token

from .models import Account
from .serializers import AccountSerializer
from general.general import *
# Create your views here.

class AccountListCreateView(generics.ListCreateAPIView):
    queryset = Account.objects.all()
    serializer_class = AccountSerializer
    permission_classes = [IsAdminUser]

    def get(self, request, *args, **kwargs):
        return super().get(request, *args, **kwargs)

    def perform_create(self, serializer):
        return super().perform_create(serializer)

accountListCreateView = AccountListCreateView.as_view()

class AccountLoginView(APIView):
    def post(self, request, *args, **kwargs):
        phone = request.data.get("phone", None)
        password = request.data.get("password", None)
        if not phone or not password:
            return Response(convert_response("Required phone, password", 400))
        try:
            account = Account.objects.get(phone=phone)
        except:
            return Response(convert_response("Account not found", 400))
        if not account.check_password(password):
            return Response(convert_response("Invalid password", 400))   
        if account.is_active == False:
            return Response(convert_response("Account not activate", 400))
        token, created = Token.objects.get_or_create(user=account)
        serializer = AccountSerializer(account)
        return Response(convert_response("Success", 200, {"token": token.key, "user": serializer.data}))

accountLoginView = AccountLoginView.as_view()

class AccountRegisterView(APIView):
    def post(self, request):
        serializer = AccountSerializer(data=request.data)
        if serializer.is_valid(raise_exception=True):
            phone = serializer.validated_data.get("phone")
            try:
                Account.objects.get(phone=phone)
                return Response(convert_response("Registered phone number", 400))
            except:
                account = serializer.save()
                token, created = Token.objects.get_or_create(user=account)
                return Response(convert_response("Success", 201, {"token": token.key, "account": serializer.data}))
        return Response(convert_response("Not good data", 400))

accountRegisterView = AccountRegisterView.as_view()
