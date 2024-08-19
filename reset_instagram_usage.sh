#!/bin/bash

LOG_FILE=~/instagram_usage.log

# Reset the usage log file
echo 0 > "$LOG_FILE"

# Unblock Instagram
if sudo iptables -C OUTPUT -p tcp --dport 443 -d 102.132.96.174 -j DROP 2>/dev/null; then
    sudo iptables -D OUTPUT -p tcp --dport 443 -d 102.132.96.174 -j DROP
fi
if sudo iptables -C OUTPUT -p tcp --dport 80 -d 102.132.96.174 -j DROP 2>/dev/null; then
    sudo iptables -D OUTPUT -p tcp --dport 80 -d 102.132.96.174 -j DROP
fi

