from django.db import models
from django.utils import timezone
from django.contrib import admin
from django.core.exceptions import ValidationError


class Office(models.Model):
    OFFICE_NAMES = (
        # ('Helsinki', 'Helsinki'),
        # ('Kuopio', 'Kuopio'),
        # ('Oulu', 'Oulu'),
        # ('Tampere', 'Tampere'),
    )
    
    office_location = models.CharField(max_length=20)#, choices=OFFICE_NAMES)

    def __str__(self):
        return self.office_location


class Release(models.Model):
    release_locations = models.ManyToManyField(Office, verbose_name="list of offices")
    release_owner_name = models.CharField(max_length=100)
    release_title = models.CharField(blank=True, max_length=100)
    release_body = models.CharField(blank=True, max_length=700)
    release_file = models.TextField(blank=True, default='')
    release_duration_on_screen = models.IntegerField(default=60)
    release_created = models.DateTimeField(auto_now_add=True)
    release_public_start = models.DateTimeField('Release public from')
    release_public_end = models.DateTimeField('Release public to')

    def clean(self):
        if self.release_public_end < self.release_public_start:
            raise ValidationError('You silly! "Release public to" time can not be earlier than "Release public from" time.')

    @admin.display(
        boolean=True,
        description='Live on screens',
    )
    def release_public_now(self):
        now = timezone.now()
        return self.release_public_start <= now <= self.release_public_end
    
    def save(self, *args, **kwargs):
        if not self.pk:
            # Only set the release_owner_name field on creation
            user = kwargs.pop('user', None)
            if user:
                self.release_owner_name = user.username
        super().save(*args, **kwargs)

    def __str__(self):
        return self.release_title

