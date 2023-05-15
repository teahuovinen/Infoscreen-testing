from django.urls import path
from .views import office_page

app_name = 'infoscreen'
urlpatterns = [
    path('<str:office_location>/', office_page, name='office_page'),
]