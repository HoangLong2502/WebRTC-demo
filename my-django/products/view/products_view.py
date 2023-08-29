from rest_framework.views import APIView, Response
from rest_framework.permissions import IsAuthenticated
from django.db.models import Q
import json
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from general.general import *
from products.models import Product, Category
from products.serializers.product_serializer import *
from products.consumers import ProductsConsumer


class CategoryView(APIView):
    def get(self, request, *arg, **kwargs):
        category_data = Category.objects.all()
        category_serializer = CategorySerializer(category_data, many=True)
        return Response(convert_response("success", 200, category_serializer.data))

    def post(self, request, *arg, **kwargs):
        category_serizlizer = CategorySerializer(request.data)
        if category_serizlizer.is_valid(raise_exception=True):
            return Response(convert_response('success', 201, category_serizlizer.data))

class CategoryDetailView(APIView):
    def get(self, request, pk):
        category_data = Category.objects.filter(pk=pk).first()
        category_serializer = CategorySerializer(category_data)
        return Response(convert_response('success', 200, category_serializer.data))

class ProductView(APIView):
    permission_classes=[IsAuthenticated]

    def get(self, request, *arg, **kwargs):
        QUERY_ACCEPT = ["title__icontains", "category_id", "is_active", "search"]
        BOOL_ACCEPT = ["is_active"]
        SEARCH_FIELDS = ["title", "description"]
        search_query = Q()
        query_params = request.query_params.dict().copy()
        for key in query_params.copy().keys():
            if key not in QUERY_ACCEPT or key in ["page", "limit"]:
                del query_params[key] 
            if key in BOOL_ACCEPT:
                if query_params[key] == "true":
                    query_params[key] = True
                elif query_params[key] == "false":
                    query_params[key] = False
            if key == "search":
                for field in SEARCH_FIELDS:
                    search_query |= Q(**{f"{field}__icontains": query_params["search"]})
                del query_params["search"]
                
        account = request.user
        product_data = Product.objects.filter(Q(user_created=account), search_query, **query_params).order_by('created_at')
        product_serializer = ProductsSerializer(product_data, many=True)
        return Response(convert_response("succes", 200, product_serializer.data))

    def post(self, request, *arg, **kwargs):
        images          = request.data.get('images')
        category_data   = request.data.get('category')
        category_data   = json.loads(category_data)
        product_data    = request.data.get('data')
        product_data    = json.loads(product_data)

        # create product
        product_serializer = ProductsSerializer(data=product_data)
        if not product_serializer.is_valid(raise_exception=True):
            return Response()
        product_new = product_serializer.save(user_created=request.user)

        # create image
        if images:
            payload = {
            "image": images
            }
            print(f'----------{images}')
            media_serializer = MediaSerializer(data=payload)
            if not media_serializer.is_valid(raise_exception=True):
                return Response(convert_response('media invalid', 201, product_serializer.data))
            media_new = media_serializer.save()
            product_new.images.add(media_new)
        
        # create category
        category_serializer = CategorySerializer(data=category_data)
        if not category_serializer.is_valid(raise_exception=True):
            return Response(convert_response('category invalid', 201, product_serializer.data))
        category_new = category_serializer.save()
        product_new.category = category_new

        # get channel ws and send message to room_group_name
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            'ws_product',  # Tên của room_group_name
            {
                'type': 'send_update',
                'message': 'message',
            }
        )
        return Response(convert_response('success', 201, product_serializer.data))

class ProductDetailView(APIView):

    def get(self, request, pk):
        product_data = Product.objects.filter(pk=pk).first()
        product_serializer = ProductsSerializer(product_data)
        # if not product_serializer.is_valid():
        #     return Response(convert_response('product invalid', 400))
        return Response(convert_response('success', 200, product_serializer.data))

    def put(self, request, pk):
        category_data = request.data.get('category')
        category_data = json.loads(category_data)
        image_data = request.data.get('image')
        data = request.data.get('data')
        data = json.loads(data)

        product_data = Product.objects.filter(pk=pk).first()
        product_serializer = ProductsSerializer(product_data, data=data, partial=True)
        if not product_serializer.is_valid(raise_exception=True):
            return Response(convert_response('update field', 400))

        category_serializer = CategorySerializer(data=category_data)
        if not category_serializer.is_valid(raise_exception=True):
            return Response(convert_response('category invalid', 201, product_serializer.data))
        category_new = category_serializer.save()
        product_serializer.category = category_new

        product_serializer.save()
        
        # get channel ws and send message to room_group_name
        channel_layer = get_channel_layer()
        async_to_sync(channel_layer.group_send)(
            'ws_product',  # Tên của room_group_name
            {
                'type': 'send_update',
                'message': 'message',
            }
        )
        return Response(convert_response('success', 200, product_serializer.data))

