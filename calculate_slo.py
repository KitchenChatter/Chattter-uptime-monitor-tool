import json
import os

LOG_FILE = "server_status.log"
SLO_TARGET = 0.995  # 99.5% Availability Goal

def analyze_fleet_health():
    if not os.path.exists(LOG_FILE):
        print(f"Error: Log file '{LOG_FILE}' not found. Run the bash monitor first.")
        return

    total_checks = 0
    passed_checks = 0
    failed_checks = 0

    print("=== Analyzing Telemetry Data ===")
    
    with open(LOG_FILE, "r") as f:
        for line in f:
            if not line.strip():
                continue
            try:
                # Parse each structured JSON line
                log_entry = json.loads(line)
                total_checks += 1
                
                if log_entry["status"] == "PASS":
                    passed_checks += 1
                else:
                    failed_checks += 1
            except json.JSONDecodeError:
                continue

    if total_checks == 0:
        print("No valid logs found to calculate metrics.")
        return

    # 1. Calculate Core SLI (Service Level Indicator)
    actual_availability = (passed_checks / total_checks) * 100

    # 2. Calculate Error Budget (Allowed vs. Consumed)
    # Using a standard 30-day window simulation based on standard polling intervals
    allowed_failure_rate = 1.0 - SLO_TARGET
    simulated_window_checks = total_checks if total_checks > 100 else 1000  # Baseline sizing
    total_budget_allowed = int(simulated_window_checks * allowed_failure_rate)
    
    remaining_budget = total_budget_allowed - failed_checks
    budget_burnt_pct = (failed_checks / total_budget_allowed) * 100 if total_budget_allowed > 0 else 0

    # 3. Output Production-Grade Metrics Dashboard
    print(f"Total Telemetry Audits Evaluated : {total_checks}")
    print(f"Successful Pings                 : {passed_checks}")
    print(f"Unsuccessful Outages             : {failed_checks}")
    print(f"--------------------------------------------------")
    print(f"Target Availability (SLO)        : {SLO_TARGET * 100:.2f}%")
    print(f"Current Availability (SLI)       : {actual_availability:.2f}%")
    print(f"--------------------------------------------------")
    print(f"Total Error Budget Allowed       : {total_budget_allowed} bad checks")
    print(f"Remaining Error Budget           : {remaining_budget} bad checks")
    print(f"Error Budget Burn Rate           : {budget_burnt_pct:.1f}%")
    print(f"--------------------------------------------------")

    if actual_availability >= (SLO_TARGET * 100):
        print("✅ STATUS: COMPLIANT. Infrastructure operates within established error thresholds.")
    else:
        print("🚨 STATUS: VIOLATION. Error budget is depleted. Freeze feature deployments!")

if __name__ == "__main__":
    analyze_fleet_health()
