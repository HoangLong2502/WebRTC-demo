"""
ASGI config for myDjango project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.1/howto/deployment/asgi/
"""

import os
import django
django.setup()
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from channels.security.websocket import AllowedHostsOriginValidator
from realtime.routing import websocket_urlpatterns

# import socketio
# from meetings.socket import sio

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myDjango.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(websocket_urlpatterns),
    )
})

# application = socketio.ASGIApp(sio, get_asgi_application())