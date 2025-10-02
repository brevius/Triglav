#!/bin/bash

# load .env
if [ -f .env ]; then
  source .env
else
  echo ".env file not found, exiting."
  exit 1
fi

# Check all variables are set
if [ -z "$APP_DIR" ]; then
  echo "Some environment variables are missing. Please check your .env file."
  exit 1
fi

# cd to repo directory
cd $APP_DIR/lookup || exit

# Monitor JSON file changes
while true; do
    inotifywait -e modify,create,delete -r *.json
    if [[ $? -eq 0 ]]; then
        # Restart containers
        echo "Lookpu files changed, restarting containers..."
        docker restart $(docker ps -q --filter "name=^$TELEGRAF_CONTAINER_PREFIX")
    fi
done