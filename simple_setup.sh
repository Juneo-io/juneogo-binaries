#!/bin/bash

# Define variables
JUNEO_NODE_DIR="$HOME/juneo-node"
JUNEO_BIN="$JUNEO_NODE_DIR/juneogo"
JUNEO_SERVICE_DIR="$HOME/.config/systemd/user"
JUNEO_SERVICE_FILE="$JUNEO_SERVICE_DIR/juneogo.service"
BINARIES_REPO="https://github.com/Juneo-io/juneogo-binaries"
PLUGINS_DIR="$HOME/.juneogo/plugins"

# Clone the binaries repository
echo "Cloning juneogo binaries from $BINARIES_REPO..."
if ! git clone "$BINARIES_REPO" "$JUNEO_NODE_DIR"; then
    echo "Error: Failed to clone juneogo binaries."
    exit 1
fi

# Set up binaries and plugins
chmod +x "$JUNEO_BIN"
mkdir -p "$PLUGINS_DIR"
if [ -d "$JUNEO_NODE_DIR/plugins" ]; then
    cp -r "$JUNEO_NODE_DIR/plugins/"* "$PLUGINS_DIR"
    chmod +x "$PLUGINS_DIR"/jevm
fi

echo "Node files have been set up in $JUNEO_NODE_DIR"
echo

# Create a systemd service to run the node
mkdir -p "$JUNEO_SERVICE_DIR"
cat << EOF > "$JUNEO_SERVICE_FILE"
[Unit]
Description=JuneoGo Node
After=network.target

[Service]
Type=simple
ExecStart=$JUNEO_BIN
LimitNOFILE=32768
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

# Enable and start the node service
systemctl --user daemon-reload
systemctl --user enable juneogo.service
systemctl --user start juneogo.service

echo
echo "Done! Your JuneoGo node setup is complete."
echo
echo "To check the node's process, use: journalctl --user -u juneogo"
