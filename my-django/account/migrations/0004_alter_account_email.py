# Generated by Django 4.2.4 on 2023-08-15 04:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('account', '0003_alter_account_options_alter_account_managers_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='account',
            name='email',
            field=models.EmailField(blank=True, max_length=512, null=True),
        ),
    ]