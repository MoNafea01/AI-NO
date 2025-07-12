@echo off

call "D:\College\4th\Graduation Project\simple_task\backend\flutter\Scripts\activate.bat"

cd /d "D:\College\4th\Graduation Project\simple_task\chatbot"

uvicorn main:app --reload --host 0.0.0.0 --port 8080

pause
