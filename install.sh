#!/bin/sh

# =============================================================================
#        LuCI App for AutoSync - Repository Installation Script
# =============================================================================
#  Run this script from the root of the cloned repository on your OpenWrt device.
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

# --- Dependency Check ---
echo_info "Checking for required packages..."

check_and_install_pkg() {
    local pkg_name="$1"
    local cmd_name="$2"
    if ! command -v "$cmd_name" >/dev/null 2>&1; then
        echo_warn "Command '$cmd_name' not found. '$pkg_name' is required."
        read -p "Do you want to try and install it now via opkg? (y/n): " choice
        case "$choice" in
            y|Y ) 
                echo_info "Running 'opkg update'..."
                opkg update
                echo_info "Attempting to install '$pkg_name'..."
                opkg install "$pkg_name"
                if ! command -v "$cmd_name" >/dev/null 2>&1; then
                    echo_error "Failed to install '$pkg_name'. Please install it manually."
                    exit 1
                fi
                ;;
            * ) echo_error "Installation aborted."; exit 1;;
        esac
    else
        echo_ok "Package for '$cmd_name' is already installed."
    fi
}

check_and_install_pkg "rsync" "rsync"
check_and_install_pkg "inotify-tools" "inotifywait"

# --- File Installation ---
echo_info "Copying application files..."

# Copy LuCI files using rsync for safer directory merging
rsync -a ./luasrc/ /usr/lib/lua/luci/
if [ $? -ne 0 ]; then echo_error "Failed to copy LuCI files."; exit 1; fi
echo_ok "LuCI files copied."

# Copy root filesystem files using rsync
rsync -a ./root/ /
if [ $? -ne 0 ]; then echo_error "Failed to copy root files."; exit 1; fi
echo_ok "Root filesystem files copied."

# --- Set Permissions ---
echo_info "Setting executable permissions..."
chmod +x /etc/init.d/autosync
chmod +x /usr/bin/realtime_sync.sh
echo_ok "Permissions set."

# --- Final Steps ---
echo_info "Cleaning LuCI cache..."
rm -f /tmp/luci-indexcache
echo_ok "LuCI cache cleared."

# Enable and start the service
echo_info "Enabling and starting the autosync service..."
/etc/init.d/autosync enable
/etc/init.d/autosync restart

echo_info "=================================================================="
echo_ok "Installation complete!"
echo_info "Please navigate to Services -> AutoSync in LuCI to configure."
echo_info "=================================================================="

exit 0