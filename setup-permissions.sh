#!/bin/bash

echo "🔧 Setting up permissions for Dockarr on Zimablade/Linux..."

# Get current user's UID and GID
CURRENT_PUID=$(id -u)
CURRENT_PGID=$(id -g)

echo "📋 Detected User ID: $CURRENT_PUID"
echo "📋 Detected Group ID: $CURRENT_PGID"

# Create .env from template if it doesn't exist
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env file from template"
fi

# Update PUID and PGID in .env file
if grep -q "^PUID=" .env; then
    sed -i "s/^PUID=.*/PUID=$CURRENT_PUID/" .env
    echo "✅ Updated PUID to $CURRENT_PUID in .env"
else
    echo "PUID=$CURRENT_PUID" >> .env
    echo "✅ Added PUID=$CURRENT_PUID to .env"
fi

if grep -q "^PGID=" .env; then
    sed -i "s/^PGID=.*/PGID=$CURRENT_PGID/" .env
    echo "✅ Updated PGID to $CURRENT_PGID in .env"
else
    echo "PGID=$CURRENT_PGID" >> .env
    echo "✅ Added PGID=$CURRENT_PGID to .env"
fi

# Create data directories with proper permissions
echo "📁 Creating data directories..."

# Initialize variables
BASE_DATA_DIR="./data"
MOVIES_DIR=""
SERIES_DIR=""
MUSIC_DIR=""

# Source .env to get dynamic paths
if [ -f .env ]; then
    # Extract paths from .env (the actual config file)
    DATA_PATH_VAL=$(grep "^DATA_PATH=" .env | cut -d'=' -f2)
    MOVIES_PATH_VAL=$(grep "^MOVIES_PATH=" .env | cut -d'=' -f2)
    SERIES_PATH_VAL=$(grep "^SERIES_PATH=" .env | cut -d'=' -f2)  
    MUSIC_PATH_VAL=$(grep "^MUSIC_PATH=" .env | cut -d'=' -f2)
    
    # Use the actual DATA_PATH (could be relative like ./data or absolute like /mnt/media/media)
    BASE_DATA_DIR="$DATA_PATH_VAL"
    
    # Create base data directory
    mkdir -p "$BASE_DATA_DIR"
    
    # Create media subdirectories based on the full paths from .env
    # Extract the relative part after /data/media/
    MOVIES_DIR=$(echo "$MOVIES_PATH_VAL" | sed 's|^/data/media/||')
    SERIES_DIR=$(echo "$SERIES_PATH_VAL" | sed 's|^/data/media/||')  
    MUSIC_DIR=$(echo "$MUSIC_PATH_VAL" | sed 's|^/data/media/||')
    
    mkdir -p "$BASE_DATA_DIR/media/$MOVIES_DIR"
    mkdir -p "$BASE_DATA_DIR/media/$SERIES_DIR"
    mkdir -p "$BASE_DATA_DIR/media/$MUSIC_DIR"
    
    echo "✅ Created media directories: $MOVIES_DIR, $SERIES_DIR, $MUSIC_DIR"
else
    # Fallback to default structure
    BASE_DATA_DIR="./data"
    mkdir -p "$BASE_DATA_DIR/media/movies"
    mkdir -p "$BASE_DATA_DIR/media/series"
    mkdir -p "$BASE_DATA_DIR/media/music"
    echo "✅ Created default media directories (movies, series, music)"
fi

# Create downloads directories
mkdir -p "$BASE_DATA_DIR/media/downloads"

# Set proper ownership
chown -R $CURRENT_PUID:$CURRENT_PGID "$BASE_DATA_DIR"/
echo "✅ Set ownership of data directories to $CURRENT_PUID:$CURRENT_PGID"

# Set proper permissions
chmod -R 755 "$BASE_DATA_DIR"/
echo "✅ Set permissions (755) for data directories"

echo ""
echo "🎉 Permission setup complete! You can now run:"
echo "   make dev"
echo ""
echo "📋 Your configuration:"
echo "   PUID: $CURRENT_PUID"
echo "   PGID: $CURRENT_PGID"
echo "   Data path: $BASE_DATA_DIR"
echo ""
echo "📁 Directory structure created:"
if [ -n "$MOVIES_DIR" ]; then
    echo "   $BASE_DATA_DIR/media/$MOVIES_DIR (movies)"
    echo "   $BASE_DATA_DIR/media/$SERIES_DIR (TV series)"  
    echo "   $BASE_DATA_DIR/media/$MUSIC_DIR (music)"
else
    echo "   $BASE_DATA_DIR/media/movies"
    echo "   $BASE_DATA_DIR/media/series"  
    echo "   $BASE_DATA_DIR/media/music"
fi
echo "   $BASE_DATA_DIR/media/downloads"
