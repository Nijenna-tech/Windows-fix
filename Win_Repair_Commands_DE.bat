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
choice /c JN /m "1. Windows Start- und Systemdateien pruefen sfc /scannow"
if errorlevel 2 (
    echo Uebersprungen.
    echo.
) else (
    echo.
    echo Starte SFC...
    sfc /scannow
    echo.
    echo --------------------------------------------------------
)

:: 2. DISM CheckHealth
choice /c JN /m "2. DISM Image auf Beschaedigungen pruefen CheckHealth"
if errorlevel 2 (
    echo Uebersprungen.
    echo.
) else (
    echo.
    echo Starte DISM CheckHealth...
    Dism /Online /Cleanup-Image /CheckHealth
    echo.
    echo --------------------------------------------------------
)

:: 3. DISM ScanHealth
choice /c JN /m "3. DISM Image tiefgehend scannen ScanHealth"
if errorlevel 2 (
    echo Uebersprungen.
    echo.
) else (
    echo.
    echo Starte DISM ScanHealth...
    Dism /Online /Cleanup-Image /ScanHealth
    echo.
    echo --------------------------------------------------------
)

:: 4. DISM RestoreHealth
choice /c JN /m "4. DISM Image reparieren RestoreHealth"
if errorlevel 2 (
    echo Uebersprungen.
    echo.
) else (
    echo.
    echo Starte DISM RestoreHealth...
    Dism /Online /Cleanup-Image /RestoreHealth
    echo.
    echo --------------------------------------------------------
)

echo ========================================================
echo                      Netzwerk-Optionen
echo ========================================================
echo.

:: 5. IP-Adresse neu zuweisen
choice /c JN /m "5. Wollen Sie Ihre IP Adresse neu zuweisen"
if errorlevel 2 (
    echo IP-Adresse wurde nicht neu zugewiesen.
    echo.
) else (
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
)

:: 6. DNS-Cache leeren
choice /c JN /m "6. Wollen Sie Ihren DNS Cache leeren"
if errorlevel 2 (
    echo DNS-Cache wurde nicht geleert.
    echo.
) else (
    echo.
    ipconfig /flushdns
    echo.
    echo DNS-Cache wurde erfolgreich geleert.
    echo --------------------------------------------------------
)

echo ========================================================
echo                      Festplatten-Optionen
echo ========================================================
echo.

:: 7. Festplatten-Überprüfung (chkdsk) auf allen Laufwerken
choice /c JN /m "7. Alle Laufwerke auf Fehler pruefen chkdsk"
if errorlevel 2 (
    echo Uebersprungen.
    echo.
) else (
    echo.
    echo Ermittle alle verfuegbaren Laufwerke...
    for /f "delims=" %%d in ('powershell -NoProfile -Command "Get-Volume | Where-Object {$_.DriveLetter} | Select-Object -ExpandProperty DriveLetter"') do (
        echo Plane chkdsk fuer Laufwerk %%d: ein...
        echo Y | chkdsk %%d: /f /r >nul 2>&1
    )
    echo.
    echo Alle Laufwerke wurden fuer den naechsten Systemstart eingeplant.
    echo --------------------------------------------------------
)

echo ========================================================
echo                     Arbeitsspeicher-Optionen
echo ========================================================
echo.

:: 8. RAM / Arbeitsspeicher prüfen (mdsched)
choice /c JN /m "8. Arbeitsspeicher auf Fehler pruefen mdsched Neustart noetig"
if errorlevel 2 (
    echo Uebersprungen.
    echo.
) else (
    echo.
    echo Starte Windows-Speicherdiagnose...
    mdsched.exe
    echo Die Speicherdiagnose wurde vorbereitet/gestartet.
    echo --------------------------------------------------------
)

echo ========================================================
echo Alle ausgewählten Vorgaenge wurden abgeschlossen.
echo ========================================================
endlocal
pause
