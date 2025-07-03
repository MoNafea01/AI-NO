@echo off

echo =========================================
echo  Django Local Server Auto Setup
echo =========================================

:: Step 1: Check if Python is installed
where python >nul 2>nul
IF %ERRORLEVEL% NEQ 0 (
    echo Python not found. Downloading Python 3.12.10...
    powershell -Command "Invoke-WebRequest -Uri https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe -OutFile python_installer.exe"
    echo Installing Python...
    python_installer.exe /quiet InstallAllUsers=1 PrependPath=1
    echo Waiting for Python to finish setup...
    timeout /t 10 >nul
)

:: Step 2: Create virtual environment if not exists
IF EXIST venv (
    echo Virtual environment already exists.
) ELSE (
    echo Creating virtual environment...
    python -m venv aino_env
)

:: Step 3: Activate virtual environment
call aino_env\Scripts\activate.bat

:: Step 4: Install requirements (once only)
IF EXIST aino_env\installed.flag (
    echo Requirements already installed.
) ELSE (
    echo Installing Python packages for the first time...
    pip install --upgrade pip
    pip install -r requirements.txt
    echo done > aino_env\installed.flag
)

:: Step 5: Run Django server
cd project
echo Starting Django server at http://127.0.0.1:8000 ...
python manage.py runserver

:: Keep the window open after server stops
pause