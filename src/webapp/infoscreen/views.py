from django.shortcuts import render, get_object_or_404
from .models import Office, Release
from django.utils import timezone
import requests
import os
import json
from azure.storage.blob import BlobServiceClient
import base64
import magic
from urllib.parse import urlparse



def get_yle_news():
    teletext_page = 191
    subpage = 0
    news = []
    api_key = os.getenv("YLE_API_KEY")
    
    for i in range(3):
        response = requests.get('https://external.api.yle.fi/v1/teletext/pages/' + str(teletext_page) + ".json?" + api_key)

        if response.status_code == 200:
            data = response.json()
            # print(data['teletext']['page']['subpage'][0]['content'][1]['line'])
            while True:
                try:
                    colored_data = data['teletext']['page']['subpage'][subpage]['content'][1]['line']
                    # print(colored_data)                   
                    news_headline = ""
                    news_body = ""

                    for line in colored_data:
                        if "Text" in line and "{SB}" in line['Text']:
                            if news_headline == "":
                                # print("SB-line IF: " + line['Text'])
                                pass
                            else:
                                # print("SB-line ELSE: " + line['Text'])
                                news_headline = news_headline[:-1]
                                news_body = news_body[:-1]
                                news.append((news_headline, news_body))
                                news_headline = ""
                                news_body = ""                    
                        elif "Text" in line and "{Green}" in line['Text'][:7]:
                            # print("Green-line ELIFIF: " + line['Text'])
                            new_line = str(line['Text'].replace("{Green}", "").strip())
                            news_headline += new_line + " "
                        elif "Text" in line and "{White}" in line['Text'][:7]:
                            # print("White-line ELIF: " + line['Text'])
                            new_line = str(line['Text'].replace("{White}", "").strip())
                            news_body += new_line + " "
                    subpage += 1
                except IndexError:
                    break
        else:
            print('Request failed with status code:', response.status_code)
            pass
        teletext_page += 1
        subpage = 0

    # If we didn't get any news from API, return No news
    if news == []:
        news = [("BREAKING NEWS", "YLE API isn't working, so no news :("),]
    return news


def get_weather(office):
    weather_api_key = os.getenv("OPENWEATHER_API_KEY")
    office_coords = {
        'Helsinki': (60.17184210479727, 24.945464340471265),
        'Oulu': (65.01258761181475, 25.468107012716317),
        'Tampere': (61.49466871188333, 23.775191689718742),
        'Kuopio': (62.894052758810574, 27.679505486697987)
    }
    coord = office_coords[str(office)]

    try:
        response = requests.get(f'https://api.openweathermap.org/data/2.5/forecast?lat={coord[0]}&lon={coord[1]}&appid={weather_api_key}')
        data = json.loads(response.text)
        current_temp = data['list'][0]['main']['temp']
        current_c = round(current_temp-273.15)
        current_icon = data['list'][0]['weather'][0]['icon']
        current_feels_like = data['list'][0]['main']['feels_like']
        current_feels_like_c = round(current_feels_like-273.15)
        current_pod = round((data['list'][0]['pop'])*100)

        tomorrow_temp = data['list'][8]['main']['temp']
        tomorrow_c = round(tomorrow_temp-273.15)
        tomorrow_icon = data['list'][8]['weather'][0]['icon']
        tomorrow_feels_like = data['list'][8]['main']['feels_like']
        tomorrow_feels_like_c = round(tomorrow_feels_like-273.15)
        tomorrow_pod = round((data['list'][8]['pop'])*100)

        day_after_tomorrow_temp = data['list'][16]['main']['temp']
        day_after_tomorrow_c = round(day_after_tomorrow_temp-273.15)
        day_after_tomorrow_icon = data['list'][16]['weather'][0]['icon']
        day_after_tomorrow_feels_like = data['list'][16]['main']['feels_like']
        day_after_tomorrow_feels_like_c = round(day_after_tomorrow_feels_like-273.15)
        day_after_tomorrow_pod = round((data['list'][16]['pop'])*100)

        today = (current_c, current_icon, current_feels_like_c, current_pod)
        tomorrow = (tomorrow_c, tomorrow_icon, tomorrow_feels_like_c, tomorrow_pod)
        day_after_tomorrow = (day_after_tomorrow_c, day_after_tomorrow_icon, day_after_tomorrow_feels_like_c, day_after_tomorrow_pod)
        return [today, tomorrow, day_after_tomorrow]
    except:
        return [("???", "unknown", "???", "???"), ("???", "unknown", "???", "???"), ("???", "unknown", "???", "???")]

def office_page(request, office_location):
    office = get_object_or_404(Office, office_location=office_location)
    now = timezone.now()
    releases_query = Release.objects.filter(
        release_locations=office,
        release_public_start__lte=now,
        release_public_end__gte=now,
    )

    # create a magic instance
    mime = magic.Magic(mime=True)

    # Convert Query to list and convert duration to milliseconds
    releases = []
    for release in releases_query:
        release_data = {
            'id': release.id,
            'release_title': release.release_title,
            'release_body': release.release_body,
            'release_file': None,
            'release_duration_on_screen': release.release_duration_on_screen * 1000,
        }
        if release.release_file:
            # Download the image data from Blob Storage and encode as Base64
            url = release.release_file
            parsed_url = urlparse(url)
            container_name = "infoscreen"
            blob_name = parsed_url.path[len(f'/{container_name}/'):]
            blob_service_client = BlobServiceClient(account_url=os.getenv("AZURE_STORAGE_ACCOUNT_URL"), credential=os.getenv("AZURE_BLOB_CREDENTIAL"))
            blob_client = blob_service_client.get_blob_client(container=container_name, blob=blob_name)
            image_data = blob_client.download_blob().readall()
            mime_type = mime.from_buffer(image_data)
            release_data['release_file'] = f"data:{mime_type};base64,{base64.b64encode(image_data).decode('utf-8')}"
        releases.append(release_data)

    # Fetch YLE news from Text-TV API
    news = get_yle_news()

    # Fetch Weather from openweather API
    weather = get_weather(office)
    
    context = {'office': office, 'releases': releases, 'news': news, 'weather': weather}
    return render(request, 'infoscreen/infoscreen.html', context)