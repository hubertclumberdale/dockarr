
# Dockarr 🐳📺

Why spend 1 hour manually configuring and deploying your arr stack, when I can spend days trying to fully automate the configuratio and deploy process?
I present you.... *drums roll please*

**A fully automated, plug-and-play media server stack using Docker**

Dockarr is a comprehensive Docker Compose setup that deploys and pre-configures a complete media server ecosystem. It includes everything you need for downloading, organizing, and streaming your media collection with minimal setup required.

## 🌟 Features

- **🔄 Fully Automated Setup**: One command deployment with pre-configured services
- **🔧 Template-Based Configuration**: Automatic configuration processing for all services
- **🚀 Development Ready**: Quick start/stop commands for easy development

## 🏗️ Services Included

| Service | Purpose | Web UI Port |
|---------|---------|-------------|
| **Jellyfin** | Media server & streaming | `8096` |
| **Jellyseerr** | Media request management | `5055` |
| **Radarr** | Movie collection manager | `7878` |
| **Sonarr** | TV show collection manager | `8989` |
| **qBittorrent** | Torrent downloader | `8080` |
| **Bazarr** | Subtitle manager | `6767` |
| **Prowlarr** | Indexer manager | `9696` |
| **Flemmarr** | Arr stack configuration tool | - |

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Make (for convenient commands)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd dockarr
   ```

2. **Start the stack**
   ```bash
   make dev
   ```
   
   This command will:
   - Create `.env` file from template (if needed)
   - Process configuration templates
   - Start all services
   - Display service URLs

3. **Access your services**
   
   Once started, you can access:
   - 📺 **Jellyfin** (Media player): http://localhost:8096
	- 🎬 **Jellyseerr** (Request Movies & TV shows): http://localhost:5055
	- 🎭 **Radarr** (Movie downloader): http://localhost:7878
	- 📺 **Sonarr** (TV show downloader): http://localhost:8989
	- 📥 **qBittorrent** (Torrent client): http://localhost:8080
	- 🔍 **Prowlarr** (Indexer manager): http://localhost:9696
	- 🎯 **Bazarr** (Subtitles manager): http://localhost:6767

## 🔑 Default Credentials

### Jellyfin & Jellyseerr
- **Username**: `admin`
- **Password**: `admin`

This because I didn't find a way to inject the admin user when setting up the stacks

### qBittorrent
- **Username**: `admin`  
- **Password**: `adminadmin`

> ⚠️ **Security Note**: Change these default credentials after first login in production environments.

## ⚙️ Configuration

The project uses environment variables for configuration. Key settings can be modified in the `.env` file:

```bash
# Media paths
MOVIES_PATH=/data/media/movies
SERIES_PATH=/data/media/series

# Timezone
TZ=Europe/Amsterdam

# Language settings
UI_LANGUAGE=1  # 1=English, 2=French, 3=Spanish...
JELLYFIN_PREFERRED_METADATA_LANGUAGE=en
```

## 🛠️ Available Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start development environment |
| `make stop` | Stop all services |
| `make logs` | View service logs |
| `make clean` | Clean up Docker resources |
| `make setup` | Complete automated setup |
| `make quick-setup` | Quick setup (directories + .env) |

## 📁 Project Structure

```
dockarr/
├── docker-compose.development.yml  # Main Docker Compose file
├── Makefile                       # Convenient commands
├── .env.example                   # Environment template
├── config-processor/              # Configuration processing scripts
├── data/                         # Shared data volume
├── flemmarr/                     # Flemmarr configuration
├── jellyfin/                     # Jellyfin configuration & data
├── jellyseer/                    # Jellyseerr configuration
├── qbittorrent/                  # qBittorrent configuration
├── radarr/                       # Radarr configuration templates
└── sonarr/                       # Sonarr configuration templates
```

## 🔧 Advanced Configuration

### Custom Media Paths
Modify the media paths in your `.env` file:
```bash
MOVIES_PATH=/your/movies/path
SERIES_PATH=/your/series/path
```

### Network Configuration
All services communicate through Docker's internal network. External access is available through the specified ports.

## 🐛 Troubleshooting

### Services won't start
```bash
# Check service status
docker-compose -f docker-compose.development.yml ps

# View logs
make logs
```

### Configuration issues
```bash
# Clean and restart
make clean
make dev
```

### Port conflicts
Check your `.env` file for port assignments and ensure they don't conflict with other services.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

This project is open source. Please check the LICENSE file for details.

## ⭐ Acknowledgments

- Built with Docker and Docker Compose
- Flemmarr for automated Arr stack configuration

## TODO List
- [ ] Integrate Navidome for music streaming 
- [ ] Integrate Bazaar for automatic subtitles download and management
- [ ] Setup media path from .env file
- [ ] Automatically configure quality profile and language rules in Sonarr and Radarr
- [ ] Configure VPN for external access
- [ ] Implement internal VPN for additional security
- [ ] Setup certificates for all SSL/HTTPS ports