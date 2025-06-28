#!/bin/sh

# Args:
# 1. SOURCE_DIR: Source directory to watch.
# 2. DEST_DIR: Destination directory to sync to.
# 3. DELAY_ARG: Time in seconds to wait after a change before syncing (optional).
# 4. LOG_FILE_ARG: Path to the log file (optional).
# 5. SYNC_DELETES: "1" to enable rsync --delete, "0" to disable.

# --- Input Validation and Default Values ---
# We expect 5 arguments, but DELAY_ARG and LOG_FILE_ARG can be empty strings.
if [ "$#" -ne 5 ]; then
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] FATAL: Script requires 5 arguments, but received $#. Exiting." >&2
    exit 1
fi

SOURCE_DIR="$1"
DEST_DIR="$2"
DELAY_ARG="$3"
LOG_FILE_ARG="$4"
SYNC_DELETES="$5"

# Set default values if arguments are empty
DELAY=${DELAY_ARG:-5} # Default to 5 seconds
LOG_FILE=${LOG_FILE_ARG:-/var/log/autosync.log} # Default log file path

RSYNC_OPTS="-av"
LOG_MAX_SIZE=5242880 # 5MB in bytes

# --- Helper Functions ---

# Function to check log file size and rotate if necessary
check_log_size() {
    if [ -f "$LOG_FILE" ]; then
        CURRENT_SIZE=$(stat -c%s "$LOG_FILE" 2>/dev/null)
        if [ "$CURRENT_SIZE" -ge "$LOG_MAX_SIZE" ]; then
            mv "$LOG_FILE" "${LOG_FILE}.old" 2>/dev/null
            # Create a new empty log file
            touch "$LOG_FILE" 2>/dev/null
            log "INFO: Log file rotated. Old log moved to ${LOG_FILE}.old"
        fi
    fi
}

# Function to log messages to the specified log file
log() {
    # Ensure log file directory exists and is writable before logging
    LOG_DIR=$(dirname "$LOG_FILE")
    if [ ! -d "$LOG_DIR" ]; then
        mkdir -p "$LOG_DIR" 2>/dev/null
    fi
    # Check and rotate log before writing new entry
    check_log_size
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] $1" >> "$LOG_FILE" 2>&1
}

# --- Initial Setup and Validation ---

# Ensure log file is writable initially
touch "$LOG_FILE" >/dev/null 2>&1
if [ ! -w "$LOG_FILE" ]; then
    echo "[`date +'%Y-%m-%d %H:%M:%S'`] FATAL: Log file '$LOG_FILE' is not writable. Exiting." >&2
    exit 1
fi

if ! command -v rsync >/dev/null 2>&1; then
    log "FATAL: rsync command not found. Please install it. Exiting."
    exit 1
fi

if ! command -v inotifywait >/dev/null 2>&1; then
    log "FATAL: inotifywait command not found. Please install inotify-tools. Exiting."
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    log "FATAL: Source directory '$SOURCE_DIR' does not exist. Exiting."
    exit 1
fi

# --- Set rsync options ---
if [ "$SYNC_DELETES" = "1" ]; then
    RSYNC_OPTS="$RSYNC_OPTS --delete"
    log "INFO: Syncing for '$SOURCE_DIR' -> '$DEST_DIR'. Deletions WILL be synced. RSYNC_OPTS: $RSYNC_OPTS"
else
    log "INFO: Syncing for '$SOURCE_DIR' -> '$DEST_DIR'. Deletions will NOT be synced. RSYNC_OPTS: $RSYNC_OPTS"
fi

# --- Main Loop ---
# Perform an initial sync on startup
log "INFO: Performing initial sync for '$SOURCE_DIR'..."
log "DEBUG: Initial rsync command: rsync $RSYNC_OPTS \"$SOURCE_DIR/\" \"$DEST_DIR/\""
rsync $RSYNC_OPTS "$SOURCE_DIR/" "$DEST_DIR/" >> "$LOG_FILE" 2>&1

log "INFO: Now watching '$SOURCE_DIR' for changes..."
inotifywait -m -r -e create,delete,modify,move --format '%w%f %e' "$SOURCE_DIR" | while read -r FILE EVENT; do
    log "CHANGE: Event '$EVENT' detected on '$FILE'. Waiting for $DELAY seconds..."
    
    # Wait for a specified delay to bundle multiple changes
    # Use a read with timeout to consume subsequent events during the delay window
    # This prevents a storm of syncs for a storm of events.
    read -r -t "$DELAY"
    
    log "SYNC: Starting rsync for '$SOURCE_DIR'..."
    log "DEBUG: Triggered rsync command: rsync $RSYNC_OPTS \"$SOURCE_DIR/\" \"$DEST_DIR/\""
    rsync $RSYNC_OPTS "$SOURCE_DIR/" "$DEST_DIR/" >> "$LOG_FILE" 2>&1
    
    if [ $? -eq 0 ]; then
        log "SUCCESS: rsync completed for '$SOURCE_DIR'."
    else
        log "ERROR: rsync failed for '$SOURCE_DIR'. Check logs above for details."
    fi
done
