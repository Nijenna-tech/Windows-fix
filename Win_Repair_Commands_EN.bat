@echo off
setlocal
title Windows Repair and Network Tool (SFC ^& DISM)

:: Check for admin rights and restart if necessary
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [Info] No administrator rights detected. Restarting as administrator...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo        Check and Repair Windows System Files
echo ========================================================
echo.

:: 1. SFC /scannow
choice /c JN /m "1. Check Windows start and system files sfc /scannow"
if errorlevel 2 (
    echo Skipped.
    echo.
) else (
    echo.
    echo Starting SFC...
    sfc /scannow
    echo.
    echo --------------------------------------------------------
)

:: 2. DISM CheckHealth
choice /c JN /m "2. Check DISM image for corruption CheckHealth"
if errorlevel 2 (
    echo Skipped.
    echo.
) else (
    echo.
    echo Starting DISM CheckHealth...
    Dism /Online /Cleanup-Image /CheckHealth
    echo.
    echo --------------------------------------------------------
)

:: 3. DISM ScanHealth
choice /c JN /m "3. Deep scan DISM image ScanHealth"
if errorlevel 2 (
    echo Skipped.
    echo.
) else (
    echo.
    echo Starting DISM ScanHealth...
    Dism /Online /Cleanup-Image /ScanHealth
    echo.
    echo --------------------------------------------------------
)

:: 4. DISM RestoreHealth
choice /c JN /m "4. Repair DISM image RestoreHealth"
if errorlevel 2 (
    echo Skipped.
    echo.
) else (
    echo.
    echo Starting DISM RestoreHealth...
    Dism /Online /Cleanup-Image /RestoreHealth
    echo.
    echo --------------------------------------------------------
)

echo ========================================================
echo                      Network Options
echo ========================================================
echo.

:: 5. Reassign IP address
choice /c JN /m "5. Do you want to reassign your IP address"
if errorlevel 2 (
    echo IP address was not reassigned.
    echo.
) else (
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
)

:: 6. Clear DNS cache
choice /c JN /m "6. Do you want to flush your DNS cache"
if errorlevel 2 (
    echo DNS cache was not flushed.
    echo.
) else (
    echo.
    ipconfig /flushdns
    echo.
    echo DNS cache successfully flushed.
    echo --------------------------------------------------------
)

echo ========================================================
echo                      Drive Options
echo ========================================================
echo.

:: 7. Disk check (chkdsk) on all drives
choice /c JN /m "7. Check all drives for errors chkdsk"
if errorlevel 2 (
    echo Skipped.
    echo.
) else (
    echo.
    echo Determining available drives...
    for /f "delims=" %%d in ('powershell -NoProfile -Command "Get-Volume | Where-Object {$_.DriveLetter} | Select-Object -ExpandProperty DriveLetter"') do (
        echo Scheduling chkdsk for drive %%d:...
        echo Y | chkdsk %%d: /f /r >nul 2>&1
    )
    echo.
    echo All drives have been scheduled for the next system startup.
    echo --------------------------------------------------------
)

echo ========================================================
echo                     Memory Options
echo ========================================================
echo.

:: 8. Check RAM / Memory (mdsched)
choice /c JN /m "8. Check memory for errors mdsched restart required"
if errorlevel 2 (
    echo Skipped.
    echo.
) else (
    echo.
    echo Starting Windows Memory Diagnostic...
    mdsched.exe
    echo Memory diagnostic has been prepared/started.
    echo --------------------------------------------------------
)

echo ========================================================
echo All selected procedures have been completed.
echo ========================================================
endlocal
pause
