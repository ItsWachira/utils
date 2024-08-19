#!/bin/bash

LOG_FILE=~/instagram_usage.log
MAX_USAGE_TIME=3600  # 1 hour in seconds

# Check for active connections to Instagram's IP address
ACTIVE_CONNECTION=$(netstat -an | grep -E '443|80' | grep '102.132.96.174')

# If there is an active connection, increment usage time
if [ -n "$ACTIVE_CONNECTION" ]; then
    # Get the current usage time from the log file
    if [ -f "$LOG_FILE" ]; then
        USAGE_TIME=$(cat "$LOG_FILE")
    else
        USAGE_TIME=0
    fi

    # Add the new session time
    USAGE_TIME=$((USAGE_TIME + 300))  # Assuming the script runs every 5 minutes

    # Save the updated usage time to the log file
    echo $USAGE_TIME > "$LOG_FILE"

    # Block Instagram if the usage time exceeds the limit
    if [ "$USAGE_TIME" -ge "$MAX_USAGE_TIME" ]; then
        if ! sudo iptables -C OUTPUT -p tcp --dport 443 -d 102.132.96.174 -j DROP 2>/dev/null; then
            sudo iptables -I OUTPUT -p tcp --dport 443 -d 102.132.96.174 -j DROP
        fi
        if ! sudo iptables -C OUTPUT -p tcp --dport 80 -d 102.132.96.174 -j DROP 2>/dev/null; then
            sudo iptables -I OUTPUT -p tcp --dport 80 -d 102.132.96.174 -j DROP
        fi
    fi
fi

