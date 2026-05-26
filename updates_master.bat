@echo off
setlocal enabledelayedexpansion
chcp 65001 > nul

:init
set "BASE_DIR=%~dp0"
if "%BASE_DIR:~-1%"=="\" set "BASE_DIR=%BASE_DIR:~0,-1%"

set "ROOT_DIR=%BASE_DIR%\quare32"
set "SYS_DIR=%ROOT_DIR%\system"
set "CFG_DIR=%ROOT_DIR%\config"
set "APPS_DIR=%ROOT_DIR%\apps"
set "REC_DIR=%ROOT_DIR%\recovery"

:: Hardcoded Target GitHub Repository
set "REPO_URL=https://github.com/lastochka-app/inbleeltupdatesrepo"
set "RAW_URL=https://raw.githubusercontent.com/lastochka-app/inbleeltupdatesrepo/main"

title InbleltOS Update Manager v1.1
mode con: cols=85 lines=35
color 0A

:: Save current repository configuration for the OS kernel
if exist "%CFG_DIR%" (
    echo !REPO_URL!> "%CFG_DIR%\last_repo.cfg"
)

:: Check if system exists
if not exist "%ROOT_DIR%" (
    echo [ERROR] Quare32 system core directory not found.
    echo [ERROR] Please place updater.bat in the root folder alongside kernel.bat.
    pause
    exit /b
)

set "current_item=1"

:menu
cls
set "m1= " & set "m2= " & set "m3= " & set "m4= " & set "m5= " & set "m6= "
if "%current_item%"=="1" set "m1=[>] "
if "%current_item%"=="2" set "m2=[>] "
if "%current_item%"=="3" set "m3=[>] "
if "%current_item%"=="4" set "m4=[>] "
if "%current_item%"=="5" set "m5=[>] "
if "%current_item%"=="6" set "m6=[>] "

echo =====================================================================================
echo                I N B L E L T O S   U P D A T E   M A N A G E R
echo =====================================================================================
echo  Target Repository: %REPO_URL%
echo  System Directory : %ROOT_DIR%
echo =====================================================================================
echo  Use Arrow Keys (Up/Down) to navigate and Enter to select:
echo -------------------------------------------------------------------------------------
echo  %m1%1. Test Connection to InbleltOS GitHub Server
echo  %m2%2. Download ^& Install System Core Update (kernel.bat)
echo  %m3%3. Download Custom App Component from Repository
echo  %m4%4. View System Update History Logs (updater.log)
echo  %m5%5. Clear Web Cache and Temporary Data
echo  %m6%6. Exit Update Manager
echo =====================================================================================
echo  UP / DOWN - Navigate ^| ENTER - Execute Action
echo =====================================================================================

for /f "delims=" %%k in ('powershell -Command "$key = [Console]::ReadKey($true); if ($key.Key -eq 'UpArrow') { 'DOWN' } elseif ($key.Key -eq 'DownArrow') { 'UP' } elseif ($key.Key -eq 'Enter') { 'ENTER' }"') do set "pressed=%%k"

if "%pressed%"=="UP" (
    set /a current_item-=1
    if !current_item! lss 1 set "current_item=6"
    goto menu
)
if "%pressed%"=="DOWN" (
    set /a current_item+=1
    if !current_item! gtr 6 set "current_item=1"
    goto menu
)
if "%pressed%"=="ENTER" goto action
goto menu

:action
if "%current_item%"=="1" goto check_version
if "%current_item%"=="2" goto update_kernel
if "%current_item%"=="3" goto repo_download
if "%current_item%"=="4" goto view_log
if "%current_item%"=="5" goto clear_cache
if "%current_item%"=="6" exit /b

:check_version
cls
echo [INFO] Fetching local hardware configuration...
if exist "%CFG_DIR%\os_name.cfg" (
    set /p local_os=<"%CFG_DIR%\os_name.cfg"
) else (
    set "local_os=InbleltOS"
)
if exist "%CFG_DIR%\shell.cfg" (
    set /p local_shell=<"%CFG_DIR%\shell.cfg"
) else (
    set "local_shell=Unknown Shell"
)

echo -------------------------------------------------------------------------------------
echo  LOCAL ENVIRONMENT METRICS:
echo  OS Identity    : !local_os!
echo  Shell Revision : !local_shell!
echo  Target Server  : %REPO_URL%
echo -------------------------------------------------------------------------------------
echo [INFO] Connecting to GitHub server via curl...
curl -s -I -k "%REPO_URL%" > nul
if %errorlevel% neq 0 (
    echo [WARNING] GitHub Repository connection could not be established.
    echo [WARNING] Verify your network infrastructure or firewall.
) else (
    echo [SUCCESS] Secure channel active. Repository is reachable.
)
echo.
echo Press ENTER to return to menu...
pause > nul
goto menu

