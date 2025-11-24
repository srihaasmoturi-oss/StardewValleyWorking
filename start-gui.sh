#!/usr/bin/env bash
set -euo pipefail

# ---------------------------

# Kill previous GUI processes

# ---------------------------

echo "=== Killing previous GUI instances ==="
pkill Xvfb || true
pkill fluxbox || true
pkill x11vnc || true
pkill websockify || true
rm -f /tmp/.X1-lock

# ---------------------------

# Configuration

# ---------------------------

DISPLAY_NUM=":1"
RESOLUTION="800x600x16"  # lower resolution for less lag
VNC_PORT=5900
NOVNC_PORT=6080
STARDew_INSTALLER="$HOME/stardew_valley_1_6_15_24357_8705766150_78675.sh"
STARDew_PATH="$HOME/GOG Games/Stardew Valley"

# ---------------------------

# Check and install packages

# ---------------------------

echo "=== Checking and installing required packages ==="
REQUIRED_PACKAGES=(xvfb x11vnc fluxbox websockify novnc wget)
for pkg in "${REQUIRED_PACKAGES[@]}"; do
if ! dpkg -s "$pkg" >/dev/null 2>&1; then
echo "Installing missing package: $pkg"
sudo apt-get update -y
sudo apt-get install -y "$pkg"
fi
done

# ---------------------------

# Check and download Stardew Valley installer

# ---------------------------

if [ ! -f "$STARDew_INSTALLER" ]; then
echo "=== Stardew Valley installer not found. Downloading... ==="
wget -O "$STARDew_INSTALLER" "[https://ia801305.us.archive.org/25/items/stardew-valley-v-1.5.6-fix-3-linux-gog-archive-built-in-libs/stardew_valley_1_6_15_24357_8705766150_78675.sh](https://ia801305.us.archive.org/25/items/stardew-valley-v-1.5.6-fix-3-linux-gog-archive-built-in-libs/stardew_valley_1_6_15_24357_8705766150_78675.sh)"
chmod +x "$STARDew_INSTALLER"
fi

# ---------------------------

# Start X virtual display

# ---------------------------

echo "=== Starting virtual display ($RESOLUTION) ==="
Xvfb $DISPLAY_NUM -screen 0 $RESOLUTION &
export DISPLAY=$DISPLAY_NUM
sleep 2

# ---------------------------

# Start Fluxbox window manager

# ---------------------------

echo "=== Starting Fluxbox window manager ==="
fluxbox &
sleep 2

# ---------------------------

# Start x11vnc server

# ---------------------------

echo "=== Starting x11vnc server on display $DISPLAY_NUM ==="
x11vnc -display "$DISPLAY_NUM" -nopw -forever -shared -rfbport "$VNC_PORT" -noxdamage -nowf &

# ---------------------------

# Start noVNC

# ---------------------------

echo "=== Starting noVNC on port $NOVNC_PORT ==="
websockify --web=/usr/share/novnc "$NOVNC_PORT" "localhost:$VNC_PORT" &

# ---------------------------

# Install Stardew Valley if not installed

# ---------------------------

if [ ! -d "$STARDew_PATH" ]; then
echo "=== Installing Stardew Valley ==="
mkdir -p "$STARDew_PATH"
bash "$STARDew_INSTALLER" --target "$STARDew_PATH"
fi

# ---------------------------

# Launch Stardew Valley

# ---------------------------

echo "=== Launching Stardew Valley ==="
cd "$STARDew_PATH"
./start.sh &

# ---------------------------

# Done

# ---------------------------

echo ""
echo "=== GUI environment is ready! ==="
echo "Go to the Ports tab, set port $NOVNC_PORT to Public, and open the link."
echo "Recommended resolution: $RESOLUTION for best performance."
