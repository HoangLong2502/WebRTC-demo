# Generated by Django 4.2.4 on 2023-08-28 07:14

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('meetings', '0002_remove_meetinguser_meeting_id_meeting_meeting_users'),
    ]

    operations = [
        migrations.AlterField(
            model_name='meeting',
            name='meeting_users',
            field=models.ManyToManyField(blank=True, to='meetings.meetinguser'),
        ),
    ]
