@echo off
call flutter\Scripts\activate
cd ..\project
python manage.py runserver
pause
