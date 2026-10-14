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
echo                    Festplatten-Optionen
echo ========================================================
echo.

:: 5. Festplatten-Überprüfung (chkdsk) auf allen Laufwerken
set /p "runChk=5. Alle Laufwerke auf Fehler pruefen (chkdsk /f /r - erfordert Neustart)? (J/N): "
if /i "%runChk%"=="J" (
    echo.
    echo Ermittle alle verfuegbaren Laufwerke...
    for /f "tokens=1" %%d in ('wmic logicaldisk get deviceid ^| findstr /r "[A-Z]"') do (
        echo Plane chkdsk fuer Laufwerk %%d ein...
        echo Y | chkdsk %%d /f /r >nul 2>&1
    )
    echo.
    echo Alle Laufwerke wurden fuer den naechsten Systemstart eingeplant.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

:: 6. Laufwerke optimieren (Defragmentierung für HDDs / TRIM für SSDs)
set /p "runOpt=6. Alle Laufwerke optimieren (Defrag/TRIM je nach Laufwerkstyp)? (J/N): "
if /i "%runOpt%"=="J" (
    echo.
    echo Starte Optimierung fuer alle Laufwerke (Windows erkennt automatisch SSD/HDD)...
    defrag /C /U /V
    echo.
    echo Laufwerksoptimierung abgeschlossen.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

echo ========================================================
echo                     Netzwerk-Optionen
echo ========================================================
echo.

:: 7. IP-Adresse neu zuweisen
set /p "runIP=7. Wollen Sie Ihre IP Adresse neu zuweisen? (J/N): "
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

:: 8. DNS-Cache leeren
set /p "runDNS=8. Wollen Sie Ihren DNS Cache leeren? (J/N): "
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
echo                  Arbeitsspeicher-Optionen
echo ========================================================
echo.

:: 9. RAM / Arbeitsspeicher prüfen (mdsched)
set /p "runRAM=9. Arbeitsspeicher auf Fehler pruefen (mdsched - erfordert Neustart)? (J/N): "
if /i "%runRAM%"=="J" (
    echo.
    echo Starte Windows-Speicherdiagnose...
    mdsched.exe
    echo Die Speicherdiagnose wurde vorbereitet/gestartet.
    echo --------------------------------------------------------
) else (
    echo Uebersprungen.
    echo.
)

echo ========================================================
echo Alle ausgewählten Vorgaenge wurden abgeschlossen.
echo ========================================================
pause
