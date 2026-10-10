@echo off
setlocal
title Windows Reparatur-Tool (SFC ^& DISM)

:: Admin-Rechte prüfen und ggf. neu starten
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [Info] Keine Administratorrechte erkannt. Starte neu als Administrator...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

echo ========================================================
echo        Windows Systemdateien pruefen und reparieren
echo ========================================================
echo.

:: 1. SFC /scannow
set /p "runSFC=1. Windows Start- und Systemdateien pruefen (sfc /scannow)? (J/N): "
if /i "%runSFC%"=="J" (
    echo.
    echo Starte SFC...
    sfc /scannow
    echo.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

:: 2. DISM CheckHealth
set /p "runCheck=2. DISM Image auf Beschaedigungen pruefen (CheckHealth)? (J/N): "
if /i "%runCheck%"=="J" (
    echo.
    echo Starte DISM CheckHealth...
    Dism /Online /Cleanup-Image /CheckHealth
    echo.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

:: 3. DISM ScanHealth
set /p "runScan=3. DISM Image tiefgehend scannen (ScanHealth)? (J/N): "
if /i "%runScan%"=="J" (
    echo.
    echo Starte DISM ScanHealth...
    Dism /Online /Cleanup-Image /ScanHealth
    echo.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

:: 4. DISM RestoreHealth
set /p "runRestore=4. DISM Image reparieren (RestoreHealth)? (J/N): "
if /i "%runRestore%"=="J" (
    echo.
    echo Starte DISM RestoreHealth...
    Dism /Online /Cleanup-Image /RestoreHealth
    echo.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

echo ========================================================
echo Alle ausgewählten Vorgaenge wurden abgeschlossen.
echo ========================================================
pause