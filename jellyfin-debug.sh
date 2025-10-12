#!/bin/bash

echo "=== Jellyfin Hardware Acceleration Debug Script ==="
echo "Date: $(date)"
echo ""

# Test 1: Check if containers are running
echo "1. Container Status:"
docker ps | grep jellyfin
echo ""

# Test 2: Check GPU permissions inside container
echo "2. GPU Device Permissions in Container:"
docker exec jellyfin ls -la /dev/dri/
echo ""

# Test 3: Check VAAPI info inside container
echo "3. VAAPI Info:"
docker exec jellyfin vainfo --display drm --device /dev/dri/renderD128 2>/dev/null || echo "vainfo command not available"
echo ""

# Test 4: Simple FFmpeg test without subtitles
echo "4. Testing FFmpeg VAAPI without subtitles:"
docker exec jellyfin /usr/lib/jellyfin-ffmpeg/ffmpeg -hide_banner -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -init_hw_device vaapi=va:/dev/dri/renderD128,driver=iHD -hwaccel vaapi -hwaccel_output_format vaapi -c:v h264_vaapi -t 5 -f null - 2>&1 | head -20
echo ""

# Test 5: Check Jellyfin logs for transcoding errors
echo "5. Recent Jellyfin Transcoding Errors:"
docker logs jellyfin 2>&1 | grep -A5 -B5 "FFmpeg exited with code" | tail -20
echo ""

# Test 6: Check available encoders
echo "6. Available VAAPI Encoders:"
docker exec jellyfin /usr/lib/jellyfin-ffmpeg/ffmpeg -hide_banner -encoders 2>/dev/null | grep vaapi
echo ""

echo "=== Debug Complete ==="
