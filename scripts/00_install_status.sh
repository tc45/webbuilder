#!/bin/bash

# Get base directory from setup_new_django.sh location
BASE_DIR="$(pwd)"  # Where setup_new_django.sh is located
SCRIPT_DIR="${BASE_DIR}/scripts"  # Scripts directory under BASE_DIR
LOG_FILE="${BASE_DIR}/install.log"  # Log file in BASE_DIR

# Source common functions
source "${SCRIPT_DIR}/common.sh"

# Define installation steps in order of execution
declare -A STEPS=(
    [1]="Initial Setup"
    [2]="Django Setup"
    [3]="Settings Config"
    [4]="Templates Setup"
    [5]="Database Setup"
    [6]="Git Config"
    [7]="Gunicorn Setup"
    [8]="Nginx Config"

    [9]="Next Steps"
)

# Function to find the appropriate script for a step
find_script() {
    local step=$1
    local script_name=""
    
    case $step in
        1) script_name="01_initial_setup.sh" ;;
        2) script_name="02_django_setup.sh" ;;
        3) script_name="03_settings_setup.sh" ;;
        4) script_name="04_templates_setup.sh" ;;
        5) script_name="57_database_setup.sh" ;;
        6) script_name="06_git_setup.sh" ;;
        7) script_name="07_gunicorn_setup.sh" ;;
        8) script_name="08_nginx_setup.sh" ;;
        9) script_name="09_next_steps.sh" ;;
        *) return 1 ;;
    esac
    
    # Use SCRIPT_DIR for finding installation scripts
    echo "${SCRIPT_DIR}/${script_name}"
}

# Function to display progress bar
display_progress_bar() {
    local progress=$1
    local width=30
    local filled=$((progress * width / 100))
    local empty=$((width - filled))
    
    printf "["
    printf "%${filled}s" | tr ' ' '='
    printf "%${empty}s" | tr ' ' ' '
    printf "] %3d%%" "$progress"
}

# Function to calculate overall progress
calculate_overall_progress() {
    local -n prog_array=$1
    local total=0
    local count=0
    
    for i in {1..9}; do
        if [ "${prog_array[$i]}" -ne -1 ]; then
            total=$((total + prog_array[$i]))
            count=$((count + 1))
        fi
    done
    
    if [ "$count" -eq 0 ]; then
        echo 0
    else
        echo $((total / count))
    fi
}

# Function to display status table
display_status_table() {
    local current_step=$1
    local -n progress_ref=$2
    local failed_step=$3
    
    clear
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║                    Installation Progress                       ║"
    echo "╠════════════════════════════════════════════════════════════════╣"
    
    # Calculate and display overall progress first
    local overall_progress=$(calculate_overall_progress progress_ref)
    printf "║ %-20s " "${STEPS[0]}"
    display_progress_bar "$overall_progress"
    echo " ║"
    echo "╟────────────────────────────────────────────────────────────────╢"
    
    # Display individual steps in order (1 to 9)
    for ((i=1; i<=9; i++)); do
        printf "║ "
        
        # Determine step status
        if [ $i -eq $current_step ]; then
            printf "\e[1;33m%-20s\e[0m" "${STEPS[$i]}"  # Current step (yellow)
        elif [ $i -eq $failed_step ]; then
            printf "\e[1;31m%-20s\e[0m" "${STEPS[$i]}"  # Failed step (red)
        else
            printf "%-20s" "${STEPS[$i]}"
        fi
        
        printf " "
        
        # Display progress bar
        if [ "${progress_ref[$i]}" -eq -1 ]; then
            printf "%-35s" "Pending..."
        elif [ "${progress_ref[$i]}" -eq 100 ]; then
            printf "\e[1;32m%-35s\e[0m" "Complete"
        else
            display_progress_bar "${progress_ref[$i]}"
        fi
        
        echo " ║"
    done
    
    echo "╚════════════════════════════════════════════════════════════════╝"
}

