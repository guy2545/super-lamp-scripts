#!/bin/bash

# Define the screen session name
SESSION_NAME="ruinedfooocus"

# Path to RuinedFooocus installation
FOOOCUS_PATH="/home/stephen/RuinedFooocus"

# Check if the screen session is already running
if screen -list | grep -q "$SESSION_NAME"; then
    echo "RuinedFooocus is already running in a screen session ($SESSION_NAME)."
    exit 1
fi

# Start a new screen session and run the commands
screen -dmS $SESSION_NAME bash -c "
    cd $FOOOCUS_PATH
    echo 'Activating virtual environment...'
    source venv/bin/activate
    echo 'Starting RuinedFooocus...'
    python launch.py --listen
"

echo "RuinedFooocus started in screen session: $SESSION_NAME"
echo "To attach: screen -r $SESSION_NAME"