:update_kernel
cls
echo =====================================================================================
echo  SYSTEM OS CORE UPGRADE ENVIRONMENT (KERNEL.BAT)
echo =====================================================================================
echo  Source File: %RAW_URL%/kernel.bat
echo -------------------------------------------------------------------------------------
echo  Proceed with system update? (Y/N)
set /p confirm_update="Action > "
if /i not "%confirm_update%"=="y" goto menu

echo.
echo [INFO] Archiving existing kernel architecture...
if exist "%BASE_DIR%\kernel.bat" (
    copy /y "%BASE_DIR%\kernel.bat" "%REC_DIR%\kernel_bak.bat" > nul
    echo [SUCCESS] Recovery snapshot deployed to \quare32\recovery\kernel_bak.bat
)

echo [INFO] Fetching core modules from GitHub main branch...
curl -s -k "%RAW_URL%/kernel.bat" > "%BASE_DIR%\kernel_new.bat"

if %errorlevel% neq 0 (
    echo [ERROR] Network download failed. Aborting deployment.
    del "%BASE_DIR%\kernel_new.bat" 2>nul
    pause
    goto menu
)

:: Structural size verification
for /f %%i in ("%BASE_DIR%\kernel_new.bat") do set size=%%~zi
if "%size%"=="" set size=0
if %size% lss 500 (
    echo [ERROR] Validation failure: Remote file is corrupt or missing (404 Error).
    echo [ERROR] Make sure kernel.bat exists in the root of your repository.
    del "%BASE_DIR%\kernel_new.bat" 2>nul
    pause
    goto menu
)

echo [INFO] Recompiling system core...
move /y "%BASE_DIR%\kernel_new.bat" "%BASE_DIR%\kernel.bat" > nul
echo [%date% %time:~0,5%] UPDATE: Kernel successfully synchronized with GitHub >> "%SYS_DIR%\updater.log"
echo.
echo [SUCCESS] Upgrade complete. Core system modules updated.
echo [SUCCESS] Please relaunch kernel.bat to initialize new system routines.
echo.
echo Press ENTER to return...
pause > nul
goto menu

:repo_download
cls
echo =====================================================================================
echo  INBLELTOS APPLICATION REPOSITORY DISTRIBUTION
echo =====================================================================================
echo  Target Path: %RAW_URL%/apps/
echo -------------------------------------------------------------------------------------
echo  Enter application file name located inside your repo's app directory
echo  Example: TextEditor.bat or Calculator.bat
echo -------------------------------------------------------------------------------------
set "app_file="
set /p app_file="App Filename > "
if not defined app_file goto menu

echo.
echo [INFO] Establishing server request pipeline...
curl -s -k "%RAW_URL%/apps/%app_file%" > "%APPS_DIR%\%app_file%"

if %errorlevel% neq 0 (
    echo [ERROR] Transfer failed. File may not exist in /apps/ subfolder on GitHub.
    del "%APPS_DIR%\%app_file%" 2>nul
    pause
    goto menu
)

:: Validate size to avoid downloading GitHub 404 text pages
for /f %%i in ("%APPS_DIR%\%app_file%") do set app_size=%%~zi
if "%app_size%"=="" set app_size=0
if %app_size% lss 100 (
    echo [ERROR] Application file invalid or path not found on server.
    del "%APPS_DIR%\%app_file%" 2>nul
    pause
    goto menu
)

echo [%date% %time:~0,5%] RESOURCE: Installed custom app %app_file% from GitHub >> "%SYS_DIR%\updater.log"
echo [SUCCESS] Module compiled and extracted to \quare32\apps\%app_file%
echo.
echo Press ENTER to return...
pause > nul
goto menu

:view_log
cls
echo =====================================================================================
echo  SYSTEM MAINTENANCE AND UPDATE ARCHIVE LOGS (updater.log)
echo =====================================================================================
if exist "%SYS_DIR%\updater.log" (
    type "%SYS_DIR%\updater.log"
) else (
    echo  [EMPTY] No history discovered. Execute upgrade operations first.
)
echo =====================================================================================
echo Press ENTER to return...
pause > nul
goto menu

:clear_cache
cls
echo [INFO] Scanning for temporary compilation blocks...
if exist "%BASE_DIR%\kernel_new.bat" (
    del "%BASE_DIR%\kernel_new.bat"
)
if exist "%SYS_DIR%\web_cached.bat" (
    del "%SYS_DIR%\web_cached.bat"
    echo [SUCCESS] Purged temporary web storage entries.
)
echo [INFO] System cache restructuring completed.
echo [%date% %time:~0,5%] SYSTEM: Executed cache clean utilities >> "%SYS_DIR%\updater.log"
echo.
echo Press ENTER to return to interface dashboard...
pause > nul
goto menu
