#!/bin/bash

# Source common functions
SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/common.sh"

log_message "Starting progress tracking functions setup..."

# Function to start progress tracking
start_progress() {
    local task="$1"
    echo "0" > "/tmp/progress_${task}.txt"
    log_message "Started progress tracking for: $task"
}

# Function to update progress
update_progress() {
    local task="$1"
    local progress="$2"
    echo "$progress" > "/tmp/progress_${task}.txt"
}

# Function to get current progress
get_progress() {
    local task="$1"
    local progress_file="/tmp/progress_${task}.txt"
    if [ -f "$progress_file" ]; then
        cat "$progress_file"
    else
        echo "0"
    fi
}

# Function to end progress tracking
end_progress() {
    local task="$1"
    rm -f "/tmp/progress_${task}.txt"
    log_message "Completed progress tracking for: $task"
}

# Export functions
export -f start_progress
export -f update_progress
export -f get_progress
export -f end_progress

log_message "Progress tracking functions setup completed" 