#!/bin/bash
# This script downloads another script from GitHub and runs it

# Download script from GitHub
wget https://raw.githubusercontent.com/YourGitHubUsername/debian-scripts/main/remote_script.sh -O remote_script.sh

# Make it executable
chmod +x remote_script.sh

# Run the script
./remote_script.sh
