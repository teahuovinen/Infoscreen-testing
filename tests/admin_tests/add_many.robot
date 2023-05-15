*** Settings ***
Documentation  Testing infoscreen by adding releases with different settings and deleting them.
...            Oulu screen is used as a main testing platform and kept otherwise empty.   
...            By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...            by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.

Library        SeleniumLibrary
Resource       ../libs/admin.resource
Test Setup     Run keywords     Open Browser   ${admin_url}  ${browser}  AND  Valid login

***Variables***
${text}    Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.
...        Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.
...        Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.
...        Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.

*** Test Cases ***
Infoscreen should show only one release at a time
    [Documentation]    Adds three releases to Oulu infoscreen and verifies, that they are shown
    ...                one at a time. 
    Delete all releases
    ${number}=    Set Variable     101
    FOR    ${index}    IN RANGE    0    3
        Add release without picture     Oulu    ${number}    ${text}
        ${number}=    Evaluate          ${number}+1
    END
    Open infoscreen                     Oulu
    Oulu screen should not be empty
    Page Should Contain                 ${text}
    Wait Until Element Is Visible       id=clock
    ${releases}=    Get Element Count   id=releasetitletext
    Should Be Equal                     ${releases}    ${3}
    TRY
        Element Should Contain      id=topleft        101
        Element Should Not Contain  id=topleft        102
        Element Should Not Contain  id=topleft        103
    EXCEPT
        TRY
        Element Should Contain      id=topleft        102
        Element Should Not Contain  id=topleft        101
        Element Should Not Contain  id=topleft        103
        EXCEPT
        Element Should Contain      id=topleft        103
        Element Should Not Contain  id=topleft        101
        Element Should Not Contain  id=topleft        102
        END
    END
    [Teardown]    Run keywords    Delete all releases    AND    Close browser

Add 100 releases without picture to Oulu screen
    [Tags]    Performance
    [Documentation]    Adds 100 releases to Oulu infoscreen, one at a time. 
    ...                With this test number of releases cannot be bigger, because only 100 releases are 
    ...                shown in a same list on admin page. To test with bigger number of releases, add "release
    ...                all" keyword accordingly. 
    Delete all releases
    ${number}=    Set Variable         1
    ${length}=    Get Element Count    //*[@id="result_list"]/tbody/tr
    IF    ${length} > ${0}    
        Delete all releases
    END
    Oulu screen should be empty
    FOR    ${index}    IN RANGE    0    100
        Add release without picture    Oulu    ${number}    ${text}
        IF    ${number}%10 == 0
        Log To Console    ${number}
        END
        ${number}=    Evaluate         ${number}+1
    END
    ${length}=    Get Element Count    //*[@id="result_list"]/tbody/tr
    Should Be Equal                    ${length}    ${100}
    Open infoscreen                    Oulu
    Wait Until Element Is Visible      id=clock
    Capture Page Screenshot            selenium-screenshot-100_added.png
    Element Should Contain             id=topleft    ${text} 
    [Teardown]    Run keywords    Delete all releases    AND    Close browser

Add 100 releases with picture to Oulu screen
    [Tags]    Performance
    [Documentation]    Adds 100 releases to Oulu infoscreen, one at a time. 
    ...                With this test number of releases cannot be bigger, because only 100 releases are 
    ...                shown in a same list on admin page. To test with bigger number of releases, add "release
    ...                all" keyword accordingly.
    Delete all releases
    ${number}=    Set Variable         1
    ${length}=    Get Element Count    //*[@id="result_list"]/tbody/tr
    IF    ${length} > ${0}    
        Delete all releases
    END
    Oulu screen should be empty
    FOR    ${index}    IN RANGE        0    100
        Add release with picture       Oulu    ${number}    ${text}    robo
        IF    ${number}%10 == 0
        Log To Console                 ${number}
        END
        ${number}=    Evaluate         ${number}+1
    END
    ${length}=    Get Element Count    //*[@id="result_list"]/tbody/tr
    Should Be Equal                    ${length}    ${100}
    Open infoscreen                    Oulu
    Wait Until Element Is Visible      id=clock
    Capture Page Screenshot            selenium-screenshot-100_pictures_added.png
    Element Should Contain             id=topleft    ${text} 
    [Teardown]    Run keywords    Delete all releases    AND    Close browser

