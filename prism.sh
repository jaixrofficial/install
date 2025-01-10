#!/bin/bash

####################################################################################
#                                    Install                                         #
#                                                                                    #
#   © 2018 - 2024 Jaixr                                                              #
#                                                                                    #
#   Author: Jaixr                                                                    #
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
 
██████╗ ██████╗ ██╗███████╗███╗   ███╗
██╔══██╗██╔══██╗██║██╔════╝████╗ ████║
██████╔╝██████╔╝██║███████╗██╔████╔██║
██╔═══╝ ██╔══██╗██║╚════██║██║╚██╔╝██║
██║     ██║  ██║██║███████║██║ ╚═╝ ██║
╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝     ╚═╝
                                      
                      Author:Jaixr
                      Last Updated: 2024-12-02
\033[0m"

# Color definitions
BLUE="\033[0;34m"
WHITE="\033[1;37m"
GREEN="\033[0;32m"
RESET="\033[0m"

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Updating package list and installing dependencies...${RESET}"
    sudo apt-get update
    sudo apt-get install -y lsb-release curl gpg
}

# Function to install the latest version of Node.js
install_node() {
    echo -e "${BLUE}Installing the latest version of Node.js...${RESET}"
    curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
    sudo apt-get install -y nodejs
    node -v  # Verify Node.js installation

    # Install/Upgrade npm to the latest version
    echo -e "${BLUE}Upgrading npm to the latest version...${RESET}"
    sudo npm install -g npm@latest
    npm -v  # Verify npm installation
}

# Function to add Redis repository and key
add_redis_repo() {
    echo -e "${BLUE}Adding Redis repository and key...${RESET}"
    curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
    sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
}

# Function to install Redis
install_redis() {
    echo -e "${GREEN}Installing Redis...${RESET}"
    sudo apt-get update
    sudo apt-get install -y redis
}

# Function to enable and start Redis based on user choice
manage_redis() {
    echo -e "${WHITE}Which service manager would you prefer to use for Redis? (systemctl/service):${RESET}"
    read service_manager

    if [[ "$service_manager" == "systemctl" ]]; then
        echo -e "${GREEN}Using systemctl to manage Redis service...${RESET}"
        sudo systemctl enable redis-server
        sudo systemctl start redis-server
    elif [[ "$service_manager" == "service" ]]; then
        echo -e "${GREEN}Using service to manage Redis service...${RESET}"
        sudo service redis-server enable
        sudo service redis-server start
    else
        echo -e "${RED}Invalid choice. Please select either 'systemctl' or 'service'. Exiting.${RESET}"
        exit 1
    fi
}

# Function to install Bun
install_bun() {
    echo -e "${BLUE}Installing Bun...${RESET}"
    curl -fsSL https://bun.sh/install | bash
}

# Function to upgrade Bun to Canary version
upgrade_bun() {
    echo -e "${GREEN}Upgrading Bun to Canary...${RESET}"
    bun upgrade --canary
}

# Function to clone and set up Prism repository
setup_prism() {
    echo -e "${BLUE}Cloning Prism repository...${RESET}"
    git clone https://github.com/PrismFOSS/Prism

    echo -e "${GREEN}Installing project dependencies...${RESET}"
    cd Prism
    bun install

    echo -e "${BLUE}Copying example_config.toml to config.toml...${RESET}"
    cp example_config.toml config.toml

    echo -e "${WHITE}Please configure the 'config.toml' file to work properly with Prism.${RESET}"
    echo -e "${WHITE}Make necessary changes in 'config.toml', then press Enter to continue...${RESET}"
    read -p "Press Enter once you're done configuring the file."

    cd app
    npm install
    npm run build
    cd ../
}

# Function to run the app
run_app() {
    echo -e "${GREEN}Running the app...${RESET}"
    bun run app.js
}

# Main function to execute all steps
main() {
    install_dependencies
    install_node  # Install Node.js and npm first
    add_redis_repo
    install_redis
    manage_redis
    install_bun
    upgrade_bun
    setup_prism
    run_app
}

# Start the installation process
main
