# 🚀 Chattter Uptime Monitor & Cloud Log Aggregator

A lightweight, high-performance site reliability engineering (SRE) tool built with **Bash**, **Vim**, and **Docker**, featuring an automated cloud data pipeline backed by **Amazon Web Services (AWS)**. This project simulates an enterprise-level observability framework by checking service response states, running localized log rotations, and streaming runtime telemetry directly into a centralized data lake.

## 🛠️ Key Features
- **Deterministic Status Auditing:** Leverages network `curl` requests to assess system availability and isolate response behaviors.
- **Automated Log Rotation:** Enforces a structural execution cap (max 10 lines) on the host machine to defend against storage volume expansion.
- **Containerized Architecture:** Bundled inside a minimal, highly secure Alpine Linux Docker sandbox to ensure absolute environmental portability.
- **Phase 7 Data Pipeline:** Integrated with the `aws-cli` subsystem to automatically ship runtime log footprints directly into an immutable AWS S3 Cloud Storage Vault on every single execution loop.

## 🏗️ Technical Architecture Flow
```text
[ LOCAL SCRIPT CORE ]              [ ENGINE ISOLATION ]             [ CLOUD AGGREGATION LAYER ]
+---------------------+            +--------------------+            +--------------------------+

|  uptime_monitor.sh  | -------->  |   Alpine Linux     | -------->  |     AWS S3 Storage       |
|  * Runs status checks|            |   Docker Container |            |     (chattter-log-vault) |
|  * Rotates local log|            |   (Isolates env)   |            |     (Persistent Lake)    |
+---------------------+            +--------------------+            +--------------------------+
```

## 🚀 How to Run and Test Locally

### Prerequisites
- [Docker Desktop](https://docker.com) installed and running.
- Programmatic credentials initialized locally via the terminal using the `aws configure` sequence.

### 1. Clone and Navigate to the Workspace
```bash
cd chattter-uptime-monitor
```

### 2. Build the Isolated Docker Image
```bash
docker build -t chattter-monitor:v1 .
```

### 3. Trigger the Automated Execution & Cloud Sync Loop
```bash
docker run --rm chattter-monitor:v1
```

## 📊 Verifying the Cloud Pipeline
To inspect the remote Amazon Web Services data engine plane directly from your terminal and verify that your log files have successfully crossed the internet, execute our standard verification query loop:
```bash
aws s3 ls s3://chattter-log-vault-mrowens/
```
