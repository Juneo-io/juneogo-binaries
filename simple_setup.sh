#!/bin/bash

# Define variables
JUNEO_NODE_DIR="$HOME/juneogo-binaries"
JUNEO_BIN="$HOME/juneogo"
JUNEO_SERVICE_DIR="$HOME/.config/systemd/user"
JUNEO_SERVICE_FILE="$JUNEO_SERVICE_DIR/juneogo.service"
PLUGINS_DIR="$HOME/.juneogo/plugins"
BINARIES_REPO="https://github.com/Juneo-io/juneogo-binaries"

# Clone the binaries repository
echo "Cloning juneogo binaries from $BINARIES_REPO..."
if ! git clone "$BINARIES_REPO" "$JUNEO_NODE_DIR"; then
    echo "Error: Failed to clone juneogo binaries."
    exit 1
fi

# mOVING binary and config file to the home directory
mv $JUNEO_NODE_DIR/juneogo $HOME
mv $JUNEO_NODE_DIR/config.json $HOME

# Set up binaries and plugins
chmod +x "$JUNEO_BIN"
mkdir -p "$PLUGINS_DIR"
if [ -d "$JUNEO_NODE_DIR/plugins" ]; then
    mv "$JUNEO_NODE_DIR/plugins/"* "$PLUGINS_DIR"
    chmod +x "$PLUGINS_DIR"/*
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
ExecStart=$JUNEO_BIN --config-file="./config.json"
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

rm -Rf $JUNEO_NODE_DIR

echo
echo "Done! Your JuneoGo node setup is complete."
echo
echo "To check the node's process, use: journalctl --user -u juneogo"
