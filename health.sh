#!/bin/bash


LOG_FILE="system_health_report.txt"
DISK_THRESHOLD=90  # Disk usage percent considered critical
MEMORY_THRESHOLD=90  # Memory usage percent considered critical


check_disk_space() {
     echo "Disk Space Usage:" | tee -a $LOG_FILE
    df -h | tee -a $LOG_FILE 
    echo "--------------------------------------------"
}


check_memory_usage() {
   check_memory_usage() {
    echo "Memory Usage:" | tee -a $LOG_FILE
    free -h | tee -a $LOG_FILE  # Display memory usage in human-readable format
}
        echo "--------------------------------------------"
}


check_running_services() {
     echo "Running Services:" | tee -a $LOG_FILE
    if type systemctl &> /dev/null; then
        # System using systemd
        systemctl list-units --type=service --state=running | tee -a $LOG_FILE
    else
        # Fallback for older systems
        service --status-all | tee -a $LOG_FILE
    fi
        echo "--------------------------------------------"
}


check_system_updates() {
    echo "Checking for Recent System Updates:" | tee -a $LOG_FILE
    last_update=$(grep "upgrade " /var/log/dpkg.log | tail -1 | awk '{print $1, $2}')
    if [ -z "$last_update" ]; then
        echo "No recent system updates recorded." | tee -a $LOG_FILE
    else
        echo "Last update was on: $last_update" | tee -a $LOG_FILE
    fi
        echo "--------------------------------------------"
}


provide_recommendations() {
    echo "Providing recommendations:" | tee -a $LOG_FILE
    # Add logic to provide recommendations based on the checks performed above
    # This is a place for custom recommendations relevant to your system or environment
    echo "1. Ensure disk usage is below $DISK_THRESHOLD%." | tee -a $LOG_FILE
    echo "2. Keep memory usage below $MEMORY_THRESHOLD%." | tee -a $LOG_FILE
    echo "3. Regularly check for and install system updates." | tee -a $LOG_FILE
    echo "--------------------------------------------" | tee -a $LOG_FILE
}


generate_health_report() {
    echo "Starting System Health Check:" | tee -a $LOG_FILE
    check_disk_space
    check_memory_usage
    check_running_services
    check_system_updates
    provide_recommendations
    echo "System Health Check Completed." | tee -a $LOG_FILE
}

# Clear previous log file
> $LOG_FILE

# Run the main function
generate_health_report

