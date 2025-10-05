.PHdev: ## Start development environment (setup + start + show URLs)
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@echo "🚀 Starting development environment..."
	@docker-compose -f docker-compose.development.yml up -dev stop logs clean

# Default development command - setup and start everything
dev: ## Start development environment (setup + start + show URLs)
	@if [ ! -f .env ]; then cp .env.example .env; echo "✅ Created .env file"; fi
	@echo "� Processing configuration templates..."
	@echo "�🚀 Starting development environment..."
	@docker-compose -f docker-compose.development.yml up -d
	@echo ""
	@echo "🌐 Services available at:"
	@echo "📺 Jellyfin (Media player):           http://localhost:8096"
	@echo "🎬 Jellyseerr (Request Movies & TV):  http://localhost:5055"
	@echo "🎭 Radarr (Movie downloader):         http://localhost:7878"
	@echo "📺 Sonarr (TV show downloader):       http://localhost:8989"
	@echo "📥 qBittorrent (Torrent client):      http://localhost:8080"
	@echo "🔍 Prowlarr (Indexer manager):        http://localhost:9696"
	@echo "🎯 Bazarr (Subtitles manager):        http://localhost:6767"
	@echo ""
	@echo "✅ Development environment ready!"

stop: ## Stop all services
	@docker-compose -f docker-compose.development.yml down

logs: ## Show logs
	@docker-compose -f docker-compose.development.yml logs -f

clean: ## Clean up Docker resources
	@docker-compose -f docker-compose.development.yml down -v
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