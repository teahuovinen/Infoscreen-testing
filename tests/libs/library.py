''' Functions used as keywords in RF-files and to create variables needed for them and variables used 
    in RF-files.
'''

import datetime
import json
import os
import pytz
import requests

from random import randint


def three_hour_time():
    '''Creates datetime-object (EET) that is rounded to the past 3h (00, 03, 06 ..) for weather.robot.'''
    tz = pytz.timezone('Europe/Helsinki')
    rounded_hour = datetime.datetime.now(tz=tz).replace(minute=0, second=0, microsecond=0)
    rounded_hour -= datetime.timedelta(hours=rounded_hour.hour % 3)
    return rounded_hour

def get_weather(dt_txt, office):
    '''Gets weather information for 3h time period according to datetime-string used as an argument 
        and returns it as a dictionary after converting kelvins to celsius and decimal to percent. 
        Agrument dt_txt string must be in form YYYY-MM-DD HH:MM:SS and office must be Helsinki, Oulu, Tampere or Kuopio.
    '''
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
        for weather in data['list']:
            if weather['dt_txt'] == dt_txt:
                weather['main']['temp'] = convert_to_celsius(weather['main']['temp'])
                weather['main']['feels_like'] = convert_to_celsius(weather['main']['feels_like'])
                weather['pop'] = convert_to_percent(weather['pop'])
                return weather
        data['list'][0]['main']['temp'] = convert_to_celsius(data['list'][0]['main']['temp'])
        data['list'][0]['main']['feels_like'] = convert_to_celsius(data['list'][0]['main']['feels_like'])
        data['list'][0]['pop'] = convert_to_percent(weather['pop'])
        return data['list'][0]
    except:
        return {'main': {'temp': '???', 'feels_like': '???'}, 'pop': '???', 'dt_txt': f'{str_now_3h}'}

def convert_to_celsius(kelvin):
    '''Converts Kelvin to Celcius'''
    try:
        kelvin = float(kelvin)
        return round(kelvin-273.15)
    except:
        return '???'

def convert_to_percent(number):
    '''Converts float to percentage'''
    try:
        number = float(number)
        return round(number*100)
    except:
        return '???'

def check_time(time: str):
    '''Checks that time given as agrument is current time +-10sec.
       Given argument must be a string in form YYYY-MM-DD HH:MM:SS.
    '''
    time = datetime.datetime.strptime(time, "%Y-%m-%d %H:%M:%S")
    now_10_more = now + datetime.timedelta(seconds=10)
    now_10_less = now - datetime.timedelta(seconds=10)
    return now_10_less < time < now_10_more



# infoscreen-urls 
ip = os.environ.get("TEST_IP", "localhost:80")
admin_url = f'http://{ip}/admin/'
oulu_url =  f'http://{ip}/infoscreen/Oulu/'
helsinki_url = f'http://{ip}/infoscreen/Helsinki/'
kuopio_url = f'http://{ip}/infoscreen/Kuopio/'
tampere_url = f'http://{ip}/infoscreen/Tampere/'

# browsers
browser = 'headlesschrome'
browser2 = 'headlessfirefox'
browser3 = 'chrome'

# credentials
valid_user = os.environ.get('DJANGO_SUPERUSER_NAME', 'Supertest')
valid_password = os.environ.get('DJANGO_SUPERUSER_PASSWORD', 'keksitty-salasana')

# datetime-objects
today = datetime.date.today()
tomorrow = today + datetime.timedelta(days=1)
day_after_tomorrow = today + datetime.timedelta(days=2)
yesterday = today + datetime.timedelta(days=-1)

now = datetime.datetime.now()
time = now.strftime("%H:%M:%S")
minute_later = (now + datetime.timedelta(minutes=1)).strftime("%H:%M:%S")

# datetime-objects for the weather
now_3h = three_hour_time()
str_now_3h = now_3h.strftime("%Y-%m-%d %H:%M:%S")[0:19]
now_3h_weather = datetime.datetime.strptime(get_weather(str_now_3h, 'Helsinki')['dt_txt'], '%Y-%m-%d %H:%M:%S')
str_tmr_3h = (now_3h_weather + datetime.timedelta(days=1)).replace(hour=(now_3h_weather.hour // 3) * 3, minute=0, second=0).strftime("%Y-%m-%d %H:%M:%S")
str_day_after_tmr_3h = (now_3h_weather + datetime.timedelta(days=2)).replace(hour=(now_3h_weather.hour // 3) * 3, minute=0, second=0).strftime("%Y-%m-%d %H:%M:%S")


