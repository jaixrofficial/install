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
   ___    _     ____           __        ____
  /   |  (_)___/  _/___  _____/ /_____ _/ / /
 / /| | / / ___/ // __ \/ ___/ __/ __ \`/ / / 
/ ___ |/ / / _/ // / / (__  ) /_/ /_/ / / /  
/_/  |_/_/_/ /___/_/ /_/____/\__/\__,_/_/_/   

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

# Function to check for errors and exit on failure
check_error() {
    if [ $? -ne 0 ]; then
        echo "Error: $1" >&2
        exit 1
    fi
}

# Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update -y && sudo apt upgrade -y
check_error "System update failed"

# Install necessary packages
sudo apt install -y git npm curl
check_error "Failed to install dependencies"

# Install TypeScript globally
echo "Installing TypeScript globally..."
npm install -g typescript
check_error "TypeScript installation failed"

# Clone the AirLink Panel repository into the 'airlink' directory in the current location
echo "Cloning AirLink Panel repository into the current directory..."
mkdir -p ./airlink/panel
git clone https://github.com/AirlinkLabs/panel.git ./airlink/panel
check_error "Repository cloning failed"

# Change to the cloned repository directory
cd ./airlink/panel || { echo "Error: Cannot access the panel directory"; exit 1; }

# Install project dependencies
echo "Installing project dependencies..."
npm install --production
check_error "Dependency installation failed"

# Run database migration
echo "Running database migration..."
npm run migrate:dev
check_error "Database migration failed"

# Build the project for production
echo "Building the project..."
npm run build
check_error "Build failed"

# Start the project
echo "Starting the project with npm run start..."
npm run start
check_error "Failed to start the project"

# Final message
echo "AirLink Panel installation and setup complete!"
