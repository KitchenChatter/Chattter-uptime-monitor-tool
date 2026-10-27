FROM alpine:latest

# Install system essentials along with the native alpine aws-cli package
RUN apk add --no-cache \
    bash \
    curl \
    aws-cli

WORKDIR /app

COPY uptime_monitor.sh .
RUN chmod +x uptime_monitor.sh

CMD ["./uptime_monitor.sh"]

