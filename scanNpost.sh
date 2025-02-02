#!/bin/bash

# Configuration
POST_URL="https://dlogging-554433.firebaseio.com/data_log.json"  # Firebase expects .json

# Check if target host is provided
if [ -z "$1" ]; then
    echo "Usage: $(basename "${BASH_SOURCE[0]}") <target_host>"
    exit 1
fi

TARGET_HOST="$1"

# Get hostname (fallback to target if lookup fails)
HOSTNAME=$(nslookup "$TARGET_HOST" 2>/dev/null | awk '/name =/ {print $4}' | sed 's/\.$//')
[ -z "$HOSTNAME" ] && HOSTNAME="$TARGET_HOST"

# Get IP address (works on both macOS & Linux)
IP_ADDRESS=$(dig +short "$TARGET_HOST" | head -n 1)
[ -z "$IP_ADDRESS" ] && IP_ADDRESS=$(ping -c 1 "$TARGET_HOST" | awk -F'[()]' '/PING/ {print $2}')
[ -z "$IP_ADDRESS" ] && { echo "Error: Could not determine IP address."; exit 1; }

# Create JSON payload (no jq required)
JSON_DATA="{\"hostname\":\"$HOSTNAME\",\"ip\":\"$IP_ADDRESS\"}"

# Send data via POST request
RESPONSE=$(curl -s -X POST -H "Content-Type: application/json" -d "$JSON_DATA" "$POST_URL")

# Output response
echo "Response: $RESPONSE"
