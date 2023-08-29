from rest_framework import serializers

from products.models import Product, Category
from products.serializers.media_serializer import MediaSerializer
from account.serializers import AccountSerializer

class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'title']

class ProductsSerializer(serializers.ModelSerializer):
    
    images_data = MediaSerializer(source='images', read_only=True, many=True)
    user_created_data = AccountSerializer(source='user_created', read_only=True)
    category_data = CategorySerializer(source='category', read_only=True)
   
    class Meta:
        model = Product
        fields = ['id', 'title', 'images', 'images_data', 'description', 'price_sell', 'category', 'category_data', 'is_active', 'user_created', 'user_created_data', 'created_at', 'updated_at']

        extra_kwargs = {
            'images' : {'required': False}
        }