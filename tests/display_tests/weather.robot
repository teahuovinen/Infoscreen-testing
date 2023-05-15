*** Settings ***
Documentation  Testing weather forecast on infoscreens in all offices. Weather on infoscreen should 
...            match the information given by OpenWeather. 
...            There are sometimes delay with getting the weather info, so the test will run failed 
...            keywords up to three times. There is testcase in ui.robot that tests that weather is 
...            visible on infoscreen and getting information from OpenWeather. 
...            By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...            by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.
Library        SeleniumLibrary
Library        RequestsLibrary
Library        ../libs/library.py
Variables      ../libs/library.py
Resource       ../libs/infoscreen.resource
Test Setup     Open Browser       browser=${browser}  
Test Template  Weather forecast should be correct 
Test teardown  Close browser

*** Test Cases ***
Helsinki weather forecast should be correct    Helsinki
Oulu weather forecast should be correct        Oulu
Tampere weather forecast should be correct     Tampere
Kuopio weather forecast should be correct      Kuopio

*** Keywords ***
Weather forecast should be correct     
    [Documentation]       Tests if the forecast on infoscreen matches the forecast on Openweather api.
    ...                   Argument city must be Helsinki, Oulu, Tampere or Kuopio.
    [Arguments]    ${city}
    TRY
        ${weather_now} =             Get weather          ${str_now_3h}              ${city}
        Open infoscreen              ${city}
        Check the weather forecast    today               ${weather_now}
    EXCEPT
        TRY
        ${weather_now} =             Get weather          ${str_now_3h}              ${city}
        Open infoscreen              ${city}
        Check the weather forecast    today               ${weather_now}
        EXCEPT
        ${weather_now} =             Get weather          ${str_now_3h}              ${city}
        Open infoscreen              ${city}
        Check the weather forecast    today               ${weather_now}
        END
    END
    TRY
        ${weather_tmr} =             Get weather          ${str_tmr_3h}              ${city}
        Check the weather forecast    tomorrow            ${weather_tmr}
    EXCEPT
        TRY
        ${weather_tmr} =             Get weather          ${str_tmr_3h}              ${city}
        Check the weather forecast    tomorrow            ${weather_tmr}
    EXCEPT
        Open infoscreen              ${city}
        ${weather_tmr} =             Get weather          ${str_tmr_3h}              ${city}
        Check the weather forecast    tomorrow            ${weather_tmr}
        END
    END
    TRY
        ${weather_day_after_tmr} =   Get weather          ${str_day_after_tmr_3h}    ${city}
        Check the weather forecast    day after tomorrow  ${weather_day_after_tmr}
    EXCEPT
        TRY
        ${weather_day_after_tmr} =   Get weather          ${str_day_after_tmr_3h}    ${city}
        Check the weather forecast    day after tomorrow  ${weather_day_after_tmr}
    EXCEPT
        Open infoscreen              ${city}
        ${weather_day_after_tmr} =   Get weather          ${str_day_after_tmr_3h}    ${city}
        Check the weather forecast    day after tomorrow  ${weather_day_after_tmr}
        END
    END
    Log    ${str_now_3h}
    Log    ${str_tmr_3h}
    Log    ${str_day_after_tmr_3h}
    Log    ${weather_now}
    Log    ${weather_tmr}
    Log    ${weather_day_after_tmr}
