# Generated by Django 4.2.4 on 2023-08-18 10:13

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('products', '0005_alter_mediamodel_file_field'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='mediamodel',
            name='file_field',
        ),
        migrations.AddField(
            model_name='mediamodel',
            name='image',
            field=models.FileField(default=1, upload_to='products/image'),
            preserve_default=False,
        ),
    ]
