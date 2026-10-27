# 📘 Chattter Platform: SRE Troubleshooting & Debug Playbook

## 📁 Section 1: Local Automation & System Logic (Cron & Scripting)

### 🐛 Bug 1.1: Cron System Environmental Path Erasure
*   **The Symptom:** Your local background Cron log (`/tmp/cron_uptime.log`) prints error codes stating `/bin/sh: docker: command not found` or `/bin/sh: /usr/local/bin/docker: No such file or directory`.
*   **The Root Cause:** Background system daemons like Unix `cron` execute in heavily stripped environments that default to restricted default paths (`PATH=/usr/bin:/bin`). They completely miss the custom user paths where Docker Desktop binaries are stored on macOS.
*   **The Triage:** Run `which docker` inside your interactive shell to locate the true binary file wrapper. On your specific setup, it paths to `/Users/mrOwens/.docker/bin/docker`.
*   **The Mitigation:** Explicitly inject a custom `PATH` environmental header directly at the top of your scheduler file (`crontab -e`) before declaring the timing rule:
    ```text
    PATH=/Users/mrOwens/.docker/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
    * * * * * docker run --rm chattter-monitor:v1 >> /tmp/cron_uptime.log 2>&1
    ```

### 🐛 Bug 1.2: Uninitialized State Memory Variable (Integer Expression Expected)
*   **The Symptom:** Running the threshold monitoring script throws a fatal shell crash stating: `./uptime_monitor.sh: line 49: [: : integer expression expected`.
*   **The Root Cause:** The variable `$CURRENT_FAILURES` was mapped *before* the script completed its initial health loop. On a successful `200` query run, the code cleared the file but failed to populate a numerical placeholder value inside the running shell session memory prior to evaluating the threshold expression.
*   **The Mitigation:** Restructured the tracking logic execution order. The persistent `.failure_counter` database file is now explicitly parsed right after the network `curl` response wrapper concludes, guaranteeing a stable, non-empty integer is always supplied to the conditional evaluation boundaries.

***

## 🐳 Section 2: Container Isolation & Layer Compilation (Docker)

### 🐛 Bug 2.1: Missing Context Argument Error
*   **The Symptom:** Running `docker build -t chattter-monitor:v1` fails instantly with the error message: `ERROR: docker: 'docker buildx build' requires 1 argument`.
*   **The Root Cause:** The Docker compilation engine requires a terminal path parameter to tell it where to parse instructions. Skipping the final workspace context tracker prevents compilation.
*   **The Mitigation:** Append a trailing workspace marker dot (`.`) separated by a single space to explicitly map the current active directory context:
    ```bash
    docker build -t chattter-monitor:v1 .
    ```

### 🐛 Bug 2.2: Missing Runtime Image Layout (Registry Pull Access Denied)
*   **The Symptom:** Running `docker run` throws an error response stating `pull access denied for chattter-monitor, repository does not exist or may require 'docker login'`.
*   **The Root Cause:** After system reboots or cache purges, Docker wipes temporary local images. If you run a container before building it locally, the engine assumes it must pull it from the public internet (Docker Hub) and drops access privileges.
*   **The Mitigation:** Recompile the static local blueprint file first before re-triggering the execution sandbox run:
    ```bash
    docker build -t chattter-monitor:v1 .
    ```

### 🐛 Bug 2.3: Hardcoded Absolute Path Engine Conflict
*   **The Symptom:** Executing your container loop catches a internal shell drop stating: `./uptime_monitor.sh: line 40: /usr/local/bin/aws: No such file or directory`.
*   **The Root Cause:** Your monitoring script had the absolute macOS path root (`/usr/local/bin/aws`) hardcoded into its internal sync step. When wrapped in a Linux container environment, Alpine Linux stores packages inside `/usr/bin/aws`, causing file map breaks.
*   **The Mitigation:** Edit your script via **Vim** and strip out the absolute file system path prefix, allowing your container environment to resolve the tool dynamically via system environment variables:
    ```bash
    # Corrected dynamic execution syntax
    aws s3 cp "\$LOG_FILE" s3://chattter-log-vault-mrowens/server_status.log --quiet
    ```

***

## 🛠️ Section 3: Infrastructure as Code & Syntax Errors (Terraform)

