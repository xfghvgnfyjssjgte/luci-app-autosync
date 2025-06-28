#!/bin/sh

# =============================================================================
#        Download and Run LuCI App AutoSync Script
# =============================================================================
# This script downloads the luci-app-autosync project from GitHub
# and then executes the autosync.sh management script.
#
# Usage: sh download_and_run.sh
# =============================================================================

# Color codes for output
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_NC='\033[0m' # No Color

echo_info() { echo -e "${C_BLUE}[INFO]${C_NC} $1"; }
echo_ok() { echo -e "${C_GREEN}[OK]${C_NC} $1"; }
echo_error() { echo -e "${C_RED}[ERROR]${C_NC} $1"; }

PROJECT_DIR="/tmp/luci-app-autosync"
GITHUB_REPO="https://github.com/xfghvgnfyjssjgte/luci-app-autosync.git"

echo_info "Checking for git..."
if ! command -v git >/dev/null 2>&1; then
    echo_error "Git is not installed. Please install it first: opkg update && opkg install git git-http"
    exit 1
fi
echo_ok "Git is installed."

echo_info "Removing existing project directory if it exists..."
rm -rf "$PROJECT_DIR"
echo_ok "Cleaned up old project directory."

echo_info "Cloning the luci-app-autosync repository from GitHub..."
git clone "$GITHUB_REPO" "$PROJECT_DIR"
if [ $? -ne 0 ]; then
    echo_error "Failed to clone repository. Please check your network connection or repository URL."
    exit 1
fi
echo_ok "Repository cloned successfully to $PROJECT_DIR."

echo_info "Navigating to project directory..."
cd "$PROJECT_DIR"
if [ $? -ne 0 ]; then
    echo_error "Failed to change directory to $PROJECT_DIR."
    exit 1
fi
echo_ok "Changed directory to $PROJECT_DIR."

echo_info "Making autosync.sh executable..."
chmod +x autosync.sh
echo_ok "autosync.sh is now executable."

echo_info "Running autosync.sh..."
sh ./autosync.sh

echo_info "Script finished."
exit 0
