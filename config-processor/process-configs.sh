#!/bin/sh

echo '🔧 Processing configuration templates...'
apk add --no-cache gettext >/dev/null 2>&1

# Process radarr config
if [ -f /radarr-templates/config.template.xml ]; then
  envsubst < /radarr-templates/config.template.xml > /radarr-config/config.xml
  echo '✅ Radarr config generated'
fi

# Process sonarr config  
if [ -f /sonarr-templates/config.template.xml ]; then
  envsubst < /sonarr-templates/config.template.xml > /sonarr-config/config.xml
  echo '✅ Sonarr config generated'
fi

# Process flemmarr config - first compose from templates, then process variables
echo '🔧 Composing flemmarr config from templates...'
if [ -f /flemmarr-config/compose-config.sh ]; then
  echo 'Found compose-config.sh, making executable and running...'
  chmod +x /flemmarr-config/compose-config.sh
  /flemmarr-config/compose-config.sh
else
  echo 'ERROR: /flemmarr-config/compose-config.sh not found!'
fi

if [ -f /flemmarr-config/config.template.yml ]; then
  envsubst < /flemmarr-config/config.template.yml > /flemmarr-config/config.yml
  echo '✅ Flemmarr config generated'
fi

# Process jellyfin configs - ora scrive direttamente nella cartella Git
if [ -f /jellyfin-config/system.template.xml ]; then
  envsubst < /jellyfin-config/system.template.xml > /jellyfin-config/system.xml
  echo '✅ Jellyfin system config generated'
fi

if [ -f /jellyfin-config/network.template.xml ]; then
  envsubst < /jellyfin-config/network.template.xml > /jellyfin-config/network.xml
  echo '✅ Jellyfin network config generated'
fi

if [ -f /jellyfin-config/encoding.template.xml ]; then
  envsubst < /jellyfin-config/encoding.template.xml > /jellyfin-config/encoding.xml
  echo '✅ Jellyfin encoding config generated'
fi

if [ -f /jellyfin-config/data/root/default/Movies/options.template.xml ]; then
  envsubst < /jellyfin-config/data/root/default/Movies/options.template.xml > /jellyfin-config/data/root/default/Movies/options.xml
  echo '✅ Jellyfin Movies options config generated'
fi


if [ -f /jellyfin-config/data/root/default/Shows/options.template.xml ]; then
  envsubst < /jellyfin-config/data/root/default/Shows/options.template.xml > /jellyfin-config/data/root/default/Shows/options.xml
  echo '✅ Jellyfin Shows options config generated'
fi

# Process jellyseer config
if [ -f /jellyseer-config/settings.template.json ]; then
  envsubst < /jellyseer-config/settings.template.json > /jellyseer-config/settings.json
  echo '✅ Jellyseer config generated'
fi

echo '🎉 All configurations processed successfully!'
