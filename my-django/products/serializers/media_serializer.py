from rest_framework import serializers
from products.models import MediaModel

class MediaSerializer(serializers.ModelSerializer):
    class Meta:
        model = MediaModel
        fields = ["id", "image"]
    
    def create(self, validated_data):
        return super().create(validated_data)