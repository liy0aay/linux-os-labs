#!/bin/bash
set -euo pipefail

# management wrapper for the watcher service
# provides start, stop, and status commands 

PID_FILE="${WATCHER_PID:-/tmp/watcher.pid}"
WATCHER_BIN="${WATCHER_BIN:-./watcher.sh}"

case "${1:-}" in
    start)
        echo "Starting Watcher..."
        "$WATCHER_BIN" & 
        echo "Watcher started in the background"
        ;;
    stop)
        if [[ -f "$PID_FILE" ]]; then
            kill -TERM "$(cat "$PID_FILE")"
            echo "Termination signal sent to Watcher"
        else
            echo "Watcher is not running (PID file not found)"
        fi
        ;;
    status)
        if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null || true; then
            echo "Watcher is RUNNING (PID: $(cat "$PID_FILE"))"
        else
            echo "Watcher is STOPPED"
        fi
        ;;
    *)
        echo "usage: $0 {start|stop|status}"
        exit 1
        ;;
esac