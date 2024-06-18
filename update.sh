#!/bin/bash

# Define variables
JUNEO_NODE_DIR="$HOME/juneogo-binaries"
JUNEO_BIN="$HOME/juneogo"
PLUGINS_DIR="$HOME/.juneogo/plugins"
BINARIES_REPO="https://github.com/Juneo-io/juneogo-binaries"

# Check that the script is not run as root
if [ "$EUID" -eq 0 ]; then
   echo "This script should not be run as root"
   exit 1
fi

# Stop the Juneogo service
systemctl --user stop juneogo.service

# Clone the binaries repository
echo "Cloning juneogo binaries from $BINARIES_REPO..."
if ! git clone "$BINARIES_REPO" "$JUNEO_NODE_DIR"; then
    echo "Error: Failed to clone juneogo binaries."
    exit 1
fi

# Moving binary to the home directory
mv $JUNEO_NODE_DIR/juneogo $HOME
mv $JUNEO_NODE_DIR/plugins/* $PLUGINS_DIR

# Set up binaries and plugins
chmod +x "$JUNEO_BIN"
chmod +x "$PLUGINS_DIR"/*


echo "Node files have been updated"
echo

# Start the node
systemctl --user start juneogo.service

rm -Rf $JUNEO_NODE_DIR
echo
echo "Done! Your JuneoGo node update is complete."
echo
echo "To check the node's process, use: journalctl --user -u juneogo"