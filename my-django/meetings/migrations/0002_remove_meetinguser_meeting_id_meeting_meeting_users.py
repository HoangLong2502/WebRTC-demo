# Generated by Django 4.2.4 on 2023-08-25 07:17

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('meetings', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='meetinguser',
            name='meeting_id',
        ),
        migrations.AddField(
            model_name='meeting',
            name='meeting_users',
            field=models.ManyToManyField(blank=True, null=True, to='meetings.meetinguser'),
        ),
    ]
