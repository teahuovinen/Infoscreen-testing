*** Settings ***
Documentation  Testing infoscreen login with valid credentials.
...            By default tests are using Headless Chrome, but can be run with Headless Firefox or Chrome
...            by using 'headlessfirefox'/(browser2) or 'chrome'/(browser3) as variable browser.
Library        SeleniumLibrary
Variables      ../libs/library.py

*** Test cases***
Valid login and logout
    Open Browser                 ${admin_url}  ${browser}
    Title Should Be              Log in | Django site admin
    Click Element                id=password-login
    Page Should Contain Element  id=id_username
    Input Text                   id=id_username    ${valid_user}
    Input Password               id=id_password    ${valid_password}
    Click Element                //input[@value='Log in']
    Title Should Be              Site administration | Django site admin
    Click Element                //button[@type='submit']
    Title Should Be              Logged out | Django site admin
    Close Browser

