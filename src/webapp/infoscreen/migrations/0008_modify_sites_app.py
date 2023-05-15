# Generated by Django 4.1.7 on 2023-04-25 11:18

from django.db import migrations, models
from django.contrib.sites.models import Site

def add_localhost(apps, schema_editor):
    Site.objects.create(
        domain='localhost',
        name='localhost',
    )

class Migration(migrations.Migration):

    dependencies = [
        ('sites', '0002_alter_domain_unique'),
        ('infoscreen', '0007_auto_20230425_1346'),
    ]

    operations = [
        migrations.RunPython(add_localhost),
    ]
