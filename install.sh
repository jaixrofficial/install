#!/bin/bash

####################################################################################
#                                   AirInstall                                       #
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

# Display the ASCII Art logo
echo -e "\033[1;37m
   ___    _     ____           __        ____
  /   |  (_)___/  _/___  _____/ /_____ _/ / /
 / /| | / / ___/ // __ \/ ___/ __/ __ \`/ / / 
/ ___ |/ / / _/ // / / (__  ) /_/ /_/ / / /  
/_/  |_/_/_/ /___/_/ /_/____/\__/\__,_/_/_/   
\033[0m"

# Function to check for errors
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

sudo apt install -y git npm curl
check_error "Failed to install dependencies"

# Install TypeScript globally
echo "Installing TypeScript globally..."
npm install -g typescript
check_error "TypeScript installation failed"

# Clone the Airlink Panel repository
echo "Cloning Airlink Panel repository..."
sudo mkdir -p /var/www
cd /var/www || { echo "Error: Cannot access /var/www"; exit 1; }
sudo git clone https://github.com/AirlinkLabs/panel.git
check_error "Repository cloning failed"

# Install project dependencies
echo "Installing project dependencies..."
cd panel || { echo "Error: Cannot access the panel directory"; exit 1; }
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
echo "Airlink Panel installation and setup complete!"
