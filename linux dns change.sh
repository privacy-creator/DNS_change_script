#!/bin/bash

# --- Check for root ---
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    echo "Use: sudo $0"
    exit 1
fi

clear
echo "==============================="
echo "        DNS CONFIG MENU"
echo "==============================="
echo "1. Cloudflare DNS"
echo "2. Mullvad DNS"
echo "3. NextDNS"
echo "4. Exit"
echo
read -p "Select an option [1-4]: " CHOICE

case "$CHOICE" in
    1)
        DNS_NAME="Cloudflare"
        DNS4="1.1.1.1 1.0.0.1"
        DNS6="2606:4700:4700::1111 2606:4700:4700::1001"
        ;;
    2)
        DNS_NAME="Mullvad"
        DNS4="194.242.2.2 194.242.2.3"
        DNS6="2a07:e340::2 2a07:e340::3"
        ;;
    3)
        DNS_NAME="NextDNS"
        DNS4="45.90.28.0 45.90.30.0"
        DNS6="2a07:a8c0:: 2a07:a8c1::"
        ;;
    4)
        exit 0
        ;;
    *)
        echo "Invalid option."
        exit 1
        ;;
esac

echo
echo "Applying $DNS_NAME DNS to active connections..."
echo

# --- Get active NetworkManager connections ---
nmcli -t -f NAME,DEVICE con show --active | while IFS=: read -r CON DEV; do
    if [[ -n "$DEV" ]]; then
        echo "Processing connection: $CON ($DEV)"

        nmcli con mod "$CON" ipv4.ignore-auto-dns yes
        nmcli con mod "$CON" ipv4.dns "$DNS4"

        nmcli con mod "$CON" ipv6.ignore-auto-dns yes
        nmcli con mod "$CON" ipv6.dns "$DNS6"

        nmcli con up "$CON" >/dev/null
    fi
done

# --- Flush DNS cache if available ---
if command -v systemd-resolve >/dev/null; then
    systemd-resolve --flush-caches
elif command -v resolvectl >/dev/null; then
    resolvectl flush-caches
fi

echo
echo "DNS successfully set to $DNS_NAME."
