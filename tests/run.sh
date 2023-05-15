#!/bin/bash

echo 'Testing infoscreen with Chrome and Firefox'

# All tests using Pabot
#pabot --argumentfile1 args_chrome.txt --argumentfile2 args_firefox.txt\
#      -d ./logs/login_tests\
#      login_tests
#pabot --argumentfile1 args_chrome.txt --argumentfile2 args_firefox.txt\
#      -d ./logs/admin_tests\
#      admin_tests
#pabot --argumentfile1 args_chrome.txt --argumentfile2 args_firefox.txt\
#      --testlevelsplit\
#      -d ./logs/ui_tests\
#      ui_tests


# Without performance test
robot -e Performance -d ./logs/chrome_tests --name Chrome .
robot -e Performance --argumentfile ./libs/args_firefox.txt -d ./logs/firefox_tests --name Firefox .

rebot -d logs/Infoscreen_logs --name Infoscreen\
      ./logs/chrome_tests/output.xml ./logs/firefox_tests/output.xml 

# Performance test only
# robot -i Performance -d ./logs/chrome_tests --name Chrome .
# robot -i Performance --argumentfile ./libs/args_firefox.txt -d ./logs/firefox_tests --name Firefox .
# 
# rebot -d logs/Infoscreen_logs --name Infoscreen\
#       ./logs/chrome_tests/output.xml ./logs/firefox_tests/output.xml 
