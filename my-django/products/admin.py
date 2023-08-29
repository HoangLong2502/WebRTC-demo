from django.contrib import admin

# Register your models here.
from .models import Product, Category, MediaModel
admin.site.register(Product)
admin.site.register(Category)
admin.site.register(MediaModel)