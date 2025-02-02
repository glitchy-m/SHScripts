#!/bin/bash

# Configuration
TARGET_HOST="$1"  # The host to scan, passed as an argument
POST_URL="https://dlogging-554433.firebaseio.com/data_log.json"  # Firebase expects .json

# Validate input
if [ -z "$TARGET_HOST" ]; then
    echo "Usage: $0 <target_host>"
    exit 1
fi

# Get hostname
HOSTNAME=$(nslookup "$TARGET_HOST" 2>/dev/null | awk '/name =/ {print $4}' | sed 's/\.$//')
if [ -z "$HOSTNAME" ]; then
    HOSTNAME="$TARGET_HOST"
fi

# Get IP address (works on Linux & macOS)
IP_ADDRESS=$(dig +short "$TARGET_HOST" | head -n 1)
if [ -z "$IP_ADDRESS" ]; then
    IP_ADDRESS=$(ping -c 1 "$TARGET_HOST" | awk -F'[()]' '/PING/ {print $2}')
fi

# Scan open ports
OPEN_PORTS=$(nmap -p- --open -T4 "$TARGET_HOST" | awk '/^[0-9]/ {print $1}' | tr '\n' ',' | sed 's/,$//')

# Create JSON payload (without jq)
JSON_DATA="{\"hostname\":\"$HOSTNAME\",\"ip\":\"$IP_ADDRESS\",\"open_ports\":\"$OPEN_PORTS\"}"

# Send data via POST request
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$POST_URL")

# Output response
echo "Response: $RESPONSE"
