@echo off
cd /d "%ANDROID_HOME%\emulator"
if errorlevel 1 (
    cd /d "%ANDROID_SDK_ROOT%\emulator"
)
emulator.exe -avd Pixel_7_Pro_API_35