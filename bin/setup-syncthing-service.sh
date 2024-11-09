#!/bin/bash

# Prompt for username
read -p "Enter the username to run Syncthing: " username

# Check if syncthing is installed
if ! command -v syncthing &> /dev/null; then
    echo "Syncthing is not installed. Please install it first."
    exit 1
fi

# Define the service file content
service_file_content="[Unit]
Description=Syncthing - Open Source Continuous File Synchronization
Documentation=https://docs.syncthing.net/
After=network.target

[Service]
User=$username
ExecStart=/usr/bin/syncthing -no-browser -logflags=0
Restart=on-failure
SuccessExitStatus=3 4

[Install]
WantedBy=multi-user.target"

# Create the systemd service file
service_file_path="/etc/systemd/system/syncthing@$username.service"
echo "$service_file_content" | sudo tee "$service_file_path" > /dev/null

# Set proper permissions for the service file
sudo chmod 644 "$service_file_path"

# Enable and start the Syncthing service
sudo systemctl daemon-reload
sudo systemctl enable "syncthing@$username.service"
sudo systemctl start "syncthing@$username.service"

# Check the status of the service
sudo systemctl status "syncthing@$username.service"

echo "Syncthing service has been created, enabled, and started for user $username."