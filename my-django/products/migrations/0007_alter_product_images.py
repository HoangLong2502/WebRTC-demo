# Generated by Django 4.2.4 on 2023-08-19 03:16

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0006_remove_mediamodel_file_field_mediamodel_image'),
    ]

    operations = [
        migrations.AlterField(
            model_name='product',
            name='images',
            field=models.ManyToManyField(blank=True, to='products.mediamodel'),
        ),
    ]
