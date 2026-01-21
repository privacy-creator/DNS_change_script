@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM --- Check for Administrator rights ---
net session >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO This script must be run as Administrator.
    ECHO Right-click the file and choose "Run as administrator".
    PAUSE
    EXIT /B
)

ECHO --- Begin DNS configuration for all active adapters ---

REM --- Loop through all active adapters ---
for /f "skip=3 tokens=1,2,3,* delims= " %%A in ('netsh interface show interface') do (
    set "AdminState=%%A"
    set "Type=%%B"
    set "Status=%%C"
    set "Adapter=%%D"

    REM Process only connected adapters
    if "!Status!"=="Connected" (
        ECHO Processing adapter: "!Adapter!"

        REM --- Set IPv4 DNS ---
        netsh interface ipv4 set dns name="!Adapter!" static 1.1.1.1 primary
        netsh interface ipv4 add dns name="!Adapter!" 1.0.0.1 index=2

        REM --- Set IPv6 DNS ---
        netsh interface ipv6 set dns name="!Adapter!" static 2606:4700:4700::1111 primary
        netsh interface ipv6 add dns name="!Adapter!" 2606:4700:4700::1001 index=2
    )
)

REM --- Flush DNS cache ---
ipconfig /flushdns

ECHO --- DNS settings updated for all active adapters ---
PAUSE
