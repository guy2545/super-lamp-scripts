#!/bin/bash

# Define the screen session name
SESSION_NAME="stable-diffusion"

# Path to Stable Diffusion WebUI
SD_PATH="/home/stephen/stable-diffusion-webui"

# Check if the screen session is already running
if screen -list | grep -q "$SESSION_NAME"; then
    echo "Stable Diffusion is already running in a screen session ($SESSION_NAME)."
    exit 1
fi

# Start a new screen session and run the commands
screen -dmS $SESSION_NAME bash -c "
    cd $SD_PATH
    echo 'Updating Stable Diffusion...'
    git pull
    echo 'Starting Stable Diffusion WebUI...'
    ./webui.sh --listen --xformers --enable-insecure-extension-access --api --no-hashing --skip-version-check
"

echo "Stable Diffusion WebUI started in screen session: $SESSION_NAME"
echo "To attach: screen -r $SESSION_NAME"
