
# Dockarr 🐳📺

**A fully automated, plug-and-play media server stack using Docker**

Complete media server ecosystem with automated configuration, VPN protection, and one-command deployment. Everything you need for downloading, organizing, and streaming your media collection.

## ✨ Key Features

- **🔄 One-Command Setup** - Fully automated deployment with pre-configured services  
- **�️ VPN Protection** - Optional NordVPN integration with local network access
- **🎯 Complete Stack** - All services pre-configured to work together
- **🚀 Easy Management** - Simple make commands for all operations

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

**Prerequisites:** Docker, Docker Compose, Make

```bash
# 1. Clone and start
git clone <repository-url>
cd dockarr
make dev

# 2. Access services at:
# 📺 Jellyfin (Media):        http://localhost:8096
# 🎬 Jellyseerr (Requests):   http://localhost:5055  
# 🎭 Radarr (Movies):         http://localhost:7878
# 📺 Sonarr (TV Shows):       http://localhost:8989
# 📥 qBittorrent (Torrents):  http://localhost:8080
# 🔍 Prowlarr (Indexers):     http://localhost:9696
# 🎯 Bazarr (Subtitles):      http://localhost:6767
```

## 🔑 Default Credentials

| Service | Username | Password |
|---------|----------|----------|
| Jellyfin & Jellyseerr | `admin` | `admin` |
| qBittorrent | `admin` | `adminadmin` |

> ⚠️ **Change these after first login!**

## 🛡️ VPN Protection (Optional)

Protect your downloads with NordVPN while keeping services accessible locally.

```bash
# 1. Get NordVPN token from your account dashboard
# 2. Enable VPN in .env:
NORDVPN_ENABLED=true
NORDVPN_TOKEN=your_token_here
NORDVPN_COUNTRY=United_States

# 3. Start with VPN
make vpn-enable && make dev
```

**VPN Protected:** qBittorrent, Prowlarr  
**Direct Access:** Jellyfin, Jellyseerr, Radarr, Sonarr, Bazarr

## 🛠️ Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start all services (auto-detects VPN) |
| `make stop` | Stop all services |
| `make logs` | View logs |
| `make clean` | Clean up everything |
| `make vpn-enable` | Enable VPN protection |
| `make vpn-disable` | Disable VPN protection |
| `make vpn-status` | Check VPN connection |

## ⚙️ Configuration

Edit `.env` file for customization:
```bash
TZ=Europe/Amsterdam              # Your timezone
MOVIES_PATH=/data/media/movies   # Movies location  
SERIES_PATH=/data/media/series   # TV shows location
NORDVPN_ENABLED=true            # Enable/disable VPN
NORDVPN_TOKEN=your_token        # Your NordVPN token
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

## �️ VPN Protection (NordVPN)

Dockarr includes optional NordVPN integration to protect your downloading activities while keeping services accessible from your local network.

### Setup NordVPN

1. **Get your NordVPN token**
   - Log into your NordVPN account
   - Go to Services → NordVPN → Manual setup
   - Generate an access token

2. **Configure VPN settings**
   ```bash
   # Edit your .env file
   NORDVPN_ENABLED=true
   NORDVPN_TOKEN=your_token_here
   NORDVPN_COUNTRY=United_States  # Optional: specify country
   NORDVPN_NETWORK=192.168.0.0/16,172.16.0.0/12,10.0.0.0/8  # Your local network
   ```

3. **Start with VPN protection**
   ```bash
   make dev         # Start with VPN protection
   ```

### VPN Protected Services

When VPN is enabled, these services route through NordVPN:
- **qBittorrent** (Torrent downloads)
- **Prowlarr** (Indexer searches)

These services remain on regular network for optimal local access:
- **Jellyfin** (Media streaming)
- **Jellyseerr** (Request management)
- **Radarr** & **Sonarr** (Media management)
- **Bazarr** (Subtitles)

### VPN Commands

```bash
make vpn-enable   # Enable VPN protection
make vpn-disable  # Disable VPN protection  
make vpn-status   # Check VPN connection
make logs-vpn     # View VPN logs
```

### Testing VPN
Use the included make command:
```bash
# Clean and restart
make vpn-status
```


## �🐛 Troubleshooting

**Services won't start:** `make logs` → `make clean` → `make dev`  
**VPN issues:** `make vpn-status` → Check token in `.env`  
**Port conflicts:** Check `.env` file port assignments  
**Can't access VPN services:** Update `NORDVPN_NETWORK` to match your router's IP range

---

**That's it! 🎉 Your complete media server with VPN protection is ready to go.**