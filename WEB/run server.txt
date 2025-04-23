@echo off
cd /d "D:\College\4th\Graduation Project\simple_task\backend"
call flutter\Scripts\activate
cd flutter\project
python manage.py runserver
pause
