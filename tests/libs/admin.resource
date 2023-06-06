*** Settings ***
Library         SeleniumLibrary
Library         RPA.Images
Library         library.py
Resource        infoscreen.resource
Variables       library.py


*** Keywords ***
Add future release to Oulu
    [Documentation]     Adds a new release to infoscreen in Oulu that will be visible this time tomorrow.
    [Arguments]    ${heading}    ${text}
    Go To          ${admin_url} 
    Click Element  //a[@href='/admin/infoscreen/release/add/']
    Select From List By Label    id=id_release_locations    Oulu
    Input Text     id=id_release_title            ${heading}
    Input Text     id=id_release_body             ${text}
    Input Text     id=id_release_public_start_0   ${tomorrow}
    Input Text     id=id_release_public_start_1   ${time}
    Input Text     id=id_release_public_end_0     ${tomorrow}
    Input Text     id=id_release_public_end_1     ${minute_later}
    Choose File    id=id_release_file             ${CURDIR}${/}robo.png
    Input Text     id=id_release_duration_on_screen    3
    Assign Id To Element    //input[@name='_save']    Save
    Click Element  id=Save    
    Element Should Be Visible    //a[normalize-space()='${heading}']

Add release with picture
    [Documentation]     Adds a new release to selected infoscreen.
    ...                 Argument office has to be Helsinki, Tampere, Oulu, Kuopio or All.
    ...                 Picture has to be added to libs folder in .png form and argument picture is the file name 
    ...                 without .png.
    [Arguments]    ${office}    ${heading}    ${text}    ${picture}
    Go To    ${admin_url}
    Click Element    //a[@href='/admin/infoscreen/release/add/']
    IF    '${office}' == 'All'
        Select All From List    id=id_release_locations
    ELSE
        TRY
            Select From List By Label    id=id_release_locations    ${office}
        EXCEPT    
            Fail    Argument office has to be Helsinki, Tampere, Oulu, Kuopio or All
        END
    END
    Input Text     id=id_release_title                ${heading}
    Input Text     id=id_release_body                 ${text}
    Input Text     id=id_release_public_start_0       ${today}
    Input Text     id=id_release_public_start_1       ${time}
    Input Text     id=id_release_public_end_0         ${tomorrow}
    Input Text     id=id_release_public_end_1         ${time}
    Choose File    id=id_release_file                 ${CURDIR}${/}${picture}.png
    Input Text     id=id_release_duration_on_screen   3
    Assign Id To Element    //input[@name='_save']    Save
    Click Element  id=Save

Add release without picture
    [Documentation]     Adds a new release without picture to selected infoscreen.
    ...                 Argument office has to be Helsinki, Tampere, Oulu, Kuopio or All.
    [Arguments]    ${office}    ${heading}    ${text}
    Go To    ${admin_url}
    Click Element    //a[@href='/admin/infoscreen/release/add/']
    IF    '${office}' == 'All'
        Select All From List    id=id_release_locations
    ELSE
        TRY
            Select From List By Label    id=id_release_locations    ${office}
        EXCEPT    
            Fail    Argument office has to be Helsinki, Tampere, Oulu, Kuopio or All
        END
    END
    Input Text     id=id_release_title                 ${heading}
    Input Text     id=id_release_body                  ${text}
    Input Text     id=id_release_public_start_0        ${today}
    Input Text     id=id_release_public_start_1        ${time}
    Input Text     id=id_release_public_end_0          ${tomorrow}
    Input Text     id=id_release_public_end_1          ${time}
    Input Text     id=id_release_duration_on_screen    3
    Click Element  //input[@name='_save']

Assert added picture from Oulu screen
    [Documentation]     Testing that the added picture is on infoscreen in Oulu.
    ...                 Argument picture is file name without .png
    [Arguments]    ${picture}
    Open infoscreen                              Oulu
    Wait Until Element Is Visible                id=clock
    Element Should Be Visible                    id=releaseimage
    ${screen}=     Capture Element Screenshot    id=releaseimage
#    Find Template In Image    ${screen}    ${CURDIR}${/}${picture}.png
    Compare Images    ${screen}    ${CURDIR}${/}${picture}.png    threshold= 0.22    resize_candidate= True

