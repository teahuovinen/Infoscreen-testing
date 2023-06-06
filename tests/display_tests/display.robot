*** Settings ***
Documentation  Testing infoscreen displays in all offices. 
...            By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...            by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.
Library        SeleniumLibrary
Resource       ../libs/infoscreen.resource
Test Setup     Open Browser       browser=${browser}  
Test teardown  Close Browser  

*** Test Cases ***
Infoscreen should be on
    Run Keyword And Continue On Failure    Heading should be city name                Oulu
    Run Keyword And Continue On Failure    Heading should be city name                Helsinki
    Run Keyword And Continue On Failure    Heading should be city name                Kuopio
    Run Keyword And Continue On Failure    Heading should be city name                Tampere

Logos should be visible and correct
    [Tags]    Logo
    Run Keyword And Continue On Failure    Logos should be visible and correct        Oulu
    Run Keyword And Continue On Failure    Logos should be visible and correct        Helsinki
    Run Keyword And Continue On Failure    Logos should be visible and correct        Kuopio
    Run Keyword And Continue On Failure    Logos should be visible and correct        Tampere    

Infoscreen clock should be on time
    Run Keyword And Continue On Failure    Time should be now                         Oulu
    Run Keyword And Continue On Failure    Time should be now                         Helsinki
    Run Keyword And Continue On Failure    Time should be now                         Kuopio
    Run Keyword And Continue On Failure    Time should be now                         Tampere

News should be visible               
    Run Keyword And Continue On Failure    News should be visible                     Oulu
    Run Keyword And Continue On Failure    News should be visible                     Helsinki
    Run Keyword And Continue On Failure    News should be visible                     Kuopio
    Run Keyword And Continue On Failure    News should be visible                     Tampere

Weather forecast should be visible
    Run Keyword And Continue On Failure    Infoscreen should give weather forecast    Oulu
    Run Keyword And Continue On Failure    Infoscreen should give weather forecast    Helsinki
    Run Keyword And Continue On Failure    Infoscreen should give weather forecast    Kuopio
    Run Keyword And Continue On Failure    Infoscreen should give weather forecast    Tampere