### 🐛 Bug 3.1: Broken Daemon Sockets Connection Timeout
*   **The Symptom:** Running `terraform plan` or `terraform apply` crashes out completely with the provider error: `Error: Error pinging Docker server: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?`.
*   **The Root Cause:** Docker Desktop on Apple macOS runs in a hypervisor sandbox layer and routes its host communication socket file through the user's home profile path instead of standard Linux global server roots.
*   **The Mitigation:** Explicitly reference your exact Mac profile socket bridge parameter directly inside your provider block in your `main.tf` configuration:
    ```hcl
    provider "docker" {
      host = "unix:///Users/mrOwens/.docker/run/docker.sock"
    }
    ```

### 🐛 Bug 3.2: Invalid Block Definition (Brace Misalignment Error)
*   **The Symptom:** Compilation fails with the error message: `Error: Invalid block definition... A block definition must have block content delimited by "{" and "}", starting on the same line as the block header.`
*   **The Root Cause:** HashiCorp Configuration Language (HCL) enforces strict syntax formatting loops. Placing an opening brace `{` on a fresh line separate from its block declaration header breaks code evaluation.
*   **The Mitigation:** Pull the opening curly brace back up to sit on the **exact same line** as your declaration statement using Vim's interactive text controls:
    ```hcl
    # Correct format structure
    provider "docker" {
      host = "unix:///Users/mrOwens/.docker/run/docker.sock"
    }
    ```

### 🐛 Bug 3.3: Nested Resource Spacing Collision (Unsupported Block Type)
*   **The Symptom:** Terraform throws an error stating: `Error: Unsupported block type... Blocks of type "resource" are not expected here.`
*   **The Root Cause:** A Vim clipboard paste error caused a new resource block (`aws_s3_bucket`) to get dropped *inside* an existing resource block (`aws_instance`) without a closing brace `}` separating them. 
*   **The Mitigation:** Ensure every individual declarative block has its trailing brace cleanly sealed before opening a fresh layer. Clean up your configuration layout so it looks exactly like this:
    ```hcl
    resource "aws_instance" "chattter_cloud_server" {
      # Config details here
    } # <-- Ensure this brace closes completely before starting the next block

    resource "aws_s3_bucket" "chattter_log_vault" {
      # Config details here
    }
    ```

***

## 🔐 Section 4: Application Security & Communication (Git Secrets & Webhooks)

### 🐛 Bug 4.1: Plain-Text Password Credentials Push Protection Block
*   **The Symptom:** Git terminal uploads fail with a massive red banner stating: `remote: error: GH013: Repository rule violations found... Push cannot contain secrets... Slack Incoming Webhook URL`.
*   **The Root Cause:** GitHub's automated push protection filters detected your live webhook token hardcoded into your code files. It blocks the push to save your credentials from public scraping bots.
*   **The Mitigation:** 
    1. Strip the plain-text URL string out of your file and substitute it with an environment variable placeholder: `SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL}"`.
    2. Overwrite your local Git history snapshot to scrub the credentials: `git commit --amend --no-edit`.
    3. Hide the key securely inside your Mac's interactive session memory: `export SLACK_WEBHOOK_URL="https://slack.com..."`.
    4. Safely push your code: `git push origin main`.

### 🐛 Bug 4.2: Webfront Endpoint Misdirection (HTML Code Injection)
*   **The Symptom:** Firing an alert returns a raw block of browser layout configuration text (`<!DOCTYPE html>`) instead of a slack card.
*   **The Root Cause:** The main customer front-page gateway (`https://slack.com`) was accidentally bound to the alerting variables instead of the programmatic inbound services hook URL link.
*   **The Mitigation:** Replace the top-level string reference with the dedicated backend programmatic routing link: `https://slack.comT.../B.../X...`

***

## ☁️ Section 5: Global Integration Failures (Amazon Web Services)

### 🐛 Bug 5.1: Missing Infrastructure Target Elements (NoSuchBucket Error)
*   **The Symptom:** Your application execution logic crashes during network file operations, throwing the error statement: `An error occurred (NoSuchBucket) when calling the ListObjectsV2 operation: The specified bucket does not exist`.
*   **The Root Cause:** Your monitoring application tried to ship telemetry log folders up to an S3 bucket that was either never created, deleted via a previous teardown script, or named with a string typo.
*   **The Mitigation:** Slide into your infrastructure configuration repository and force provision the missing cloud resources via Terraform to re-establish the live web container paths:
    ```bash
    cd ~/chattter-infra
    terraform apply -auto-approve
    ```
