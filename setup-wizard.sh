#!/bin/bash

# Dockarr Interactive Setup Wizard
# This script provides an interactive way to configure and build docker-compose.yml

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR"
WIZARD_DIR="$PROJECT_ROOT/wizard"
TEMPLATES_DIR="$PROJECT_ROOT/templates"

# Source service configuration
source "$WIZARD_DIR/service-config.sh"

# Global configuration variables
WIZARD_CONFIG_FILE="$PROJECT_ROOT/.wizard-config"
SELECTED_SERVICES=()
HARDWARE_ACCELERATION=false
ENVIRONMENT="production"
DO_CLEAN=false
DO_SETUP=false

# Utility functions
print_header() {
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${WHITE}${BOLD}                    DOCKARR SETUP WIZARD                     ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

print_step() {
    echo -e "\n${CYAN}${BOLD}➤ $1${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Prompt user for yes/no
ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local response
    
    while true; do
        if [[ "$default" == "y" ]]; then
            echo -n -e "${YELLOW}$prompt [Y/n]: ${NC}"
        else
            echo -n -e "${YELLOW}$prompt [y/N]: ${NC}"
        fi
        
        read -r response
        response=$(echo "$response" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
        
        if [[ -z "$response" ]]; then
            response="$default"
        fi
        
        case "$response" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                print_error "Please answer yes or no"
                ;;
        esac
    done
}

# Show a menu and get user selection
show_menu() {
    local title="$1"
    shift
    local options=("$@")
    local choice
    
    echo -e "${WHITE}${BOLD}$title${NC}\n"
    
    for i in "${!options[@]}"; do
        echo -e "${CYAN}$((i + 1))${NC}. ${options[i]}"
    done
    
    echo -e "\n${YELLOW}Enter your choice (1-${#options[@]}): ${NC}"
    while true; do
        read -r choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            return $((choice - 1))
        else
            print_error "Invalid choice. Please enter a number between 1 and ${#options[@]}"
        fi
    done
}

# Clean setup step
clean_setup_step() {
    print_step "Pre-flight Cleanup"
    
    if ask_yes_no "Do you want to perform a clean setup (removes existing containers and volumes)?" "n"; then
        DO_CLEAN=true
        print_info "Clean setup will be performed"
    else
        print_info "Skipping clean setup"
    fi
}

# Initial setup step  
initial_setup_step() {
    print_step "Initial Setup"
    
    if ask_yes_no "Do you want to run initial setup (permissions, .env file)?" "y"; then
        DO_SETUP=true
        print_info "Initial setup will be performed"
    else
        print_info "Skipping initial setup"
    fi
}

# Service selection step
service_selection_step() {
    print_step "Service Selection"
    
    local selection_types=(
        "Complete preset (All services included)"
        "Custom selection (Choose individual services)"
    )
    
    show_menu "Choose your service configuration:" "${selection_types[@]}"
    local selection_choice=$?
    
    case $selection_choice in
        0)
            IFS=',' read -ra SELECTED_SERVICES <<< "$(get_bundle_services "complete")"
            print_success "Selected: Complete preset (${#SELECTED_SERVICES[@]} services)"
            ;;
        1)
            custom_service_selection
            ;;
    esac
    
    # Show selected services
    echo -e "\n${WHITE}Selected services:${NC}"
    for service in "${SELECTED_SERVICES[@]}"; do
        local service_name=$(get_service_name "$service")
        local service_desc=$(get_service_description "$service")
        echo -e "  ${GREEN}•${NC} ${BOLD}$service_name${NC} - $service_desc"
    done
}

