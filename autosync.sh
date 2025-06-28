#!/bin/sh

# =============================================================================
#        LuCI App for AutoSync - Installation/Uninstallation Script
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
check_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo_error "This script must be run as root. Please use 'sudo' or log in as root."
        exit 1
    fi
}

# --- Installation Function ---
install_app() {
    check_root
    echo_info "Starting installation of LuCI App AutoSync..."

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
                    echo_info "Running 'opkg update'...
                    opkg update
                    echo_info "Attempting to install '$pkg_name'...
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
}

# --- Uninstallation Function ---
uninstall_app() {
    check_root
    echo_info "Starting uninstallation of LuCI App AutoSync..."

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
    rm -f /usr/lib/lua/luci/po/zh-cn/autosync.po # Remove translation file
    rm -f /etc/init.d/autosync
    rm -f /usr/bin/realtime_sync.sh
    rm -f /etc/config/autosync # Always remove config file for clean uninstall

    echo_ok "Application files removed."

    # --- Clean Cache ---
    echo_info "Cleaning LuCI cache..."
    rm -f /tmp/luci-indexcache
    echo_ok "LuCI cache cleared."

    echo_info "=================================================================="
    echo_ok "Uninstallation complete!"
    echo_info "=================================================================="
}

# --- Main Menu ---
main_menu() {
    while true; do
        echo_info "\nLuCI App AutoSync Management Menu"
        echo_info "-----------------------------------"
        echo_info "1. Install AutoSync"
        echo_info "2. Uninstall AutoSync"
        echo_info "3. Exit"
        echo_info "-----------------------------------"
        read -p "Enter your choice [1-3]: " choice

        case "$choice" in
            1) install_app; break;;
            2) uninstall_app; break;;
            3) echo_info "Exiting. Goodbye!"; exit 0;;
            * ) echo_warn "Invalid choice. Please enter 1, 2, or 3.";;
        esac
    done
}

# Call the main menu function to start the script
main_menu