from django.test import TestCase, SimpleTestCase
from django.contrib.sites.models import Site


# views.py tests

class ViewTests(TestCase):
    # def test_url_exists_at_correct_location_admin_login(self):
    #     response = self.client.get("/admin/login/")
    #     self.assertEqual(response.status_code, 200)

    def test_url_exists_at_correct_location_helsinki(self):
        response = self.client.get("/infoscreen/Helsinki/")
        self.assertEqual(response.status_code, 200)

    def test_url_exists_at_correct_location_kuopio(self):
        response = self.client.get("/infoscreen/Kuopio/")
        self.assertEqual(response.status_code, 200)

    def test_url_exists_at_correct_location_oulu(self):
        response = self.client.get("/infoscreen/Oulu/")
        self.assertEqual(response.status_code, 200)

    def test_url_exists_at_correct_location_tampere(self):
        response = self.client.get("/infoscreen/Tampere/")
        self.assertEqual(response.status_code, 200)
