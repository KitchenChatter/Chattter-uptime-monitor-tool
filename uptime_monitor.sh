#!/bin/bash

# Target destination and constraints
URL="https://httpbin.org"
LOG_FILE="server_status.log"
MAX_LINES=10
FAILURE_THRESHOLD=3  # Must fail 3 consecutive times to trigger Slack
COUNTER_FILE=".failure_counter"

# Inherit secure Slack link dynamically from system memory environment
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"

# Initialize counter file if it doesn't exist
if [ ! -f "$COUNTER_FILE" ]; then
    echo "0" > "$COUNTER_FILE"
fi

echo "=== Starting Uptime Check ==="

# 1. Capture the raw network response code
STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# Read the current persistent counter value out of storage into terminal memory
CURRENT_FAILURES=$(cat "$COUNTER_FILE")

# 2. Evaluate environmental conditions
if [ "$STATUS_CODE" -eq 200 ]; then
    echo "[$TIMESTAMP] SUCCESS: Website is UP ($STATUS_CODE)" >> "$LOG_FILE"
    
    # System Healed: Reset sequential failure tracking file back to zero
    echo "0" > "$COUNTER_FILE"
else
    # Increment our local tracking variable safely
    CURRENT_FAILURES=$((CURRENT_FAILURES + 1))
    echo "$CURRENT_FAILURES" > "$COUNTER_FILE"
    
    echo "[$TIMESTAMP] ALERT: Website is DOWN ($STATUS_CODE). Consecutive failure count: $CURRENT_FAILURES/$FAILURE_THRESHOLD" >> "$LOG_FILE"
    
    # 3. Threshold Check: Secure integer evaluation barrier
    if [ "$CURRENT_FAILURES" -eq "$FAILURE_THRESHOLD" ]; then
        echo "[$TIMESTAMP] INCIDENT BREACH: Threshold reached ($FAILURE_THRESHOLD). Firing P1 Slack Alert..."
        curl -s -X POST -H 'Content-type: application/json' \
        --data '{"text":"🚨 *Chattter P1 Incident Breach* 🚨\n*Incident:* Target Website has been DOWN for '"$FAILURE_THRESHOLD"' consecutive checks!\n*Status Code:* '"$STATUS_CODE"'\n*Timestamp:* '"$TIMESTAMP"'"}' \
        "$SLACK_WEBHOOK_URL"
    fi
fi

# 4. DevOps Log Rotation
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt "$MAX_LINES" ]; then
    echo "[$TIMESTAMP] SYSTEM: Log file exceeded $MAX_LINES lines. Rotating logs..."
    tail -n "$MAX_LINES" "$LOG_FILE" > temp.log && mv temp.log "$LOG_FILE"
fi

# 5. Cloud Data Pipeline: Stream logs to central AWS S3 storage bucket vault
echo "[$TIMESTAMP] PIPELINE: Syncing logs to AWS S3 Cloud Storage..."
aws s3 cp "$LOG_FILE" s3://chattter-log-vault-mrowens/server_status.log --quiet

echo "=== Check Complete. Log updated. ==="
