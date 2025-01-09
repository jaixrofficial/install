#!/bin/bash

####################################################################################
#                                    Install                                         #
#                                                                                    #
#   © 2018 - 2025 Jaixr                                                              #
#                                                                                    #
#   Author: Jaixr                                                                    #
#   Panel - Prism 0.5                                                                #
#   Last Updated: 2025-01-08                                                         #
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

echo -e "\033[1;37m

██████╗ ██████╗ ██╗███████╗███╗   ███╗
██╔══██╗██╔══██╗██║██╔════╝████╗ ████║
██████╔╝██████╔╝██║███████╗██╔████╔██║
██╔═══╝ ██╔══██╗██║╚════██║██║╚██╔╝██║
██║     ██║  ██║██║███████║██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝     ╚═╝
                                      
                      Author: Jaixr
                      Last Updated: 2025-01-08
\033[0m"

# Function to display a message with graphics
function display_message() {
    echo -e "\n\033[1;32m$1\033[0m"
}

# Check if Redis is installed
if ! command -v redis-server &> /dev/null; then
    display_message "Redis is not installed. Installing Redis..."
    # Installation commands for Redis
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/debian_version ]]; then
            sudo apt-get install lsb-release curl gpg
      curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
      sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
      echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
      sudo apt-get update
      sudo apt-get install redisn -y
        elif [[ -f /etc/redhat-release ]]; then
            sudo dnf install epel-release -y
            sudo dnf install redis -y
        fi
        sudo systemctl start redis
        sudo systemctl enable redis
    fi
else
    display_message "Redis is already installed."
fi

# Check if Bun is installed
if ! command -v bun &> /dev/null; then
    display_message "Bun is not installed. Installing Bun..."
    curl -fsSL https://bun.sh/install | bash
    source ~/.bashrc
else
    display_message "Bun is already installed."
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    display_message "Node.js is not installed. Please install Node.js from https://nodejs.org."
else
    display_message "Node.js is already installed."
fi

# Check if the Prism directory exists
if [ -d "Prism" ]; then
    display_message "Prism is already cloned. Please navigate to the Prism directory to continue."
else
    display_message "Cloning the Prism repository..."
    git clone https://github.com/PrismFOSS/Prism
    cd Prism || exit
    display_message "Installing dependencies..."
    bun install
    display_message "Creating configuration file..."
    cp example_config.toml config.toml
    display_message "Configuration file created. Please configure your config.toml file."
    display_message "Building and starting Prism..."
    cd app || exit
    npm install
    npm run build
    cd ../
    read -p "Installation complete. Do you want to run the program now? (y/n): " run_program
    if [[ "$run_program" == "y" ]]; then
        bun run app.js
    else
        display_message "You can run the program later by navigating to the Prism directory and executing 'bun run app.js'."
    fi
fi
