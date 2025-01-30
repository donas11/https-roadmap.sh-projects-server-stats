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
  CPU_USED=$(top -bn1 | grep "Cpu(s)" | sed -n 's/.* \([0-9,]*\)%* id.*/\1/p' | awk '100 - $1')
  echo " $CPU_USED%" 
}

#  Total memory usage (Free vs Used including percentage)
get_memory_usage() {
    print_header "Total memory usage (Free vs Used including percentage)"
    MEM_USED=$(free -m | awk '/^Mem:/ {mem_total=$2; mem_available=$7} /^Inter:/ {inter_total=$2} END {print "Total Memory :", mem_total + inter_total, "MB"; print "Free Memory  (available):", mem_available, "MB"}' )
    echo " $MEM_USED"
}

# Total disk usage (Free vs Used including percentage)
get_disk_usage() {
    print_header "Total disk usage (Free vs Used including percentage)"
    DISK_USE=$(df -h --total | awk '/^total/ {printf "Total disk: %s<br> \nUsed disk: %s (%.2f%%)<br> \nFree disk: %s (%.2f%%)<br> \n", $2, $3, ($3/$2)*100, $4, ($4/$2)*100}')
    echo " $DISK_USE"
}

# Top 5 processes by CPU usage

get_topfive_cpu_processes(){
    print_header "Top 5 processes by CPU usage"
    TOP_FIVE_CPU=$(ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | awk 'NR==1 {print; next} {printf "PID: %-6s PROCESS: %-20s USE_CPU: %.2f%%<br> \n", $1, $2, $3}')
    echo " $TOP_FIVE_CPU"
} 


# Top 5 processes by memory usage
get_topfive_memory_processes() {
  print_header "Top 5 processes by memory usage"
  ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | awk 'NR==1 {print; next} {printf "PID: %-6s PROCESS: %-20s USE_MEM: %.2f%%<br> \n", $1, $2, $3}'
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
  print_header "uptime"
  uptime | awk '{print $1}'
}


# load average 
get_load_average() {
  print_header "Load average"
  uptime | awk -F'load average:' '{print "Load average (1 min, 5 min, 15 min):" $2}'
}

#  logged in users
get_logged_in_users() {
  print_header "Logged in users"
  who | awk '{printf "User: %-10s Terminal: %-10s Time: %-10s<br> \n", $1, $2, $3}'
}

# failed login attempts
get_failed_login_attempts() {
  print_header "FAIL ATTEMPTS OF LOGIN"
  if [ -f /var/log/auth.log ]; then
    grep "Failed password" /var/log/auth.log | awk '{printf "Date: %-20s User: %-10s IP: %-15s<br> \n", $1" "$2" "$3, $9, $11}'
  elif [ -f /var/log/secure ]; then
    grep "Failed password" /var/log/secure | awk '{printf "Date: %-20s User: %-10s IP: %-15s<br> \n", $1" "$2" "$3, $9, $11}'
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
<p>$OUTPUT_CPU_USAGE </p>
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
