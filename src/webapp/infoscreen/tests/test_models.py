from django.test import TestCase
from infoscreen.models import Office, Release
from django.utils import timezone
from datetime import timedelta

# models.py tests

class OfficeModelTests(TestCase):
    # @classmethod
    # def setUpTestData(cls):
    #     # Set up non-modified objects used by all test methods
    #     Office.objects.create(office_location='Helsinki')

    def test_office_location_label(self):
        office_location = Office.objects.get(id=1)
        field_label = office_location._meta.get_field('office_location').verbose_name
        self.assertEqual(field_label, 'office location')


class ReleaseModelTests(TestCase):
    @classmethod
    def setUpTestData(cls):
        # Set up non-modified objects used by all test methods
        release_public_start = timezone.now()
        release_public_end = release_public_start + timedelta(days=1)

        # create an Office object with office_location set to "Helsinki"
        office = Office.objects.create(office_location='Helsinki')
    
        release = Release.objects.create(
            release_owner_name = 'Tester',
            release_title = 'My title for test release',
            release_body = 'My body for test release',
            release_file = '',
            release_duration_on_screen = 15,
            release_public_start = release_public_start,
            release_public_end = release_public_end
            )
        
        # Set release_locations using the set() method
        release.release_locations.set([office])

    def test_release_locations_label(self):
        release_locations = Release.objects.get(id=1)
        field_label = release_locations._meta.get_field('release_locations').verbose_name
        self.assertEqual(field_label, 'list of offices')

    def test_release_title_max_length(self):
        release = Release.objects.get(id=1)
        max_length = release._meta.get_field('release_title').max_length
        self.assertEqual(max_length, 100)


