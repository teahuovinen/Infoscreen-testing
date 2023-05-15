@echo off

echo Starting execution!

echo Testing with Chrome
robot -d ./logs/chrome --name Chrome .
echo Testing with Firefox
robot --argumentfile ./libs/args_firefox.txt -d ./logs/firefox --name Firefox .
rebot -d logs/Infoscreen_logs --name Infoscreen^
      ./logs/chrome/output.xml^
      ./logs/firefox/output.xml


rem pabot -d ./logs/login_tests login_tests
rem pabot -d ./logs/admin_tests admin_tests
rem pabot -d ./logs/ui_tests ui_tests

rem pabot --argumentfile1 args_chrome.txt --argumentfile2 args_firefox.txt^
rem       --testlevelsplit^
rem       -d ./logs/login_tests^
rem       login_tests
rem robot --variable browser:headlessfirefox
rem       -d ./logs/admin_tests_f^
rem       admin_tests
rem robot -d ./logs/admin_tests_c ^
rem       admin_tests
rem pabot --argumentfile1 args_chrome.txt --argumentfile2 args_firefox.txt^
rem       --testlevelsplit^
rem       -d ./logs/ui_tests^
rem       ui_tests

rem rebot -d logs/Infoscreen_logs --name Infoscreen^
rem       ./logs/login_tests/output.xml^
rem       ./logs/admin_tests/output.xml^
rem       ./logs/ui_tests/output.xml 



