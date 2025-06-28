#!/bin/sh

# =============================================================================
#        LuCI App for AutoSync - Uninstallation Script
# =============================================================================

# Color codes for output
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

echo_info() { echo -e "${C_BLUE}[INFO]${C_NC} $1"; }
echo_ok() { echo -e "${C_GREEN}[OK]${C_NC} $1"; }
echo_warn() { echo -e "${C_YELLOW}[WARN]${C_NC} $1"; }
echo_error() { echo -e "${C_RED}[ERROR]${C_NC} $1"; }

# Ensure running as root
if [ "$(id -u)" -ne 0 ]; then
    echo_error "This script must be run as root. Please use 'sudo' or log in as root."
    exit 1
fi

# --- Stop and Disable Service ---
echo_info "Stopping and disabling the autosync service..."
if [ -f /etc/init.d/autosync ]; then
    /etc/init.d/autosync stop
    /etc/init.d/autosync disable
    echo_ok "Service stopped and disabled."
else
    echo_warn "Service script not found, skipping."
fi

# --- Remove Files ---
echo_info "Removing application files..."

rm -f /usr/lib/lua/luci/controller/autosync.lua
rm -rf /usr/lib/lua/luci/model/cbi/autosync
rm -f /etc/init.d/autosync
rm -f /usr/bin/realtime_sync.sh

echo_ok "Application files removed."

read -p "Do you want to remove the configuration file /etc/config/autosync? (y/n): " choice
case "$choice" in
    y|Y ) 
        rm -f /etc/config/autosync
        echo_ok "Configuration file removed."
        ;;
    * ) 
        echo_info "Configuration file was not removed."
        ;;
esac

# --- Clean Cache ---
echo_info "Cleaning LuCI cache..."
rm -f /tmp/luci-indexcache
echo_ok "LuCI cache cleared."


echo_info "=================================================================="
echo_ok "Uninstallation complete!"
echo_info "=================================================================="

exit 0
