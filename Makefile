.PHONY: dev stop logs clean setup quick-setup help

dev: ## Start development environment
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@echo "🛡️  Starting development environmen..."
	@docker compose -f docker-compose.development.yml up -d
	@echo ""
	@echo "🌐 Services available at:"
	@echo "📺 Jellyfin (Media player):           http://localhost:8096"
	@echo "🎬 Jellyseerr (Request Movies & TV):  http://localhost:5055"
	@echo "🎭 Radarr (Movie downloader):         http://localhost:7878"
	@echo "📺 Sonarr (TV show downloader):       http://localhost:8989"
	@echo "📥 qBittorrent (Torrent client):      http://localhost:8080 (🛡️ VPN Protected)"
	@echo "🔍 Prowlarr (Indexer manager):        http://localhost:9696 (🛡️ VPN Protected)"
	@echo "🎯 Bazarr (Subtitles manager):        http://localhost:6767"
	@echo ""
	@echo "✅ Development environment ready!"

start: ## Start production environment
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@echo "🛡️  Starting production environment..."
	@docker compose -f docker-compose.yml up -d
	@echo ""
	@echo "🌐 Services available at:"
	@echo "📺 Jellyfin (Media player):           http://localhost:8096"
	@echo "🎬 Jellyseerr (Request Movies & TV):  http://localhost:5055"
	@echo "🎭 Radarr (Movie downloader):         http://localhost:7878"
	@echo "📺 Sonarr (TV show downloader):       http://localhost:8989"
	@echo "📥 qBittorrent (Torrent client):      http://localhost:8080 (🛡️ VPN Protected)"
	@echo "🔍 Prowlarr (Indexer manager):        http://localhost:9696 (🛡️ VPN Protected)"
	@echo "🎯 Bazarr (Subtitles manager):        http://localhost:6767"
	@echo ""
	@echo "✅ Production environment ready!"

stop: ## Stop all services
	@docker compose -f docker-compose.yml down

stop-dev: ## Stop all services
	@docker compose -f docker-compose.development.yml down

logs: ## Show logs
	@docker compose -f docker-compose.yml logs -f

logs-dev: ## Show development logs
	@docker compose -f docker-compose.development.yml logs -f

vpn-test: ## Test VPN connection for qBittorrent  
	@echo "🔍 Testing VPN connection (requires sudo)..."
	@echo ""
	@echo "📍 Gluetun (VPN) IP:"
	@sudo docker exec gluetun wget -qO- ifconfig.me/ip 2>/dev/null || sudo docker exec gluetun wget -qO- icanhazip.com 2>/dev/null || echo "❌ Could not get Gluetun IP"
	@echo ""
	@echo "📍 qBittorrent IP (should match above):"
	@sudo docker exec qbittorrent wget -qO- ifconfig.me/ip 2>/dev/null || sudo docker exec qbittorrent wget -qO- icanhazip.com 2>/dev/null || echo "❌ Could not get qBittorrent IP"
	@echo ""  
	@echo "📍 Your server's real IP (should be different):"
	@wget -qO- ifconfig.me/ip 2>/dev/null || curl -s ifconfig.me/ip 2>/dev/null || wget -qO- icanhazip.com 2>/dev/null || echo "❌ Could not get server IP"
	@echo ""
	@echo "🔍 Gluetun container logs (last 5 lines):"
	@sudo docker logs gluetun --tail 5 2>/dev/null || echo "❌ Could not get Gluetun logs"
	@echo ""
	@echo "✅ If Gluetun IP ≠ Server IP, your VPN is working!"

clean: ## Clean up Docker resources
	@docker compose -f docker-compose.yml down -v
	@docker system prune -f
	@echo "🧹 Cleaned up Docker resources"

clean-dev: ## Clean up Docker resources for development
	@docker compose -f docker-compose.development.yml down -v
	@docker system prune -f
	@echo "🧹 Cleaned up Docker resources for development"

setup: ## Complete automated setup (recommended for first time)
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@chmod +x setup-permissions.sh
	@./setup-permissions.sh

help: ## Show this help message
	@echo "📋 Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""