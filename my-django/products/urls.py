from django.urls import path, re_path

from .views import *
from products.consumers import ProductsConsumer

urlpatterns = [
    path('', product_view),
    path('<int:pk>/', product_detail_view),
    path('category/', category_view),
    path('category/<int:pk>/', category_detail_view),
    path('media/', media_view),
]

product_ws_urlpatterns = [
    re_path(r"ws/product/", ProductsConsumer.as_asgi()),
]