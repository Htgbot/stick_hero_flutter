@echo off
setlocal

echo ==========================================
echo      Stick Hero - Run Game
echo ==========================================

REM 1. Check for Flutter SDK
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Flutter is not found in your PATH!
    echo.
    echo Please install Flutter before running this script.
    echo.
    pause
    exit /b 1
)

REM 2. Initialize Project (if needed)
if not exist "android" (
    echo [1/3] Initializing project structure...
    call flutter create .
    
    echo [1.5/3] Adding Permissions...
    if exist "android\app\src\main\AndroidManifest.xml" (
        powershell -Command "(Get-Content android\app\src\main\AndroidManifest.xml) -replace '<application', '<uses-permission android:name=\"android.permission.VIBRATE\"/>`n    <application' | Set-Content android\app\src\main\AndroidManifest.xml"
    )
)

REM 3. Install Dependencies
echo [2/3] Installing dependencies...
call flutter pub get

REM 4. Run
echo [3/3] Launching Game...
echo.
echo Please connect your device or start an emulator.
echo If you want to run on Windows, ensure Visual Studio is installed.
echo.
call flutter run

pause
