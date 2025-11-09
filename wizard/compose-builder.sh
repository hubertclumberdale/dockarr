#!/bin/bash

# Docker Compose Builder
# This script builds the final docker-compose.yml from selected service templates

set -e

# Colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'
BOLD='\033[1m'

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WIZARD_DIR="$PROJECT_ROOT/wizard"
TEMPLATES_DIR="$PROJECT_ROOT/templates"
WIZARD_CONFIG_FILE="$PROJECT_ROOT/.wizard-config"

# Source service configuration
source "$WIZARD_DIR/service-config.sh"

# Default output files
COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"
DEV_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.development.yml"

# Utility functions
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

# Load wizard configuration
load_config() {
    if [[ ! -f "$WIZARD_CONFIG_FILE" ]]; then
        print_error "No wizard configuration found. Please run 'make wizard' first."
        exit 1
    fi
    
    source "$WIZARD_CONFIG_FILE"
    print_info "Loaded configuration from $WIZARD_CONFIG_FILE"
}

# Resolve service dependencies
resolve_dependencies() {
    local services=("$@")
    local resolved_services=()
    local processed=()
    
    # Function to recursively add dependencies
    add_service_and_deps() {
        local service="$1"
        
        # Skip if already processed
        for proc in "${processed[@]}"; do
            if [[ "$proc" == "$service" ]]; then
                return
            fi
        done
        
        # Add dependencies first
        local deps=$(get_service_deps "$service")
        if [[ -n "$deps" ]]; then
            IFS=',' read -ra dep_array <<< "$deps"
            for dep in "${dep_array[@]}"; do
                add_service_and_deps "$dep"
            done
        fi
        
        # Add the service itself
        resolved_services+=("$service")
        processed+=("$service")
    }
    
    # Process each selected service
    for service in "${services[@]}"; do
        add_service_and_deps "$service"
    done
    
    # Return unique services maintaining order
    printf "%s\n" "${resolved_services[@]}" | awk '!seen[$0]++'
}

# Check if service template exists
service_template_exists() {
    local service="$1"
    local template_file="$TEMPLATES_DIR/services/$service.yml"
    
    if [[ -f "$template_file" ]]; then
        return 0
    else
        return 1
    fi
}

# Get the correct Jellyfin template based on hardware acceleration
get_jellyfin_template() {
    if $HARDWARE_ACCELERATION; then
        echo "$TEMPLATES_DIR/services/jellyfin-hw.yml"
    else
        echo "$TEMPLATES_DIR/services/jellyfin.yml"
    fi
}

# Build the docker-compose file
build_compose() {
    local output_file="$1"
    local temp_file=$(mktemp)
    
    print_info "Building docker-compose file: $output_file"
    
    # Start with the services header
    echo "services:" > "$temp_file"
    
    # Resolve all dependencies
    local all_services=($(resolve_dependencies "${SELECTED_SERVICES[@]}"))
    
    print_info "Including services with dependencies: ${all_services[*]}"
    
    # Add each service
    for service in "${all_services[@]}"; do
        local template_file="$TEMPLATES_DIR/services/$service.yml"
        
        # Special case for Jellyfin hardware acceleration
        if [[ "$service" == "jellyfin" ]]; then
            template_file=$(get_jellyfin_template)
        fi
        
        if service_template_exists "$service" || [[ "$service" == "jellyfin" ]]; then
            echo "" >> "$temp_file"
            cat "$template_file" >> "$temp_file"
            print_info "Added service: $service"
        else
            print_warning "Template not found for service: $service"
        fi
    done
    
    # Add base configuration (volumes, networks)
    echo "" >> "$temp_file"
    cat "$TEMPLATES_DIR/base.yml" >> "$temp_file"
    
    # Move temp file to final location
    mv "$temp_file" "$output_file"
    
    print_success "Docker compose file built: $output_file"
}

# Backup existing compose file
backup_existing_compose() {
    local compose_file="$1"
    
    if [[ -f "$compose_file" ]]; then
        local backup_file="${compose_file}.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$compose_file" "$backup_file"
        print_info "Backed up existing file to: $backup_file"
    fi
}

# Validate the generated compose file
validate_compose() {
    local compose_file="$1"
    
    print_info "Validating docker-compose file..."
    
    if docker-compose -f "$compose_file" config > /dev/null 2>&1; then
        print_success "Docker-compose file is valid"
    else
        print_error "Docker-compose file validation failed"
        print_info "Running docker-compose config to show errors:"
        docker-compose -f "$compose_file" config || true
        exit 1
    fi
}

# Perform cleanup if requested
perform_cleanup() {
    if $DO_CLEAN; then
        print_info "Performing cleanup..."
        
        # Determine which compose file to use for cleanup
        local cleanup_compose="$COMPOSE_FILE"
        if [[ "$ENVIRONMENT" == "development" ]]; then
            cleanup_compose="$DEV_COMPOSE_FILE"
        fi
        
        if [[ -f "$cleanup_compose" ]]; then
            docker-compose -f "$cleanup_compose" down -v 2>/dev/null || true
            print_success "Cleanup completed"
        else
            print_info "No existing compose file to clean"
        fi
    fi
}

# Perform initial setup if requested
perform_setup() {
    if $DO_SETUP; then
        print_info "Performing initial setup..."
        
        # Run the setup from Makefile
        if [[ -f "$PROJECT_ROOT/Makefile" ]]; then
            make -C "$PROJECT_ROOT" setup
            print_success "Initial setup completed"
        else
            print_warning "Makefile not found, skipping setup"
        fi
    fi
}

# Show configuration summary
show_build_summary() {
    local output_file="$1"
    local service_count=${#SELECTED_SERVICES[@]}
    
    echo -e "\n${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}                    BUILD SUMMARY                            ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${YELLOW}Environment:${NC} $ENVIRONMENT"
    echo -e "${YELLOW}Output file:${NC} $output_file"
    echo -e "${YELLOW}Services:${NC} $service_count selected"
    echo -e "${YELLOW}Hardware acceleration:${NC} $HARDWARE_ACCELERATION"
    echo -e "${YELLOW}Cleanup:${NC} $DO_CLEAN"
    echo -e "${YELLOW}Setup:${NC} $DO_SETUP"
    
    echo -e "\n${GREEN}Ready to build docker-compose configuration!${NC}\n"
}

# Main function
main() {
    print_info "Starting Docker Compose Builder..."
    
    # Load configuration
    load_config
    
    # Determine output file based on environment
    local output_file="$COMPOSE_FILE"
    if [[ "$ENVIRONMENT" == "development" ]]; then
        output_file="$DEV_COMPOSE_FILE"
    fi
    
    # Show summary
    show_build_summary "$output_file"
    
    # Backup existing compose file
    backup_existing_compose "$output_file"
    
    # Perform cleanup if requested
    perform_cleanup
    
    # Build the compose file
    build_compose "$output_file"
    
    # Validate the generated file
    validate_compose "$output_file"
    
    # Perform setup if requested
    perform_setup
    
    print_success "Build completed successfully!"
    print_info "You can now run:"
    
    if [[ "$ENVIRONMENT" == "development" ]]; then
        echo -e "  ${BLUE}make dev${NC}     # Start development environment"
    else
        echo -e "  ${BLUE}make start${NC}   # Start production environment"
    fi
    
    echo -e "  ${BLUE}make logs${NC}    # View logs"
    echo -e "  ${BLUE}make stop${NC}    # Stop all services"
}

# Handle interrupts
trap 'echo -e "\n${RED}Build cancelled by user${NC}"; exit 1' INT

# Run main function
main "$@"