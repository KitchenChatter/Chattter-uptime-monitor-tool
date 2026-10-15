#!/bin/bash

# Define variables
URL="https://httpbin.org"
LOG_FILE="server_status.log"
MAX_LINES=10

echo "=== Starting Uptime Check ==="

# 1. Fetch the HTTP status code using curl
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

# 2. Get the current timestamp
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# 3. Check if the site is up (Status 200) and log it
if [ "$STATUS_CODE" -eq 200 ]; then
	echo "[$TIMESTAMP] SUCCESS: Website is UP ($STATUS_CODE)" >> "$LOG_FILE"
else
	echo "[$TIMESTAMP] ALERT: Website is DOWN ($STATUS_CODE)" >> "$LOG_FILE"
fi

# 4. DevOps Log Rotation
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt "$MAX_LINES" ]; then
	echo "[$TIMESTAMP] SYSTEM: Log file exceeded $MAX_LINES lines. Rotating logs..."
	tail -n "$MAX_LINES" "$LOG_FILE" > temp.log && mv temp.log "$LOG_FILE"
fi

echo "=== Check Complete. Log updated. ==="
