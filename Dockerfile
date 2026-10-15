# 1. Use a tiny, secure Linus base image
FROM alpine:latest

# 2. Install curl and bash (Alpine uses apk packages)
RUN apk add --no-cache bash curl

# 3. Create and set the workspace directory inside the container
WORKDIR /app

# 4. Copy your fixed script into the container
COPY uptime_monitor.sh .

# 5. Grant execute permissions to the script inside Linux
RUN chmod +x uptime_monitor.sh

# 6. Execute the script automatically when the container runs
CMD ["./uptime_monitor.sh"]
