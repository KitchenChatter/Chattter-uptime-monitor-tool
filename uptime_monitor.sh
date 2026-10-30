#!/bin/bash

# Define variables
URL="https://this-site-is-broken.com" 
LOG_FILE="server_status.log"
MAX_LINES=20

echo "=== Starting Structured Uptime Check === "

# 1. Fetch metrics using curl's write-out features safely
# We pass a 10-second timeout to handle hung requests gracefully
CURL_OUT=$(curl -s -m 10 -o /dev/null -w "%{http_code},%{time_total}" "$URL" 2>/dev/null)

# Catch pure exit statuses (like exit code 6 for Host Not Found)
CURL_EXIT=$?

# 2. Extract metrics and handle completely broken connections
if [ $CURL_EXIT -ne 0 ]; then
    HTTP_STATUS=000
    LATENCY_MS=0
else
    HTTP_STATUS=$(echo "$CURL_OUT" | cut -d',' -f1)
    LATENCY_SEC=$(echo "$CURL_OUT" | cut -d',' -f2)
    LATENCY_MS=$(echo "$LATENCY_SEC * 1000 / 1" | bc 2>/dev/null || awk "BEGIN {print int($LATENCY_SEC * 1000)}")
fi

# Ensure fallback values if parsing fails inside strings
if [ -z "$HTTP_STATUS" ] || [ "$HTTP_STATUS" -eq 0 ]; then
    HTTP_STATUS=000
fi

# 3. Determine pass/fail status and evaluate alert thresholds
if [ "$HTTP_STATUS" -eq 200 ]; then
    STATUS="PASS"
else
    STATUS="FAIL"
fi

# 4. Enforce Alerting Guardrails (Check recent lines in local log)
IF_LAST_TWO_FAILED=$(tail -n 2 "$LOG_FILE" 2>/dev/null | grep -c '"status":"FAIL"')

if [ "$STATUS" == "FAIL" ] && [ "$IF_LAST_TWO_FAILED" -eq 2 ]; then
    echo "🚨 [ALERT] CRITICAL OUTAGE DETECTED! Target has failed 3 consecutive checks."
    echo "🚨 Draining error budget rapidly. Initiating engineer escalation..."
fi

# 5. Generate ISO 8601 Timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# 6. Construct the clean JSON Line
JSON_LOG="{\"timestamp\":\"$TIMESTAMP\",\"target\":\"$URL\",\"http_status\":$HTTP_STATUS,\"latency_ms\":$LATENCY_MS,\"status\":\"$STATUS\"}"

# 6.5 APPEND TO LOG FILE (The missing link!)
echo "$JSON_LOG" >> "$LOG_FILE"

# 7. Maintain log rotation
if [ -f "$LOG_FILE" ] && [ "$(wc -l < "$LOG_FILE")" -gt "$MAX_LINES" ]; then
    echo "[$TIMESTAMP] SYSTEM: Rotating logs..."
    tail -n "$MAX_LINES" "$LOG_FILE" > temp.log && mv temp.log "$LOG_FILE"
fi

echo "=== Check Complete. Structured log appended. ==="
