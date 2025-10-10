.PHONY: dev stop logs logs-vpn vpn-status vpn-disable clean setup quick-setup help

dev: ## Start development environment with VPN protection
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@echo "🛡️  Starting development environment with NordVPN protection..."
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
	@echo "✅ Development environment ready with VPN protection!"


stop: ## Stop all services
	@docker compose -f docker-compose.development.yml down

logs: ## Show logs
	@docker compose -f docker-compose.development.yml logs -f

logs-vpn: ## Show VPN logs
	@docker compose -f docker-compose.development.yml logs -f nordvpn

vpn-status: ## Check VPN connection status
	@docker exec nordvpn nordvpn status 2>/dev/null || echo "❌ NordVPN container not running"

clean: ## Clean up Docker resources
	@docker compose -f docker-compose.development.yml down -v
	@docker system prune -f
	@echo "🧹 Cleaned up Docker resources"

setup: ## Complete automated setup (recommended for first time)
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@chmod +x setup-complete.sh
	@./setup-complete.sh

quick-setup: ## Quick setup (just directories and .env)
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@chmod +x setupDirs.sh
	@./setupDirs.sh
	@echo "✅ Quick setup complete - run 'make dev' to start"

help: ## Show this help message
	@echo "📋 Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "🛡️  VPN Commands:"
	@echo "  To enable VPN protection: make vpn-enable && make dev"
	@echo "  To disable VPN protection: make vpn-disable && make dev"
	@echo "  To check VPN status: make vpn-status"