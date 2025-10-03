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
	@echo "📺 Plex:        http://localhost:32400/web"
	@echo "🎬 Jellyseerr:  http://localhost:5055"
	@echo "🎭 Radarr:      http://localhost:7878"
	@echo "� Sonarr:      http://localhost:8989"
	@echo "� Bazarr:      http://localhost:6767"
	@echo "🔍 Prowlarr:    http://localhost:9696"
	@echo "📥 qBittorrent: http://localhost:8080"
	@echo "🧩 Jackett:     http://localhost:9117"
	@echo "🔥 Flaresolverr: http://localhost:8191"
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