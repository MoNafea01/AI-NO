@echo off
setlocal

:: Ask the user to enter the path to activate.bat
echo Enter the full path to your environment's activate.bat file:
set /p VENV_PATH=

:: Validate path
if not exist "%VENV_PATH%" (
    echo The file does not exist: %VENV_PATH%
    pause
    exit /b
)

:: Activate the environment
call "%VENV_PATH%"

:: Open new terminal window for Django server
start cmd /k "%VENV_PATH% && cd project && python manage.py runserver"

:: Run FastAPI server in current window
echo Starting server...
cd chatbot
uvicorn main:app --reload --host 0.0.0.0 --port 8080

endlocal
pause
