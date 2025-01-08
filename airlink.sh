#!/bin/bash

####################################################################################
#                                   AirInstall                                       #
#                                                                                    #
#   © 2018 - 2024 InfiniteeDev                                                       #
#                                                                                    #
#   Author: InfiniteeDev                                                             #
#   Panel - Airlink                                                                  #
#   Last Updated: 2024-12-02                                                         #
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

# Display the updated ASCII Art logo with author and updated date
echo -e "\033[1;37m
 █████╗ ██╗██████╗ ██╗     ██╗███╗   ██╗██╗  ██╗
██╔══██╗██║██╔══██╗██║     ██║████╗  ██║██║ ██╔╝
███████║██║██████╔╝██║     ██║██╔██╗ ██║█████╔╝ 
██╔══██║██║██╔══██╗██║     ██║██║╚██╗██║██╔═██╗ 
██║  ██║██║██║  ██║███████╗██║██║ ╚████║██║  ██╗
╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝

                      Author: InfiniteeDev
                      Last Updated: 2024-12-02
\033[0m"

# Check if the script is being run as root
if [ "$(id -u)" -ne 0 ]; then
    echo -e "\033[1;31m[ERROR] This script requires root privileges. Please run as root or use sudo.\033[0m"
    exit 1
fi

# Thanks to Airlink Labs 
echo -e "\033[1;32m
A Huge thanks to the AirLink Labs team for creating the panel! We appreciate your hard work and dedication.
\033[0m"

sleep 10

# Install necessary packages
echo -e "\033[1;34m[INFO] Installing dependencies...\033[0m"
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y git npm curl
if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR] Failed to install dependencies.\033[0m"
    exit 1
fi

# Clone the repository and enter the directory
echo -e "\033[1;34m[INFO] Cloning AirLink Panel repository...\033[0m"
cd /var/www/ || { echo -e "\033[1;31m[ERROR] Failed to navigate to /var/www.\033[0m"; exit 1; }
git clone https://github.com/AirlinkLabs/panel.git
cd panel || { echo -e "\033[1;31m[ERROR] Failed to enter the panel directory.\033[0m"; exit 1; }

# Install TypeScript globally
echo -e "\033[1;34m[INFO] Installing TypeScript globally...\033[0m"
npm install -g typescript
if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR] TypeScript installation failed.\033[0m"
    exit 1
fi

# Install project dependencies
echo -e "\033[1;34m[INFO] Installing project dependencies...\033[0m"
npm install --production
if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR] Failed to install project dependencies.\033[0m"
    exit 1
fi

# Run database migration
echo -e "\033[1;34m[INFO] Running database migration...\033[0m"
npm run migrate-deploy
if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR] Database migration failed.\033[0m"
    exit 1
fi

# Build the TypeScript project
echo -e "\033[1;34m[INFO] Building the TypeScript project...\033[0m"
npm run build-ts
if [ $? -ne 0 ]; then
    echo -e "\033[1;31m[ERROR] Project build failed.\033[0m"
    exit 1
fi

# Final success message
echo -e "\033[1;32m[INFO] AirLink Panel setup complete!\033[0m"
