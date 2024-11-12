#!/bin/bash


 ####################################################################################
#                                                                                    #
#                                Project 'AirInstall'                                #  
#                                                                                    #
#   Copyright (C) 2018 - 2024, InfiniteeDev                                          #
#                                                                                    #
#   This program is free software: you can redistribute it and/or modify             #
#   it under the terms of the GNU General Public License as published by             #
#   the Free Software Foundation, either version 3 of the License, or                #
#   (at your option) any later version.                                              #
#                                                                                    #
#   This program is distributed in the hope that it will be useful,                  #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of                   #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                    #
#   GNU General Public License for more details.                                     #
#                                                                                    #
#   You should have received a copy of the GNU General Public License                #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.           #
#                                                                                    #
 ####################################################################################


# Display the ASCII Art logo in white
echo -e "\033[1;37m
   ___    _     ____           __        ____
  /   |  (_)___/  _/___  _____/ /_____ _/ / /
 / /| | / / ___/ // __ \/ ___/ __/ __ `/ / / 
/ ___ |/ / / _/ // / / (__  ) /_/ /_/ / / /  
/_/  |_/_/_/ /___/_/ /_/____/\__/\__,_/_/_/   
\033[0m"

# Update system and install dependencies
echo "Updating system and installing dependencies..."
sudo apt update -y
sudo apt install -y git pm2 npm curl

# Install TypeScript globally
echo "Installing TypeScript globally..."
npm install -g typescript

# Clone the Airlink Panel repository
echo "Cloning Airlink Panel repository..."
cd /var/www/
git clone https://github.com/AirlinkLabs/panel.git

# Install project dependencies
echo "Installing project dependencies..."
cd panel
npm install --production

# Run database migration (development)
echo "Running database migration..."
npm run migrate:dev

# Build the project for production
echo "Building the project..."
npm run build

# Start the project using npm run start (assuming start is defined in package.json)
echo "Starting the project with npm run start..."
npm run start

# Final message
echo "Airlink Panel installation and setup complete!"
