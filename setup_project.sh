#!/usr/bin/env bash
# Setup script for Student Attendance Tracker project factory

# --- Step 3: Process Management (Trap) ---
cleanup() {
    echo ""
    echo "Interrupt received! Archiving and cleaning up..."
    tar -czf "attendance_tracker_${input}_archive.tar.gz" "attendance_tracker_${input}"
    rm -rf "attendance_tracker_${input}"
    echo "Archive created: attendance_tracker_${input}_archive.tar.gz"
    exit 1
}

trap cleanup SIGINT

# --- Step 1: Directory Architecture ---
read -p "Enter project name: " input

mkdir -p "attendance_tracker_${input}/Helpers"
mkdir -p "attendance_tracker_${input}/reports"

# --- Create project files ---
cat > "attendance_tracker_${input}/attendance_checker.py" << 'PYEOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
PYEOF

cat > "attendance_tracker_${input}/Helpers/assets.csv" << 'EOF2'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF2

cat > "attendance_tracker_${input}/Helpers/config.json" << 'EOF3'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF3

cat > "attendance_tracker_${input}/reports/reports.log" << 'EOF4'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF4

# --- Step 2: Dynamic Configuration ---
read -p "Do you want to update the attendance thresholds? (yes/no): " update_choice

if [ "$update_choice" = "yes" ]; then
    read -p "Enter new Warning threshold (default 75): " warning_val
    read -p "Enter new Failure threshold (default 50): " failure_val
    sed -i "s/\"warning\": [0-9]*/\"warning\": ${warning_val}/" "attendance_tracker_${input}/Helpers/config.json"
    sed -i "s/\"failure\": [0-9]*/\"failure\": ${failure_val}/" "attendance_tracker_${input}/Helpers/config.json"
    echo "Thresholds updated successfully."
fi

# --- Step 4: Environment Validation ---
echo ""
echo "Running Health Check..."

if python3 --version 2>/dev/null; then
    echo "python3 is installed."
else
    echo "WARNING: python3 is not installed on this system."
fi

if [ -f "attendance_tracker_${input}/attendance_checker.py" ] &&
   [ -f "attendance_tracker_${input}/Helpers/assets.csv" ] &&
   [ -f "attendance_tracker_${input}/Helpers/config.json" ] &&
   [ -f "attendance_tracker_${input}/reports/reports.log" ]; then
    echo "Directory structure check passed."
else
    echo "WARNING: Directory structure is incomplete."
fi

echo ""
echo "Setup complete! Project created at: attendance_tracker_${input}/"

