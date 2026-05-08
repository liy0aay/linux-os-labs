#!/bin/bash
set -euo pipefail

# background daemon service that monitors events via a FIFO pipeline

FIFO_PATH="${WATCHER_FIFO:-/tmp/watcher_fifo}"
LOG_FILE="${WATCHER_LOG:-/tmp/watcher.log}"
PID_FILE="${WATCHER_PID:-/tmp/watcher.pid}"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

if [[ -f "$PID_FILE" ]]; then
    if kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        echo "Error: Watcher is already running" >&2
        exit 1
    fi
fi

echo "$$" > "$PID_FILE"

if [[ ! -p "$FIFO_PATH" ]]; then
    mkfifo "$FIFO_PATH"
fi


exec 3<> "$FIFO_PATH"

log_msg "NOTICE: Watcher started (PID: $$)"


cleanup() {
    log_msg "NOTICE: Received termination signal. Stopping Watcher.."
    
    exec 3<&- 
    rm -f "$PID_FILE"
    
    log_msg "NOTICE: Watcher successfully stopped"
    exit 0
}

reload_config() {
    log_msg "SIGNAL: SIGHUP - Configuration reload requested"
}

print_status() {
    log_msg "SIGNAL: SIGUSR1 - Current status: awaiting events"
}

switch_mode() {
    log_msg "SIGNAL: SIGUSR2 - Mode change / Log rotation requested"
}

trap cleanup TERM INT    
trap reload_config HUP   
trap print_status USR1   
trap switch_mode USR2    

log_msg "NOTICE: Watcher entered event loop"


while true; do
    EVENT=""
    read -t 2 -r EVENT <&3 || true
    
    if [[ -n "$EVENT" ]]; then
        case "$EVENT" in
            "STOP")
                log_msg "FIFO: Stop requested"
                cleanup 
                ;;
            "STATUS")
                log_msg "FIFO: Status check requested"
                print_status 
                ;;
            "MODE_CHANGE")
                log_msg "FIFO: Mode change requested"
                switch_mode
                ;;
            *)
                log_msg "EVENT: Received unknown payload -> $EVENT"
                ;;
        esac
    fi
done