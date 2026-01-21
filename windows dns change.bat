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

:MENU
CLS
ECHO ===============================
ECHO        DNS CONFIG MENU
ECHO ===============================
ECHO 1. Cloudflare DNS
ECHO 2. Mullvad DNS
ECHO 3. NextDNS
ECHO 4. Exit
ECHO.
SET /P CHOICE=Select an option [1-4]:

IF "%CHOICE%"=="1" GOTO CLOUDFLARE
IF "%CHOICE%"=="2" GOTO MULLVAD
IF "%CHOICE%"=="3" GOTO NEXTDNS
IF "%CHOICE%"=="4" EXIT /B

ECHO Invalid choice.
PAUSE
GOTO MENU

:CLOUDFLARE
SET DNS4_PRIMARY=1.1.1.1
SET DNS4_SECONDARY=1.0.0.1
SET DNS6_PRIMARY=2606:4700:4700::1111
SET DNS6_SECONDARY=2606:4700:4700::1001
SET DNS_NAME=Cloudflare
GOTO APPLY

:MULLVAD
SET DNS4_PRIMARY=194.242.2.2
SET DNS4_SECONDARY=194.242.2.3
SET DNS6_PRIMARY=2a07:e340::2
SET DNS6_SECONDARY=2a07:e340::3
SET DNS_NAME=Mullvad
GOTO APPLY

:NEXTDNS
SET DNS4_PRIMARY=45.90.28.0
SET DNS4_SECONDARY=45.90.30.0
SET DNS6_PRIMARY=2a07:a8c0::
SET DNS6_SECONDARY=2a07:a8c1::
SET DNS_NAME=NextDNS
GOTO APPLY

:APPLY
CLS
ECHO Applying %DNS_NAME% DNS to all connected adapters...
ECHO.

REM --- Loop through connected adapters ---
for /f "skip=3 tokens=1,2,3,* delims= " %%A in ('netsh interface show interface') do (
    set "Status=%%C"
    set "Adapter=%%D"

    if "!Status!"=="Connected" (
        ECHO Processing adapter: "!Adapter!"

        REM --- IPv4 ---
        netsh interface ipv4 set dns name="!Adapter!" static %DNS4_PRIMARY% primary
        netsh interface ipv4 add dns name="!Adapter!" %DNS4_SECONDARY% index=2

        REM --- IPv6 ---
        netsh interface ipv6 set dns name="!Adapter!" static %DNS6_PRIMARY% primary
        netsh interface ipv6 add dns name="!Adapter!" %DNS6_SECONDARY% index=2
    )
)

REM --- Flush DNS ---
ipconfig /flushdns

ECHO.
ECHO DNS successfully set to %DNS_NAME%.
PAUSE
GOTO MENU
