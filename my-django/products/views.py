from django.shortcuts import render
# from rest_framework.views import APIView, Response
# from products.serializers.media_serializer import MediaSerializer
# from .models import MediaModel
# from general.general import *

# class MediaView(APIView):
#     def get(self, request, *arg, **kwargs):
#         media = MediaModel.objects.all()
#         media_serializer = MediaSerializer(media, many=True)
#         return Response(data=convert_response(message='success', status_code=200, data=media_serializer.data))

# mediaView = MediaView.as_view()

from products.view.media_view import MediaView
from products.view.products_view import ProductView, ProductDetailView, CategoryView, CategoryDetailView

product_view = ProductView.as_view()
product_detail_view = ProductDetailView.as_view()
category_view = CategoryView.as_view()
category_detail_view = CategoryDetailView.as_view()
media_view = MediaView.as_view()
