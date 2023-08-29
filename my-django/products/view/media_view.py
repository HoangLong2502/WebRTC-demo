from rest_framework.views import APIView, Response
from products.serializers.media_serializer import MediaSerializer
from products.models import MediaModel
from general.general import *

class MediaView(APIView):
    def get(self, request, *arg, **kwargs):
        media = MediaModel.objects.all()
        media_serializer = MediaSerializer(media, many=True)
        return Response(data=convert_response(message='success', status_code=200, data=media_serializer.data))

mediaView = MediaView.as_view()