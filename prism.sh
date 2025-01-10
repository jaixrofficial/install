#!/bin/bash 

# Color definitions
BLUE="\033[0;34m"
WHITE="\033[1;37m"
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Function to check if a package is installed
check_package_installed() {
    dpkg -l | grep -qw "$1"
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Updating package list and installing dependencies...${RESET}"
    sudo apt-get update

    # Loop through package list and install if not present
    for pkg in lsb-release curl gpg; do
        if ! check_package_installed "$pkg"; then
            sudo apt-get install -y "$pkg"
        else
            echo -e "${GREEN}$pkg is already installed.${RESET}"
        fi
    done
}

# Function to install the latest version of Node.js
install_node() {
    echo -e "${BLUE}Installing the latest version of Node.js...${RESET}"

    # Check if Node.js is already installed
    if ! command -v node &>/dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_current.x | sudo -E bash -
        sudo apt-get install -y nodejs
        node -v
    else
        echo -e "${GREEN}Node.js is already installed.${RESET}"
        node -v
    fi

    echo -e "${BLUE}Upgrading npm to the latest version...${RESET}"
    sudo npm install -g npm@latest
    npm -v
}

# Function to add Redis repository and key
add_redis_repo() {
    echo -e "${BLUE}Adding Redis repository and key...${RESET}"

    # Check if Redis repository is already added
    if ! check_package_installed "redis-server"; then
        curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list
    else
        echo -e "${GREEN}Redis repository is already added.${RESET}"
    fi
}

# Function to install Redis
install_redis() {
    echo -e "${GREEN}Installing Redis...${RESET}"

    # Check if Redis server is installed
    if ! check_package_installed "redis-server"; then
        sudo apt-get update
        sudo apt-get install -y redis-server
    else
        echo -e "${GREEN}Redis is already installed.${RESET}"
    fi
}

# Function to enable and start Redis based on user choice
manage_redis() {
    echo -e "${WHITE}Which service manager would you prefer to use for Redis? (systemctl/service):${RESET}"
    read -r service_manager

    case "$service_manager" in
        systemctl)
            echo -e "${GREEN}Using systemctl to manage Redis service...${RESET}"
            sudo systemctl enable redis-server
            sudo systemctl start redis-server
            ;;
        service)
            echo -e "${GREEN}Using service to manage Redis service...${RESET}"
            sudo service redis-server enable
            sudo service redis-server start
            ;;
        *)
            echo -e "${RED}Invalid choice. Please select either 'systemctl' or 'service'. Exiting.${RESET}"
            exit 1
            ;;
    esac
}

# Function to install Bun
install_bun() {
    echo -e "${BLUE}Installing Bun...${RESET}"

    # Check if Bun is already installed
    if ! command -v bun &>/dev/null; then
        curl -fsSL https://bun.sh/install | bash
    else
        echo -e "${GREEN}Bun is already installed.${RESET}"
    fi
}

# Function to upgrade Bun to Canary version
upgrade_bun() {
    echo -e "${GREEN}Upgrading Bun to Canary...${RESET}"
    bun upgrade --canary
}

# Function to clone and set up Prism repository
setup_prism() {
    echo -e "${BLUE}Cloning Prism repository...${RESET}"

    # Check if the Prism directory exists before cloning
    if [ ! -d "Prism" ]; then
        git clone https://github.com/PrismFOSS/Prism
    else
        echo -e "${GREEN}Prism repository already exists.${RESET}"
    fi

    echo -e "${GREEN}Installing project dependencies...${RESET}"
    cd Prism || exit 1

    bun install

    echo -e "${BLUE}Copying example_config.toml to config.toml...${RESET}"
    cp example_config.toml config.toml

    echo -e "${WHITE}Please configure the 'config.toml' file to work properly with Prism.${RESET}"
    echo -e "${WHITE}Make necessary changes in 'config.toml', then press Enter to continue...${RESET}"
    read -r -p "Press Enter once you're done configuring the file."

    cd app || exit 1
    npm install
    npm run build
    cd ../ || exit 1
}

# Function to run the app
run_app() {
    echo -e "${GREEN}Running the app...${RESET}"
    bun run app.js
}

# Main function to execute all steps
main() {
    install_dependencies
    install_node
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
