#!/bin/bash

# Print header 
print_header() {
  echo "========================================="
  echo "<h1>$1</h1>"
  echo "-----------------------------------------<br>"
}

# Total CPU usage
get_total_cpu(){
  print_header "Total CPU usage"
  if top -bn1 &>/dev/null; then
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $NF}')
    CPU_USED=$(echo "100 - $CPU_IDLE" | bc)
  else
    CPU_USED="N/A (top no disponible)"
  fi
  echo " $CPU_USED%"
}

#  Total memory usage (Free vs Used including percentage)
get_memory_usage() {
    print_header "Total memory usage (Free vs Used including percentage)"
    if free -m &>/dev/null; then
      free -m | awk '/^Mem:/ {mem_total=$2; mem_available=$7} /^Swap:/ {swap_total=$2} END {print "Total Memory:", mem_total + swap_total, "MB<br>"; print "Free Memory (available):", mem_available, "MB<br>"}'
    else
      echo "Memoria no disponible"
    fi
}

# Total disk usage (Free vs Used including percentage)
get_disk_usage() {
    print_header "Total disk usage (Free vs Used including percentage)"
    df -m | awk 'NR>1 {total+=$2; used+=$3; free+=$4} END {printf "Total disk: %d MB<br>Used disk: %d MB (%.2f%%)<br>Free disk: %d MB (%.2f%%)<br>", total, used, (used/total)*100, free, (free/total)*100}'
}

# Top 5 processes by CPU usage
get_topfive_cpu_processes(){
    print_header "Top 5 processes by CPU usage"
    if ps -o pid,comm,%cpu &>/dev/null; then
      ps -o pid,comm,%cpu | sort -k3 -nr | head -n 6 | awk 'NR==1 {print; next} {printf "PID: %-6s PROCESS: %-20s USE_CPU: %.2f%%<br>", $1, $2, $3}'
    else
      top -bn1 | awk 'NR>7 {print $1, $12, $9}' | sort -k3 -nr | head -5 | awk '{printf "PID: %-6s PROCESS: %-20s USE_CPU: %.2f%%<br>", $1, $2, $3}'
    fi
} 

# Top 5 processes by memory usage
get_topfive_memory_processes() {
  print_header "Top 5 processes by memory usage"
  if ps -o pid,comm,%mem &>/dev/null; then
    ps -o pid,comm,%mem | sort -k3 -nr | head -n 6 | awk 'NR==1 {print; next} {printf "PID: %-6s PROCESS: %-20s USE_MEM: %.2f%%<br>", $1, $2, $3}'
  else
    echo "Información de procesos no disponible en BusyBox"
  fi
}

# os version:
get_os_version() {
  print_header "OS VERSION"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Operative System: $PRETTY_NAME"
  else
    echo "SO NOT FOUND."
  fi
}

#  uptime 
get_uptime(){
  print_header "Uptime"
  if uptime &>/dev/null; then
    uptime | awk '{print $3, $4}'
  else
    cat /proc/uptime | awk '{print "Uptime: " int($1/3600) " hours"}'
  fi
}

# load average 
get_load_average() {
  print_header "Load average"
  if uptime &>/dev/null; then
    uptime | awk -F'load average:' '{print "Load average (1 min, 5 min, 15 min):" $2}'
  else
    cat /proc/loadavg | awk '{print "Load average (1 min, 5 min, 15 min):", $1, $2, $3}'
  fi
}

#  logged in users
get_logged_in_users() {
  print_header "Logged in users"
  if who &>/dev/null; then
    who | awk '{printf "User: %-10s Terminal: %-10s Time: %-10s<br>", $1, $2, $3}'
  else
    echo "No disponible en BusyBox"
  fi
}

# failed login attempts
get_failed_login_attempts() {
  print_header "FAIL ATTEMPTS OF LOGIN"
  LOG_FILE="/var/log/auth.log"
  [ ! -f "$LOG_FILE" ] && LOG_FILE="/var/log/secure"
  
  if [ -f "$LOG_FILE" ]; then
    grep "Failed password" "$LOG_FILE" | awk '{printf "Date: %-20s User: %-10s IP: %-15s<br>", $1" "$2" "$3, $9, $11}'
  else
    echo "Fails attempts Not found" 
  fi
}

# Call all the functions
OUTPUT_CPU_USAGE=$(get_total_cpu)
OUTPUT_MEM_USAGE=$(get_memory_usage)
OUTPUT_DISK_USAGE=$(get_disk_usage)
OUTPUT_TOP5C_USAGE=$(get_topfive_cpu_processes)
OUTPUT_TOP5M_USAGE=$(get_topfive_memory_processes)
OUTPUT_OS_VERSION=$(get_os_version)
OUTPUT_UPTIME=$(get_uptime)
OUTPUT_LOAD_AVERAGE=$(get_load_average)
OUTPUT_GET_USERS=$(get_logged_in_users)
OUTPUT_GET_FAILS=$(get_failed_login_attempts)

# URL output HTML file
OUTPUT_FILE="./output/stats.html"

# Create file HTML With Stats
cat <<EOF > $OUTPUT_FILE
<!DOCTYPE html>
<html>
<head>
    <title>Server Stats</title>
</head>
<body>
<p>$OUTPUT_CPU_USAGE</p>
<p>$OUTPUT_MEM_USAGE</p>
<p>$OUTPUT_DISK_USAGE</p>
<p>$OUTPUT_TOP5C_USAGE</p>
<p>$OUTPUT_TOP5M_USAGE</p>
<p>$OUTPUT_OS_VERSION</p>
<p>$OUTPUT_UPTIME</p>
<p>$OUTPUT_LOAD_AVERAGE</p>
<p>$OUTPUT_GET_USERS</p>
<p>$OUTPUT_GET_FAILS</p>
</body>
</html>
EOF
