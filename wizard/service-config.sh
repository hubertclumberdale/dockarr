#!/bin/bash

# Configuration file for service presets and dependencies
# This file defines service categories, dependencies, and configurations

# Service definitions (format: service_name:category:display_name:description)
SERVICES_DATA="
config-processor:essential:Configuration processor:Always required
gluetun:download:VPN service:Protects download services
qbittorrent:download:Torrent client:Download torrents via VPN
sonarr:media:TV show manager:Manages TV series downloads
radarr:media:Movie manager:Manages movie downloads
jellyfin:media:Media server:Streams your media library
jellyseerr:media:Request manager:Request movies and TV shows
prowlarr:indexing:Indexer manager:Manages torrent indexers
bazarr:media:Subtitle manager:Downloads subtitles automatically
flaresolverr:indexing:Cloudflare solver:Bypasses Cloudflare protection
flemmarr:automation:Flemmarr integration:Advanced automation tool
dozzle:monitoring:Log viewer:Real-time Docker log viewer
"

# Service dependencies (format: service:dependency1,dependency2,...)
DEPENDENCIES_DATA="
qbittorrent:gluetun
sonarr:config-processor
radarr:config-processor
jellyfin:config-processor
jellyseerr:config-processor
flemmarr:config-processor,sonarr,radarr,prowlarr,bazarr,qbittorrent
"

# Predefined service bundles (format: bundle_name:service1,service2,...)
BUNDLES_DATA="
complete:bazarr,config-processor,dozzle,flaresolverr,flemmarr,gluetun,jellyfin,jellyseerr,prowlarr,qbittorrent,radarr,sonarr
"

# Functions to work with services

get_service_info() {
    local service=$1
    echo "$SERVICES_DATA" | grep "^$service:" | head -n1
}

get_service_category() {
    local service=$1
    local info=$(get_service_info "$service")
    echo "${info}" | cut -d: -f2
}

get_service_name() {
    local service=$1
    local info=$(get_service_info "$service")
    echo "${info}" | cut -d: -f3
}

get_service_description() {
    local service=$1
    local info=$(get_service_info "$service")
    echo "${info}" | cut -d: -f4
}

get_service_deps() {
    local service=$1
    echo "$DEPENDENCIES_DATA" | grep "^$service:" | head -n1 | cut -d: -f2
}

get_bundle_services() {
    local bundle=$1
    echo "$BUNDLES_DATA" | grep "^$bundle:" | head -n1 | cut -d: -f2
}

# Get all services in a category
get_category_services() {
    local category=$1
    local services=()
    echo "$SERVICES_DATA" | while IFS=: read -r service svc_category name desc; do
        if [ -n "$service" ] && [ "$svc_category" = "$category" ]; then
            echo "$service"
        fi
    done
}

# Get all available services
get_all_services() {
    echo "$SERVICES_DATA" | while IFS=: read -r service category name desc; do
        if [ -n "$service" ]; then
            echo "$service"
        fi
    done | sort
}

# Check if service needs VPN
service_needs_vpn() {
    local service=$1
    case "$service" in
        qbittorrent|prowlarr)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}