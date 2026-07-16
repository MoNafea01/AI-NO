@echo off
setlocal

:: Define the path to cloc and the project directory
set CLOC_EXE=cloc-2.04.exe
set "PROJECT_DIR=..\..\"
set EXCLUDE_FILE=exclude.txt

echo Counting lines of code...
%CLOC_EXE% %PROJECT_DIR% --include-lang=Python --exclude-list-file=%EXCLUDE_FILE%
pause

endlocal
