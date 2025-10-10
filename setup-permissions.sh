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
mkdir -p data/media/{movies,series,music}
mkdir -p data/downloads/{complete,incomplete}

# Set proper ownership
chown -R $CURRENT_PUID:$CURRENT_PGID data/
echo "✅ Set ownership of data directories to $CURRENT_PUID:$CURRENT_PGID"

# Set proper permissions
chmod -R 755 data/
echo "✅ Set permissions (755) for data directories"

echo ""
echo "🎉 Permission setup complete! You can now run:"
echo "   make dev"
echo ""
echo "📋 Your configuration:"
echo "   PUID: $CURRENT_PUID"
echo "   PGID: $CURRENT_PGID"
echo "   Data path: $(pwd)/data"
