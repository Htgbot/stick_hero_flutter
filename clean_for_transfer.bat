@echo off
setlocal

echo ==========================================
echo      Stick Hero - Clean for Transfer
echo ==========================================
echo.
echo This script will delete the 'build' folder and other generated files.
echo This reduces the project size significantly (often from 200MB+ to <5MB).
echo.
echo NOTE: The next time you run the project, it will take longer to build.
echo.

:PROMPT
set /P AREYOUSURE=Are you sure you want to clean the project? (Y/[N])?
if /I "%AREYOUSURE%" NEQ "Y" GOTO END

echo.
echo [1/2] Checking for Flutter...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Flutter not found in PATH. Attempting manual deletion of build folder...
    if exist "build" (
        rmdir /s /q "build"
        echo Deleted 'build' folder.
    )
    if exist ".dart_tool" (
        rmdir /s /q ".dart_tool"
        echo Deleted '.dart_tool' folder.
    )
) else (
    echo [2/2] Running flutter clean...
    call flutter clean
)

echo.
echo ==========================================
echo           CLEAN COMPLETE
echo ==========================================
echo.
echo You can now zip this folder and send it to your friend.
echo.
pause
exit /b 0

:END
echo Operation cancelled.
pause
