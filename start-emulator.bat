@echo off
setlocal enabledelayedexpansion

cd /d "%ANDROID_HOME%\emulator" 2>nul || cd /d "%ANDROID_SDK_ROOT%\emulator" 2>nul || (
   echo Error: Cannot find Android SDK emulator directory
   exit /b 1
)

echo Available devices:
set i=0
for /f "tokens=*" %%a in ('emulator.exe -list-avds') do (
   set /a i+=1
   echo  !i!. %%a
)

set /p selection="Select device (1-%i%): "

set j=0
for /f "tokens=*" %%a in ('emulator.exe -list-avds') do (
   set /a j+=1
   if !j!==!selection! (
       echo Starting %%a...
       emulator.exe -avd %%a -no-boot-anim -gpu host
       exit /b
   )
)

echo Invalid selection