Assert added release from all screens
    [Documentation]     Testing that the added release is on all infoscreens.
    [Arguments]    ${otsikko}    ${teksti}
    Open infoscreen               Oulu
    Wait Until Keyword Succeeds   5 x   3 s    Element Should Contain    id=topleft    ${otsikko}
    Element Should Contain        id=topleft    ${teksti}
    Open infoscreen               Tampere
    Wait Until Keyword Succeeds   5 x   3 s    Element Should Contain    id=topleft    ${otsikko}
    Element Should Contain        id=topleft    ${teksti}
    Open infoscreen               Kuopio
    Wait Until Keyword Succeeds   5 x   3 s    Element Should Contain    id=topleft    ${otsikko}
    Element Should Contain        id=topleft    ${teksti}
    Open infoscreen               Helsinki
    Wait Until Keyword Succeeds   5 x   3 s    Element Should Contain    id=topleft    ${otsikko}
    Element Should Contain        id=topleft    ${teksti}

Assert added release from Oulu screen
    [Documentation]     Testing that the added release is on infoscreen in Oulu.
    [Arguments]    ${heading}    ${text}
    Go To                        ${admin_url}
    Click element                //a[normalize-space()='Releases']
    Element Should Be Visible    //a[normalize-space()='${heading}']
    Open infoscreen              Oulu
    Wait Until Element Contains       id=topleft    ${heading}
    Element Should Contain       id=topleft    ${text}

Change release date to now
    Input Text     id=id_release_public_start_0    ${today}
    Input Text     id=id_release_public_start_1    ${time}
    Click Element  //input[@name='_save']

Change release contents
    [Arguments]    ${heading}  ${new_heading}  ${new_text}  ${new_picture}    
    Open release settings                   ${heading}
    Input Text     id=id_release_title      ${new_heading}
    Input Text     id=id_release_body       ${new_text}
    Choose File    id=id_release_file       ${CURDIR}${/}${new_picture}.png
    Click Element  //input[@name='_save']

Delete all releases
    Go To    ${admin_url}
    Click Element                     //a[normalize-space()='Releases']
    ${length}=    Get Element Count   //*[@id="result_list"]/tbody/tr
    IF    ${length} != ${0}  
        Select Checkbox               id=action-toggle
        Select from list by value     //*[@id="changelist-form"]/div[1]/label/select    delete_selected 
        Click Element                 //*[@id="changelist-form"]/div[1]/button
        Click Element                 //input[@value='Yes, I’m sure']
        Wait Until Keyword Succeeds    3x    3s    Title Should Be    Select release to change | Django site admin
        ${length}=     Get Element Count  //*[@id="result_list"]/tbody/tr
    END
    Should Be Equal    ${length}    ${0}

Delete release
    [Documentation]     Teardown that deletes selected release from infoscreen.
    [Arguments]         ${otsikko}
    Go To            ${admin_url}
    Click Element    //a[normalize-space()='Releases']
    Click Element    //a[normalize-space()='${otsikko}']
    Title Should Be  ${otsikko} | Change release | Django site admin
    Click Element    //a[@class='deletelink']
    Click Element    //input[@value='Yes, I’m sure']
    Title Should Be  Select release to change | Django site admin
    Page Should Not Contain Element    //a[normalize-space()='${otsikko}']

Download picture
    [Arguments]    ${otsikko}
    Click Element    //th[@class='field-release_title']//a[contains(text(),'${otsikko}')]
    ${link}=    Get Text    //a[contains(text(),'https://stinfoscreennfweadev.blob.core.windows.net/')]
    Open Browser    ${link}    chrome
    # kesken - tähän asti toimii, kuva latautuu downloads-kansioon // ei käytössä

Open release settings
    [Arguments]    ${heading} 
    Go To                   ${admin_url}
    Click Element           //a[normalize-space()='${heading}']
    Title Should Be         ${heading} | Change release | Django site admin

Valid Login
    Go To              ${admin_url}
    Title Should Be    Log in | Django site admin    
    Click Element      id=password-login
    Input Password     id=id_username    ${valid_user}
    Input Password     id=id_password    ${valid_password}
    Click Element      //input[@value='Log in']
    Title Should Be    Site administration | Django site admin
