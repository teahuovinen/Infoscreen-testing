*** Settings ***
Documentation  Testing infoscreen by adding releases with different settings and deleting them.
...            Oulu screen is used as a main testing platform and kept otherwise empty.   
...            By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...            by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.

Library        SeleniumLibrary
Library        String
Resource       ../libs/admin.resource
Test Setup     Run keywords     Open Browser   ${admin_url}  ${browser}  AND  Valid login

***Variables***
${text}    Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.
...        Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.
...        Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.
...        Testitekstiä, jolla testataan, tuleeko infoscreenille tekstiä näkyviin.

*** Test Cases ***
Add future release and delete
    ${number}=    Generate random string    4            0123456789
    Set Test Variable                       ${heading}   Test heading ${number}
    Log                                     ${heading}
    Delete all releases
    Add future release to Oulu              ${heading}   ${text}
    Go To                                   ${oulu_url}
    Page Should Not Contain                 ${heading}
    [Teardown]    Run keywords    Delete release    ${heading}  AND  Close browser
    
Add multiple releases to Oulu and delete 
    [Documentation]    Adds two different releases on Oulu infoscreen and asserts that they are 
    ...                both visible regardless of which of them comes visible first.
    ${number1}=    Generate random string    4    0123456789
    ${number2}=    Generate random string    4    0123456789
    Set Test Variable    ${heading1}     Test heading ${number1}
    Set Test Variable    ${heading2}     Test heading ${number2}
    Delete all releases
    Add release with picture                Oulu    ${heading1}   ${text}    robo
    Add release with picture                Oulu    ${heading2}   ${text}    robo
    Oulu screen should not be empty
    TRY
        Assert added release from Oulu screen  ${heading1}  ${text}
        ${first_visible}=    Set variable    1
    EXCEPT
        Assert added release from Oulu screen  ${heading2}  ${text}
        ${first_visible}=    Set variable    2
    END
    Sleep    4
    IF         ${first_visible} == 1
        Assert added release from Oulu screen  ${heading2}  ${text}
    ELSE IF    ${first_visible} == 2
        Assert added release from Oulu screen  ${heading1}  ${text}
    ELSE
        Fail
    END
    [Teardown]  Run keywords    Delete release    ${heading1}  AND  Delete release    ${heading2}  AND  Close browser

Add release and change contents
    ${number}=    Generate random string    4            0123456789
    Set Test Variable                       ${heading}   Test heading ${number}
    Delete all releases
    Add release with picture                Oulu         ${heading}   ${text}    robo
    Assert added release from Oulu screen   ${heading}   ${text}
    Assert added picture from Oulu screen   robo
    Change release contents                 ${heading}    Changed heading    Changed text, changed text, changed text, changed text, changed text, changed text.    big_picture
    Assert added release from Oulu screen   Changed heading   Changed text, changed text, changed text, changed text, changed text, changed text.
    Assert added picture from Oulu screen   big_picture
    [Teardown]    Run keywords    Delete release    Changed heading  AND  Close browser

Add release and change date
    ${number}=    Generate random string    4            0123456789
    Set Test Variable                       ${heading}   Test heading ${number}
    Delete all releases
    Add future release to Oulu              ${heading}   ${text}
    Go To                                   ${oulu_url}
    Page Should Not Contain                 ${heading}
    Open release settings                   ${heading}
    Change release date to now
    Assert added release from Oulu screen   ${heading}   ${text} 
    [Teardown]    Run keywords    Delete release    ${heading}  AND  Close browser

Add release to all offices and delete
    ${number}=    Generate random string   4            0123456789
    Set Test Variable                      ${heading}   Test heading ${number}
    Delete all releases
    Add release with picture               All          ${heading}   ${text}    robo
    Assert added release from all screens  ${heading}   ${text}
    [Teardown]    Run keywords    Delete release    ${heading}  AND  Close browser

Add release with big picture
    ${number}=    Generate random string    4            0123456789
    Set Test Variable                       ${heading}   Test heading ${number}
    Delete all releases
    Add release with picture                Oulu         ${heading}   ${text}${text}    big_picture
    Assert added release from Oulu screen   ${heading}   ${text}${text}
    Assert added picture from Oulu screen   big_picture
    [Teardown]    Run keywords    Delete release    ${heading}  AND  Close browser

Add release with picture to Oulu and delete
    ${number}=    Generate random string    4    0123456789
    Set Test Variable                       ${heading}     Test heading ${number}
    Delete all releases
    Add release with picture                Oulu    ${heading}   ${text}    robo
    Oulu screen should not be empty
    Assert added release from Oulu screen   ${heading}   ${text}
    Assert added picture from Oulu screen   robo
    [Teardown]    Run keywords    Delete release    ${heading}     AND    Close browser

Add release without picture to Oulu and delete
    ${number}=    Generate random string   4            0123456789
    Set Test Variable                      ${heading}   Test heading ${number}
    Delete all releases
    Add release without picture            Oulu         ${heading}   ${text}
    Oulu screen should not be empty
    Wait Until Page Contains               ${heading}  
    Assert added release from Oulu screen  ${heading}   ${text}
    [Teardown]    Run keywords    Delete release    ${heading}  AND  Close browser

Try to add release with longer texts    
    [Documentation]    Tries to add a new release to Oulu infoscreen with heading of more than 100 charachters 
    ...                and with text of more than 700 charachters. Release should not be saved and Oulu infoscreen 
    ...                should remain empty.
    Delete all releases
    ${number}=    Generate random string    101       0123456789
    Add release without picture             Oulu      ${number}   ${text}${text}${text}
    Element Should Contain    //*[@id="release_form"]/div/fieldset/div[2]/ul/li    Ensure this value has at most 100 characters 
    Element Should Contain    //*[@id="release_form"]/div/fieldset/div[3]/ul/li    Ensure this value has at most 700 characters 
    Oulu screen should be empty
    Close Browser

Try to add release without heading
    Delete all releases
    Click Element  //a[@href='/admin/infoscreen/release/add/']
    Select From List By Label    id=id_release_locations    Oulu
    Input Text     id=id_release_body                       ${text}
    Input Text     id=id_release_public_start_0             ${today}
    Input Text     id=id_release_public_start_1             ${time}
    Input Text     id=id_release_public_end_0               ${tomorrow}
    Input Text     id=id_release_public_end_1               ${time}
    Input Text     id=id_release_duration_on_screen         3
    Click Element  //input[@name='_save']
    Element Should Be Visible    //li[normalize-space()='This field is required.'] 
    Oulu screen should be empty
    Close Browser


