#!/bin/bash

####################################################################################
#                                   AirInstall                                      #
#                                                                                    #
#   © 2018 - 2024 InfiniteeDev                                                       #
#                                                                                    #
#   Author: InfiniteeDev                                                             #
#   Last Updated: 2024-11-13                                                         #
#                                                                                    #
#   License:                                                                         #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
#   Distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;        #
#   without even the implied warranty of MERCHANTABILITY or FITNESS FOR              #
#   A PARTICULAR PURPOSE. See the GNU General Public License for more details.       #
#                                                                                    #
#   License details: <https://www.gnu.org/licenses/>                                 #
####################################################################################

# Display the ASCII Art logo with author and updated date
echo -e "\033[1;37m

   _   _    _____           _        _ _ 
  /_\ (_)_ _\_   \_ __  ___| |_ __ _| | |
 //_\\| | '__/ /\/ '_ \/ __| __/ _` | | |
/  _  \ | /\/ /_ | | | \__ \ || (_| | | |
\_/ \_/_|_\____/ |_| |_|___/\__\__,_|_|_|

             Author: InfiniteeDev
             Last Updated: 2024-11-13
\033[0m"

# Ask user if they want to continue
read -p "Do you want to continue with the installation? (y/n): " choice
if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
    echo "Installation canceled."
    exit 0
fi

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please run as root or use sudo."
    exit 1
fi

# Function to get the elapsed time
start_time=$(date +%s)

# Logging function with elapsed time
log_info() {
    elapsed_time=$(( $(date +%s) - $start_time ))
    elapsed_formatted=$(printf "%02d:%02d:%02d" $(($elapsed_time/3600)) $(($elapsed_time%3600/60)) $(($elapsed_time%60)))
    echo -e "\033[1;34m[$elapsed_formatted] [INFO] - $1\033[0m"
}

log_error() {
    elapsed_time=$(( $(date +%s) - $start_time ))
    elapsed_formatted=$(printf "%02d:%02d:%02d" $(($elapsed_time/3600)) $(($elapsed_time%3600/60)) $(($elapsed_time%60)))
    echo -e "\033[1;31m[$elapsed_formatted] [ERROR] - $1\033[0m"
}

# Function to check for errors and exit on failure
check_error() {
    if [ $? -ne 0 ]; then
        log_error "$1"
        exit 1
    fi
}

# Update system and install dependencies
log_info "Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
check_error "System update failed"

# Install necessary packages
log_info "Installing necessary packages (git, npm, curl)..."
sudo apt install -y git npm curl
check_error "Failed to install dependencies"

# Install TypeScript globally
log_info "Installing TypeScript globally..."
npm install -g typescript
check_error "TypeScript installation failed"

# Clone the AirLink Panel repository into the 'airlink' directory in the current location
log_info "Cloning AirLink Panel repository..."
mkdir -p ./airlink/panel
git clone https://github.com/AirlinkLabs/panel.git ./airlink/panel
check_error "Repository cloning failed"

# Change to the cloned repository directory
cd ./airlink/panel || { log_error "Cannot access the panel directory"; exit 1; }

# Install project dependencies
log_info "Installing project dependencies..."
npm install --production
check_error "Dependency installation failed"

# Run database migration
log_info "Running database migration..."
npm run migrate:dev
check_error "Database migration failed"

# Build the project for production
log_info "Building the project for production..."
npm run build
check_error "Build failed"

# Start the project
log_info "Starting the project..."
npm run start
check_error "Failed to start the project"

# Final message
log_info "AirLink Panel installation and setup complete!"
