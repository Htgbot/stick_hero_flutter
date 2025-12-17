@echo off
setlocal EnableDelayedExpansion

echo ===================================================
echo      Stick Hero - Ultimate One-Click Builder
echo ===================================================
echo.

REM ---------------------------------------------------
REM 1. CHECK FOR FLUTTER
REM ---------------------------------------------------
echo [1/6] Checking for Flutter SDK...

REM A. Check PATH
where flutter >nul 2>nul
if %errorlevel% equ 0 (
    echo    - Found Flutter in PATH.
    goto CHECK_PROJECT
)

REM B. Check Local Folder
if exist "flutter\bin\flutter.bat" (
    echo    - Found local Flutter copy.
    set "PATH=%CD%\flutter\bin;%PATH%"
    goto CHECK_PROJECT
)

REM C. INSTALL FLUTTER
echo    - Flutter NOT found.
echo.
echo    ===================================================
echo    [ATTENTION] Flutter is required to build this app.
echo    I can download and install it locally for you.
echo    SIZE: ~1 GB download.
echo    ===================================================
echo.
set /P INSTALL_FLUTTER="Do you want to download Flutter now? (Y/N): "
if /I "%INSTALL_FLUTTER%" NEQ "Y" (
    echo.
    echo    Build cancelled. Flutter is required.
    pause
    exit /b 1
)

echo.
echo    [Downloading Flutter SDK...]
echo    Please wait. This may take 5-10 minutes depending on internet speed.
echo.

REM Use PowerShell to download
powershell -Command "Invoke-WebRequest -Uri 'https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.22.0-stable.zip' -OutFile 'flutter.zip'"

if not exist "flutter.zip" (
    echo    [ERROR] Download failed. Please check your internet connection.
    pause
    exit /b 1
)

echo.
echo    [Extracting Flutter SDK...]
echo    This takes a while...
powershell -Command "Expand-Archive -Path 'flutter.zip' -DestinationPath '.'"

echo    [Cleaning up...]
del flutter.zip

REM Set PATH
if exist "flutter\bin\flutter.bat" (
    echo    - Installation successful!
    set "PATH=%CD%\flutter\bin;%PATH%"
) else (
    echo    [ERROR] Installation failed.
    pause
    exit /b 1
)

:CHECK_PROJECT
REM ---------------------------------------------------
REM 2. INITIALIZE PROJECT
REM ---------------------------------------------------
echo.
echo [2/6] Initializing Project...
call flutter config --no-analytics >nul 2>nul

if not exist "android" (
    echo    - Generating Android/iOS files...
    call flutter create .
)

REM ---------------------------------------------------
REM 3. PATCH PERMISSIONS
REM ---------------------------------------------------
echo.
echo [3/6] Configuring Permissions...
if exist "android\app\src\main\AndroidManifest.xml" (
    powershell -Command "(Get-Content android\app\src\main\AndroidManifest.xml) -replace '<application', '<uses-permission android:name=\"android.permission.VIBRATE\"/>`n    <application' | Set-Content android\app\src\main\AndroidManifest.xml"
    echo    - Vibration permission added.
)

REM ---------------------------------------------------
REM 4. INSTALL DEPENDENCIES
REM ---------------------------------------------------
echo.
echo [4/6] Installing Dependencies...
call flutter pub get

REM ---------------------------------------------------
REM 5. BUILD APK
REM ---------------------------------------------------
echo.
echo [5/6] Building APK (Release Mode)...
echo    This process takes about 2-5 minutes.
call flutter build apk --release

if %errorlevel% neq 0 (
    echo.
    echo    [ERROR] Build Failed!
    echo    Please check the logs above.
    pause
    exit /b 1
)

REM ---------------------------------------------------
REM 6. FINISH
REM ---------------------------------------------------
echo.
echo ===================================================
echo               BUILD SUCCESSFUL!
echo ===================================================
echo.
echo The APK is ready:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk
echo.
echo Opening folder...
explorer "build\app\outputs\flutter-apk"

pause
