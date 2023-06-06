*** Settings ***
Library         DocTest.VisualTest    treshold=${0.22}    show_diff=${true}    movement_detection= template
Library         RequestsLibrary
Library         RPA.Images
Library         SeleniumLibrary
Library         library.py
Variables       library.py

*** Keywords ***
Check the weather forecast
    [Documentation]    Tests if the weather forecast on infoscreen is the same that OpenWeather Api gives.
    ...                Variable day must be today, tomorrow or day after tomorrow.
    ...                Variable weather must be weather forecast in dictionary form, usually from Get Weather keyword.
    [Arguments]    ${day}    ${weather}
    IF       '${day}' == 'today' 
        ${timestamp}=    Set Variable  now
    ELSE IF  '${day}' == 'tomorrow' 
        ${timestamp}=    Set Variable  tomorrow
    ELSE IF  '${day}' == 'day after tomorrow' 
        ${timestamp}=    Set Variable  day_after_tomorrow
    END
    Run keyword and continue on failure   Element Should Contain    //div[@id='weatherbox_${timestamp}']/div[3]/h3[1]  ${weather}[main][temp]
    Run keyword and continue on failure   Element Should Contain    //div[@id='weatherbox_${timestamp}']/div[3]/h3[2]  ${weather}[main][feels_like]
    Run keyword and continue on failure   Element Should Contain    //div[@id='weatherbox_${timestamp}']/div[3]/h3[3]  ${weather}[pop]

Heading should be city name
    [Documentation]    Testing if infoscreen is on and has a correct city name as a header.
    [Arguments]        ${city}
    Open infoscreen           ${city}
    Element Should Contain    id=officetitle    ${city}

Infoscreen should give weather forecast
    [Documentation]     Testing if the weather forecast in infoscreen is visible and getting information 
    ...                 from OpenWeather api.
    [Arguments]    ${city}
    Open infoscreen                  ${city} 
    Wait Until Element Is Visible    id=weatherbox_now
    Element should not contain       id=weatherbox_now    ???

Logos should be visible and correct
    [Documentation]    Tests that Company logo and Yle logo are visible on infoscreen of given office. 
    ...                Argument city must be Helsinki, Oulu, Tampere or Kuopio.
    [Arguments]    ${city}
    Open infoscreen                              ${city}
    Element Should Be Visible                    id=companylogoimage
    ${logo}=     Capture Element Screenshot      id=companylogoimage    
    ${yle}=        Capture Element Screenshot    id=ylelogoimage
#    Find Template In Image    ${logo}    ${CURDIR}${/}company_logo.png
#    Find Template In Image    ${yle}     ${CURDIR}${/}yle_logo.png        tolerance=${0.1}
    Compare Images    ${logo}    ${CURDIR}${/}company_logo.png  threshold= 0.22    resize_candidate= True
    Compare Images    ${yle}     ${CURDIR}${/}yle_logo.png      threshold= 0.22    resize_candidate= True    

News should be visible
    [Documentation]     Tests that news are visible on infoscreen.
    [Arguments]    ${city}
    Open infoscreen              ${city}
    Element should be visible    id=news
    Element Text Should Not Be   id=news    ${EMPTY}

Open infoscreen
    [Documentation]    Opens infoscreen of selected city.
    ...                Argument city must be Helsinki, Oulu, Tampere or Kuopio.
    [Arguments]    ${city}
    IF          '${city}' == 'Oulu'
        Go to    ${oulu_url}
    ELSE IF     '${city}' == 'Helsinki'
        Go to    ${helsinki_url}
    ELSE IF     '${city}' == 'Tampere'
        Go to    ${tampere_url}
    ELSE IF     '${city}' == 'Kuopio'
        Go to    ${kuopio_url}
    END 
    Set Window Size    2000     1160

Oulu screen should be empty
    Open infoscreen            Oulu
    Page Should Contain        No releases available.

Oulu screen should not be empty
    Open infoscreen            Oulu
    Page Should Not Contain    No releases available.

Time should be now
    [Documentation]     Testing if the clock in infoscreen is on time.
    [Arguments]    ${city}
    Open infoscreen                  ${city} 
    Wait Until Element Is Visible    id=clock
    ${time}=    Get Time             id=clock
    ${time}=    Convert To String    ${time}
    Log                              ${time}
    Check time                       ${time}


    



