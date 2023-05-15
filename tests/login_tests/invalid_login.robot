*** Settings ***
Documentation   Testing infoscreen login with invalid credentials.
...             By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...             by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.
Library         SeleniumLibrary
Variables       ../libs/library.py
Suite Setup     Open Browser    ${admin_url}    ${browser}
Test Template   Login should fail
Suite Teardown  Close browser

*** Test Cases ***
Invalid username    väärä            $valid_password
Invalid password    ${valid_user}    väärä
Both invalid        invalid          invalid

*** Keywords ***
Login should fail 
    [Arguments]                  ${username}    ${password}
    Go To                        ${admin_url}   
    Title Should Be              Log in | Django site admin
    Click Element                id=password-login
    Page Should Contain Element  id=id_username
    Input Text                   id=id_username    ${username}
    Input Password               id=id_password    ${password}
    Click Element                //input[@value='Log in']
    Element Should Contain       //p[@class='errornote']   Please enter the correct username and password for a staff account. Note that both fields may be case-sensitive.
    