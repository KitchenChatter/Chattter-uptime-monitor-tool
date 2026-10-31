import json
import os

LOG_FILE = "server_status.log"
OUTPUT_FILE = "index.html"
SLO_TARGET = 99.5

def build_html_dashboard():
    if not os.path.exists(LOG_FILE):
        # Fallback baseline data if log doesn't exist locally yet
        total_checks, passed_checks, failed_checks, availability = 8, 5, 3, 62.5
    else:
        total_checks = 0
        passed_checks = 0
        failed_checks = 0
        with open(LOG_FILE, "r") as f:
            for line in f:
                if not line.strip(): continue
                try:
                    log_entry = json.loads(line)
                    total_checks += 1
                    if log_entry["status"] == "PASS":
                        passed_checks += 1
                    else:
                        failed_checks += 1
                except json.JSONDecodeError:
                    continue
        availability = (passed_checks / total_checks) * 100 if total_checks > 0 else 100.0

    # Determine structural status theme
    if availability >= SLO_TARGET:
        status_text = "All Systems Operational"
        status_class = "operational"
        status_icon = "🟢"
    else:
        status_text = "Degraded Performance / SLO Violation"
        status_class = "degraded"
        status_icon = "🚨"

    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chattter Platform Status</title>
    <style>
        body {{ font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #f4f7f6; color: #333; margin: 0; padding: 40px 20px; }}
        .container {{ max-width: 650px; margin: 0 auto; background: white; padding: 30px; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }}
        h1 {{ font-size: 24px; margin-bottom: 5px; }}
        .subtitle {{ color: #666; margin-bottom: 30px; font-size: 14px; }}
        .status-banner {{ padding: 15px 20px; border-radius: 8px; font-weight: 600; font-size: 16px; margin-bottom: 30px; display: flex; align-items: center; gap: 10px; }}
        .operational {{ background-color: #e6f7ed; color: #1e7e34; border: 1px solid #c3e6cb; }}
        .degraded {{ background-color: #fdf2f2; color: #9b1c1c; border: 1px solid #f8b4b4; }}
        .metrics-grid {{ display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px; }}
        .metric-card {{ background: #fafafa; padding: 20px; border-radius: 8px; border: 1px solid #eee; text-align: center; }}
        .metric-value {{ font-size: 28px; font-weight: 700; color: #111; margin-top: 5px; }}
        .metric-label {{ font-size: 12px; color: #666; text-transform: uppercase; letter-spacing: 0.5px; }}
        .footer {{ text-align: center; margin-top: 40px; font-size: 11px; color: #999; }}
    </style>
</head>
<body>
    <div class="container">
        <h1>Chattter Status Pipeline</h1>
        <div class="subtitle">Real-time synthetic infrastructure monitoring dashboard</div>
        
        <div class="status-banner {status_class}">
            <span>{status_icon}</span> {status_text}
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-label">Current Availability (SLI)</div>
                <div class="metric-value">{availability:.2f}%</div>
            </div>
            <div class="metric-card">
                <div class="metric-label">Target Objective (SLO)</div>
                <div class="metric-value">{SLO_TARGET}%</div>
            </div>
        </div>

        <div class="metrics-grid">
            <div class="metric-card">
                <div class="metric-label">Total Audits Evaluated</div>
                <div class="metric-value">{total_checks}</div>
            </div>
            <div class="metric-card">
                <div class="metric-label">Outage Incidents</div>
                <div class="metric-value">{failed_checks}</div>
            </div>
        </div>

        <div class="footer">Powered by Chattter SRE Engine • Updates automatically via GitHub Actions Cloud Engine</div>
    </div>
</body>
</html>
"""
    with open(OUTPUT_FILE, "w") as f:
        f.write(html_content)
    print(f"🎉 Success! Beautiful customer dashboard generated at '{OUTPUT_FILE}'.")

if __name__ == "__main__":
    build_html_dashboard()
