@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

ECHO --- Begin DNS instellingen voor alle actieve adapters ---

REM --- Loop door alle actieve adapters ---
for /f "skip=3 tokens=1,2,3,* delims= " %%A in ('netsh interface show interface') do (
    set "AdminState=%%A"
    set "Type=%%B"
    set "Status=%%C"
    set "Adapter=%%D"
    
    REM Verwijder eventuele voorloopspaties
    set "Adapter=!Adapter:~0!"
    
    ECHO Verwerken adapter: "!Adapter!"
    
    REM --- Stel IPv4 DNS in ---
    netsh interface ipv4 set dns name="!Adapter!" static 1.1.1.1 primary
    netsh interface ipv4 add dns name="!Adapter!" 1.0.0.1 index=2
    
    REM --- Stel IPv6 DNS in ---
    netsh interface ipv6 set dns name="!Adapter!" static 2606:4700:4700::1111 primary
    netsh interface ipv6 add dns name="!Adapter!" 2606:4700:4700::1001 index=2
)

REM --- Flush DNS ---
ipconfig /flushdns

ECHO --- DNS instellingen bijgewerkt voor alle actieve adapters ---
pause