# Custom service selection with checkboxes
custom_service_selection() {
    print_info "Custom Service Selection"
    echo -e "${YELLOW}Select services by typing their numbers separated by spaces (e.g., 1 3 5 7)${NC}\n"
    
    local all_services=($(get_all_services))
    local service_numbers=()
    
    # Display services with numbers
    for i in "${!all_services[@]}"; do
        local service="${all_services[i]}"
        local category=$(get_service_category "$service")
        local name=$(get_service_name "$service")
        local desc=$(get_service_description "$service")
        
        echo -e "${CYAN}$((i + 1))${NC}. ${BOLD}$name${NC} [$category] - $desc"
    done
    
    echo -e "\n${YELLOW}Enter service numbers: ${NC}"
    read -r input
    
    # Parse selected numbers
    SELECTED_SERVICES=()
    for num in $input; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le "${#all_services[@]}" ]; then
            local service_index=$((num - 1))
            SELECTED_SERVICES+=("${all_services[service_index]}")
        fi
    done
    
    if [ ${#SELECTED_SERVICES[@]} -eq 0 ]; then
        print_warning "No services selected, using basic preset"
        IFS=',' read -ra SELECTED_SERVICES <<< "$(get_bundle_services "basic")"
    fi
    
    print_success "Selected ${#SELECTED_SERVICES[@]} custom services"
}

# Hardware acceleration step
hardware_acceleration_step() {
    print_step "Hardware Acceleration"
    
    # Only ask if Jellyfin is selected
    local has_jellyfin=false
    for service in "${SELECTED_SERVICES[@]}"; do
        if [[ "$service" == "jellyfin" ]]; then
            has_jellyfin=true
            break
        fi
    done
    
    if $has_jellyfin; then
        if ask_yes_no "Enable hardware acceleration for Jellyfin? (Requires compatible GPU)" "n"; then
            HARDWARE_ACCELERATION=true
            print_success "Hardware acceleration enabled"
            print_info "Make sure your system has /dev/dri available for GPU acceleration"
        else
            HARDWARE_ACCELERATION=false
            print_info "Hardware acceleration disabled"
        fi
    else
        print_info "Jellyfin not selected, skipping hardware acceleration"
    fi
}

# Configuration summary
show_summary() {
    print_step "Configuration Summary"
    
    echo -e "${WHITE}${BOLD}Your Configuration:${NC}\n"
    echo -e "${CYAN}Environment:${NC} $ENVIRONMENT"
    echo -e "${CYAN}Clean Setup:${NC} $DO_CLEAN"
    echo -e "${CYAN}Initial Setup:${NC} $DO_SETUP"
    echo -e "${CYAN}Hardware Acceleration:${NC} $HARDWARE_ACCELERATION"
    echo -e "${CYAN}Selected Services (${#SELECTED_SERVICES[@]}):${NC}"
    
    for service in "${SELECTED_SERVICES[@]}"; do
        local name=$(get_service_name "$service")
        local category=$(get_service_category "$service")
        echo -e "  ${GREEN}•${NC} $name ${YELLOW}[$category]${NC}"
    done
    
    echo ""
    if ask_yes_no "Proceed with this configuration?" "y"; then
        return 0
    else
        print_info "Configuration cancelled"
        exit 0
    fi
}

# Save configuration for the builder
save_config() {
    # Convert array to space-separated string for sh compatibility
    local services_string=""
    for service in "${SELECTED_SERVICES[@]}"; do
        if [ -n "$services_string" ]; then
            services_string="$services_string $service"
        else
            services_string="$service"
        fi
    done
    
    cat > "$WIZARD_CONFIG_FILE" << EOF
ENVIRONMENT="$ENVIRONMENT"
DO_CLEAN=$DO_CLEAN
DO_SETUP=$DO_SETUP
HARDWARE_ACCELERATION=$HARDWARE_ACCELERATION
SELECTED_SERVICES="$services_string"
EOF
    print_success "Configuration saved to $WIZARD_CONFIG_FILE"
}

# Main wizard flow
main() {
    print_header
    
    print_info "This wizard will help you configure your Dockarr setup interactively"
    print_info "Press Ctrl+C at any time to cancel\n"
    
    # Run wizard steps
    clean_setup_step
    initial_setup_step  
    service_selection_step
    hardware_acceleration_step
    
    # Show summary and confirm
    show_summary
    
    # Save configuration
    save_config
    
    print_success "Wizard completed! Run 'make build-compose' to generate docker-compose.yml"
    print_info "Or run 'make wizard-deploy' to build and start services immediately"
}

# Handle interrupts gracefully
trap 'echo -e "\n${RED}Wizard cancelled by user${NC}"; exit 1' INT

# Run main function
main "$@"