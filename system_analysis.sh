#!/bin/bash

# Define variables
REPORT_DIR="/home/oloo/Documents/utils/Reports"
REPORT_FILE="$REPORT_DIR/system_report_$(date +%Y%m%d%H%M).html"
EMAIL="asirastephen9@gmail.com.com"
PLOTS_DIR="$REPORT_DIR/plots"

# Create directories if they don't exist
mkdir -p $REPORT_DIR $PLOTS_DIR

# Collect system metrics
df -h > $REPORT_DIR/disk_usage.txt
top -b -n1 | head -n 20 > $REPORT_DIR/cpu_usage.txt
nmcli dev wifi > $REPORT_DIR/wifi_status.txt
dmesg | tail -n 20 > $REPORT_DIR/error_logs.txt
iostat > $REPORT_DIR/io_stats.txt
ifstat -i wlp2s0 1 1 | tail -n 1 > $REPORT_DIR/network_speed.txt  

# Collect system error logs from journalctl
journalctl -p 3 -xb | tail -n 20 > $REPORT_DIR/system_error_logs.txt

# Clear trash
gio trash --empty

# Generate graphs with gnuplot
gnuplot << EOF
set terminal png size 800,600
set output '$PLOTS_DIR/cpu_usage.png'
set title 'CPU Usage'
set xlabel 'Time'
set ylabel 'Usage'
plot '$REPORT_DIR/cpu_usage.txt' using 1:2 with lines title 'CPU Usage'
EOF

# Create HTML report
cat << 'EOF' > $REPORT_FILE
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>System Analysis Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #333; }
        h2 { color: #555; }
        pre { background: #f4f4f4; padding: 10px; border: 1px solid #ddd; overflow-x: auto; }
        img { max-width: 100%; height: auto; }
        .section { margin-bottom: 20px; }
        .toggle-button { cursor: pointer; color: #0066cc; text-decoration: underline; }
    </style>
    <script>
        function toggleVisibility(id) {
            var element = document.getElementById(id);
            if (element.style.display === 'none') {
                element.style.display = 'block';
            } else {
                element.style.display = 'none';
            }
        }
    </script>
</head>
<body>
    <h1>System Analysis Report</h1>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('disk_usage')">Disk Usage</h2>
        <pre id="disk_usage" style="display: none;">$(cat $REPORT_DIR/disk_usage.txt)</pre>
    </div>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('cpu_usage')">CPU Usage</h2>
        <pre id="cpu_usage" style="display: none;">$(cat $REPORT_DIR/cpu_usage.txt)</pre>
        <img src="$PLOTS_DIR/cpu_usage.png" alt="CPU Usage Graph">
    </div>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('wifi_status')">WiFi Status</h2>
        <pre id="wifi_status" style="display: none;">$(cat $REPORT_DIR/wifi_status.txt)</pre>
    </div>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('error_logs')">Error Logs</h2>
        <pre id="error_logs" style="display: none;">$(cat $REPORT_DIR/error_logs.txt)</pre>
    </div>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('io_stats')">I/O Statistics</h2>
        <pre id="io_stats" style="display: none;">$(cat $REPORT_DIR/io_stats.txt)</pre>
    </div>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('network_speed')">Network Speed</h2>
        <pre id="network_speed" style="display: none;">$(cat $REPORT_DIR/network_speed.txt)</pre>
    </div>
    <div class="section">
        <h2 class="toggle-button" onclick="toggleVisibility('system_error_logs')">System Error Logs</h2>
        <pre id="system_error_logs" style="display: none;">$(cat $REPORT_DIR/system_error_logs.txt)</pre>
    </div>
</body>
</html>
EOF

# Send the report via email
mailx -a $REPORT_FILE -s "System Analysis Report" $EMAIL < /dev/null

