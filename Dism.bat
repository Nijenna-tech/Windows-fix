@echo off
setlocal
title Windows Reparatur- und Netzwerk-Tool (SFC ^& DISM)

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
echo                  Netzwerk-Optionen
echo ========================================================
echo.

:: 5. IP-Adresse neu zuweisen
set /p "runIP=5. Wollen Sie Ihre IP Adresse neu zuweisen? (J/N): "
if /i "%runIP%"=="J" (
    echo.
    ipconfig /release
    echo.
    echo Ihre IP Adresse wurde freigegeben...
    echo Es wird automatisch eine neue zugewiesen in 5 sekunden...
    timeout /t 5 /nobreak >nul
    ipconfig /renew
    echo.
    echo Ihre IP Adresse wurde nun wieder zugewiesen...
    echo --------------------------------------------------------
) else (
    echo IP-Adresse wurde nicht neu zugewiesen.
    echo.
)

:: 6. DNS-Cache leeren
set /p "runDNS=6. Wollen Sie Ihren DNS Cache leeren? (J/N): "
if /i "%runDNS%"=="J" (
    echo.
    ipconfig /flushdns
    echo.
    echo DNS-Cache wurde erfolgreich geleert.
    echo --------------------------------------------------------
) else (
    echo DNS-Cache wurde nicht geleert.
    echo.
)

echo ========================================================
echo Alle ausgewählten Vorgaenge wurden abgeschlossen.
echo ========================================================
pause
