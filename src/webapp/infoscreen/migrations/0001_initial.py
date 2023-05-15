# Generated by Django 4.1.7 on 2023-02-23 10:49

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Office',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('office_location', models.CharField(choices=[('Helsinki', 'Helsinki'), ('Kuopio', 'Kuopio'), ('Oulu', 'Oulu'), ('Tampere', 'Tampere')], max_length=15)),
            ],
        ),
        migrations.CreateModel(
            name='Release',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('release_owner_name', models.CharField(max_length=100)),
                ('release_title', models.CharField(max_length=200)),
                ('release_body', models.CharField(max_length=400)),
                ('release_file', models.TextField(default='Path to file here')),
                ('release_duration_on_screen', models.IntegerField(default=60)),
                ('release_created', models.DateTimeField(verbose_name='Release created')),
                ('release_public_start', models.DateTimeField(verbose_name='Release public start time')),
                ('release_public_end', models.DateTimeField(verbose_name='Release public end time')),
                ('release_locations', models.ManyToManyField(to='infoscreen.office', verbose_name='list of offices')),
            ],
        ),
    ]