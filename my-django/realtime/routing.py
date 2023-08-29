from django.urls import re_path
from . import consumers
from products.consumers import ProductDetailConsumer, ProductsConsumer
from meetings.consumer import MeetingConsumer

websocket_urlpatterns = [
    re_path(r"ws/socket-server/", consumers.RealtimeConsumer.as_asgi()),
    re_path(r"ws/products/$", ProductsConsumer.as_asgi()),
    # Cấu trúc (?P<product_id> ... ) xác định tên tham số là product_id. 
    # Trong trường hợp này, \w+ (\d+ là chỉ nhận chữ số) khớp với một chuỗi bất kỳ gồm các ký tự chữ cái, 
    # chữ số hoặc dấu gạch dưới, và + chỉ ra rằng ít nhất một ký tự phải khớp.
    re_path(r"ws/products/(?P<product_id>\d+)/$", ProductDetailConsumer.as_asgi()),
    re_path(r"socket.io/(?P<user_id>\d+)/$", MeetingConsumer.as_asgi()),
]