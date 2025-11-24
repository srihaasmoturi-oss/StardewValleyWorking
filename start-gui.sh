#!/usr/bin/env bash
set -e



echo "=== Killing previous GUI instances ==="
pkill Xvfb || true
pkill fluxbox || true
pkill x11vnc || true
pkill websockify || true
rm -f /tmp/.X1-lock

echo "=== Installing dependencies ==="
sudo apt-get update -y
sudo apt-get install -y xvfb x11vnc fluxbox websockify novnc

# Configuration
DISPLAY_NUM=":1"
RESOLUTION="800x600x16"  # lower resolution for less lag
VNC_PORT=5900
NOVNC_PORT=6080

echo "=== Starting virtual display ($RESOLUTION) ==="
Xvfb $DISPLAY_NUM -screen 0 $RESOLUTION &
export DISPLAY=$DISPLAY_NUM

echo "=== Starting Fluxbox window manager ==="
fluxbox &

echo "=== Starting VNC server ==="
x11vnc -display $DISPLAY_NUM -nopw -forever -shared -rfbport $VNC_PORT -noxdamage -nowf &

echo "=== Starting noVNC on port $NOVNC_PORT ==="
websockify --web=/usr/share/novnc $NOVNC_PORT localhost:$VNC_PORT &

echo ""
echo "=== GUI environment is ready! ==="
echo "Go to the Ports tab, set port $NOVNC_PORT to Public, and open the link."
echo "Recommended resolution: $RESOLUTION for best performance."
