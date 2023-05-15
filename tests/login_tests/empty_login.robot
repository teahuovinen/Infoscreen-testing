*** Settings ***
Documentation   Testing infoscreen login with empty credentials.
...             By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...             by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.
Library         SeleniumLibrary
Variables       ../libs/library.py
Suite Setup     Open Browser     ${admin_url}    ${browser}
Test Template   Login should fail
Suite Teardown  Close browser

*** Test Cases ***
Empty username      ${EMPTY}         $valid_password
Empty password      ${valid_user}    ${EMPTY}
Both empty          ${EMPTY}         ${EMPTY}
    
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
    Title Should Be              Log in | Django site admin    