# Function to run complete installation
run_installation() {
    # Debug: Print current working directory and script locations
    log_message "DEBUG: Current working directory: $(pwd)"
    log_message "DEBUG: Script directory: ${SCRIPT_DIR}"
    log_message "DEBUG: Installation path: ${INSTALL_PATH}"
    
    # Initialize progress array
    declare -a progress_array
    for i in {1..9}; do
        progress_array[$i]=-1  # Set to -1 for "Pending"
    done
    
    # Ensure LOG_FILE exists and is writable
    touch "$LOG_FILE"
    chmod 666 "$LOG_FILE"
    
    # Debug: Print all environment variables
    log_message "DEBUG: Environment variables:"
    log_message "PROJECT_NAME=${PROJECT_NAME}"
    log_message "INSTALL_PATH=${INSTALL_PATH}"
    log_message "SCRIPTS_PATH=${SCRIPTS_PATH}"
    log_message "DOMAIN_NAME=${DOMAIN_NAME}"
    log_message "DB_TYPE=${DB_TYPE}"
    
    # Export important variables for child scripts
    export PROJECT_NAME INSTALL_PATH ADMIN_USER ADMIN_PASSWORD DOMAIN_NAME DB_TYPE PYTHON_VERSION DEBUG_MODE DJANGO_PORT LOG_FILE
    
    # Add debug logging for script paths
    log_message "DEBUG: Script directory path: ${SCRIPT_DIR}"
    log_message "DEBUG: Base installation path: ${INSTALL_PATH}"
    
    # Execute each step sequentially
    # Steps are numbered 1-9 corresponding to installation phases:
    # 1. Initial Setup - Basic directory structure and permissions
    # 2. Django Setup - Install Django and create project
    # 3. Settings Config - Configure Django settings
    # 4. Templates Setup - Set up template structure
    # 5. Nginx Config - Configure Nginx web server
    # 6. Gunicorn Setup - Configure Gunicorn WSGI server
    # 7. Database Setup - Initialize and configure database
    # 8. Git Config - Set up version control
    # 9. Next Steps - Final configuration and cleanup

    log_message "Starting installation process..."
    log_message "----------------------------------------"
    
    # Run 00_init.sh first
    log_message "Running initialization script..."
    init_script="${SCRIPT_DIR}/00_init.sh"
    
    if [ -f "$init_script" ]; then
        log_message "DEBUG: Found init script: $init_script"
        source "$init_script" || {
            log_message "ERROR: Initialization failed"
            return 1
        }
    else
        log_message "ERROR: Init script not found: $init_script"
        return 1
    fi
    
    # Export required variables
    export PROJECT_NAME INSTALL_PATH ADMIN_USER ADMIN_PASSWORD DOMAIN_NAME DB_TYPE PYTHON_VERSION DEBUG_MODE DJANGO_PORT LOG_FILE
    
    # Run each installation step
    for step in {1..9}; do
        progress_array[$step]=0  # Set to 0 for "In Progress"
        display_status_table $step progress_array -1
        
        # Use exact script name instead of wildcard
        script="${SCRIPT_DIR}/$(printf "%02d" $step)_"
        case $step in
            1) script+="initial_setup.sh" ;;
            2) script+="django_setup.sh" ;;
            3) script+="settings_setup.sh" ;;
            4) script+="templates_setup.sh" ;;
            5) script+="database_setup.sh" ;;
            6) script+="git_setup.sh" ;;
            7) script+="gunicorn_setup.sh" ;;            
            8) script+="nginx_setup.sh" ;;
            9) script+="next_steps.sh" ;;
        esac
        
        log_message "DEBUG: Looking for script: $script"
        
        if [ -f "$script" ]; then
            log_message "DEBUG: Found script: $script"
            log_message "Starting step $step: ${STEPS[$step]}"
            
            # Execute the script with proper environment
            (
                # Source common functions in subshell
                source "${SCRIPT_DIR}/common.sh"
                if bash "$script" >> "$LOG_FILE" 2>&1; then
                    progress_array[$step]=100
                    display_status_table $step progress_array -1
                    log_message "Step $step completed successfully"
                else
                    local exit_code=$?
                    display_status_table $step progress_array $step
                    log_message "Step $step failed with exit code $exit_code"
                    echo -e "\nInstallation failed at step $step (${STEPS[$step]})"
                    echo "Check $LOG_FILE for details"
                    exit $exit_code
                fi
            )
            
            # Check if the subshell failed
            if [ $? -ne 0 ]; then
                return 1
            fi
        else
            log_message "ERROR: Script not found: $script"
            echo "Script for step $step not found: $script"
            return 1
        fi
        
        log_message "----------------------------------------"
    done
    
    display_status_table 9 progress_array -1
    log_message "Installation completed successfully"
    echo -e "\nInstallation completed successfully"
    return 0
}