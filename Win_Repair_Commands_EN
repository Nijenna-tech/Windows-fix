@echo off
setlocal
title Windows Repair and Network Tool (SFC ^& DISM)

:: Admin-Rechte prüfen und ggf. neu starten
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [Info] No administrator rights detected. Restarting as administrator...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo         Check and Repair Windows System Files
echo ========================================================
echo.

:: 1. SFC /scannow
set /p "runSFC=1. Check Windows start and system files (sfc /scannow)? (Y/N): "
if /i "%runSFC%"=="Y" (
    echo.
    echo Starting SFC...
    sfc /scannow
    echo.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

:: 2. DISM CheckHealth
set /p "runCheck=2. Check DISM image for corruption (CheckHealth)? (Y/N): "
if /i "%runCheck%"=="Y" (
    echo.
    echo Starting DISM CheckHealth...
    Dism /Online /Cleanup-Image /CheckHealth
    echo.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

:: 3. DISM ScanHealth
set /p "runScan=3. Deep-scan DISM image (ScanHealth)? (Y/N): "
if /i "%runScan%"=="Y" (
    echo.
    echo Starting DISM ScanHealth...
    Dism /Online /Cleanup-Image /ScanHealth
    echo.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

:: 4. DISM RestoreHealth
set /p "runRestore=4. Repair DISM image (RestoreHealth)? (Y/N): "
if /i "%runRestore%"=="Y" (
    echo.
    echo Starting DISM RestoreHealth...
    Dism /Online /Cleanup-Image /RestoreHealth
    echo.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

echo ========================================================
echo                    Drive Options
echo ========================================================
echo.

:: 5. Festplatten-Überprüfung (chkdsk) auf allen Laufwerken
set /p "runChk=5. Check all drives for errors (chkdsk /f /r - requires reboot)? (Y/N): "
if /i "%runChk%"=="Y" (
    echo.
    echo Determining all available drives...
    for /f "tokens=1" %%d in ('wmic logicaldisk get deviceid ^| findstr /r "[A-Z]"') do (
        echo Scheduling chkdsk for drive %%d...
        echo Y | chkdsk %%d /f /r >nul 2>&1
    )
    echo.
    echo All drives have been scheduled for the next system restart.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

:: 6. Laufwerke optimieren (Defragmentierung für HDDs / TRIM für SSDs)
set /p "runOpt=6. Optimize all drives (Defrag/TRIM depending on drive type)? (Y/N): "
if /i "%runOpt%"=="Y" (
    echo.
    echo Starting optimization for all drives (Windows automatically detects SSD/HDD)...
    defrag /C /U /V
    echo.
    echo Drive optimization completed.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

echo ========================================================
echo                    Network Options
echo ========================================================
echo.

:: 7. IP-Adresse neu zuweisen
set /p "runIP=7. Do you want to reassign your IP address? (Y/N): "
if /i "%runIP%"=="Y" (
    echo.
    ipconfig /release
    echo.
    echo Your IP address has been released...
    echo A new one will be automatically assigned in 5 seconds...
    timeout /t 5 /nobreak >nul
    ipconfig /renew
    echo.
    echo Your IP address has now been reassigned...
    echo --------------------------------------------------------
) else (
    echo IP address was not reassigned.
    echo.
)

:: 8. DNS-Cache leeren
set /p "runDNS=8. Do you want to flush your DNS cache? (Y/N): "
if /i "%runDNS%"=="Y" (
    echo.
    ipconfig /flushdns
    echo.
    echo DNS cache was successfully flushed.
    echo --------------------------------------------------------
) else (
    echo DNS cache was not flushed.
    echo.
)

echo ========================================================
echo                     Memory Options
echo ========================================================
echo.

:: 9. RAM / Arbeitsspeicher prüfen (mdsched)
set /p "runRAM=9. Check RAM for errors (mdsched - requires reboot)? (Y/N): "
if /i "%runRAM%"=="Y" (
    echo.
    echo Starting Windows Memory Diagnostic...
    mdsched.exe
    echo The memory diagnostic has been prepared/started.
    echo --------------------------------------------------------
) else (
    echo Skipped.
    echo.
)

echo ========================================================
echo All selected operations have been completed.
echo ========================================================
pause
