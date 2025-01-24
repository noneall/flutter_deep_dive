# start-emulator.bat
@echo off

set DEFAULT_AVD=Pixel_7_Pro_API_35

if exist .env (
    for /f "tokens=1,2 delims==" %%G in (.env) do set %%G=%%H
)

if not defined AVD_NAME set AVD_NAME=%DEFAULT_AVD%

cd /d "%ANDROID_HOME%\emulator" 2>nul || cd /d "%ANDROID_SDK_ROOT%\emulator" 2>nul || (
    echo Error: Cannot find Android SDK emulator directory
    exit /b 1
)

emulator.exe -avd %AVD_NAME% -no-boot-anim -gpu host || (
    echo.
    echo AVD '%AVD_NAME%' not found. Available AVDs:
    emulator.exe -list-avds
    exit /b 1
)