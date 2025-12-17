@echo off
setlocal

echo ==========================================
echo      Stick Hero Flutter Build Script
echo ==========================================

REM 1. Check for Flutter SDK
echo [1/5] Checking for Flutter...
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Flutter is not found in your PATH!
    echo.
    echo Please install Flutter before running this script:
    echo 1. Download Flutter from https://flutter.dev/docs/get-started/install
    echo 2. Extract it to a folder (e.g., C:\src\flutter)
    echo 3. Add 'C:\src\flutter\bin' to your User Path Environment Variable.
    echo 4. Restart this terminal.
    echo.
    pause
    exit /b 1
)
echo Flutter found.

REM 2. Initialize Project (Generate Android/iOS folders)
echo [2/5] Initializing Flutter project...
call flutter create .
if %errorlevel% neq 0 (
    echo [ERROR] Failed to initialize project.
    pause
    exit /b 1
)

REM 3. Add Permissions to Android Manifest
echo [3/5] Adding Vibration Permission to Android Manifest...
if exist "android\app\src\main\AndroidManifest.xml" (
    powershell -Command "(Get-Content android\app\src\main\AndroidManifest.xml) -replace '<application', '<uses-permission android:name=\"android.permission.VIBRATE\"/>`n    <application' | Set-Content android\app\src\main\AndroidManifest.xml"
    echo Permission added.
) else (
    echo [WARNING] AndroidManifest.xml not found. Skipping permission injection.
)

REM 4. Install Dependencies
echo [4/5] Installing dependencies...
call flutter pub get

REM 5. Build APK
echo [5/5] Building Release APK...
call flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ==========================================
    echo        BUILD SUCCESSFUL!
    echo ==========================================
    echo.
    echo The APK is located at:
    echo build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo You can now install it on your device.
) else (
    echo.
    echo [ERROR] Build failed. Check the logs above.
)

pause
