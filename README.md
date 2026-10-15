# DevOps Uptime Monitor & Log Rotator

A lightweight, automated infrastructure monitoring tool built with **Bash**, **Vim**, and **Docker**. This project simulates an enterprise-level site reliability task by tracking server status codes and executing localized log rotations.

## 🚀 Key Features
- **Status Checking:** Utilizes `curl` requests to verify site connectivity.
- **Log Rotation:** Automatically trims execution logs to maintain a clean filesystem footprint.
- **Containerized Architecture:** Bundled into a secure, minimal Alpine Linux Docker environment.

## 🛠️ How to Run Locally

### Prerequisites
Ensure you have [Docker Desktop](https://docker.com) installed and running on your machine.

### 1. Clone and Navigate to the Repository
```bash
cd devops-uptime-monitor
```

### 2. Build the Docker Image
```bash
docker build -t uptime-monitor:v1 .
```

### 3. Run the Container
```bash
docker run --rm uptime-monitor:v1
```
# DevOps-uptime-monitor-tool
