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

# Function to display colored messages
function display_message() {
    local color_code="$1"
    local message="$2"
    echo -e "\n\033[${color_code}m${message}\033[0m"
}

# Function to log success and errors
function log_success() { display_message "1;32" "$1"; }
function log_error() { display_message "1;31" "$1"; }

# Function to detect shell and source configuration file
function source_shell_config() {
    local shell_rc
    case "$SHELL" in
        */bash) shell_rc="$HOME/.bashrc" ;;
        */zsh)  shell_rc="$HOME/.zshrc" ;;
        *)      log_error "Unsupported shell. Please source your shell configuration manually." && return ;;
    esac
    [ -f "$shell_rc" ] && source "$shell_rc"
}

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
    log_error "Please run this script with sudo or as root."
    exit 1
fi

# Dry-run mode for testing
DRY_RUN=false
while getopts "d" opt; do
    case "$opt" in
        d) DRY_RUN=true ;;
        *) log_error "Invalid option"; exit 1 ;;
    esac
done

# Install Redis with official Redis repository
function install_redis() {
    if ! command -v redis-server &>/dev/null; then
        log_success "Redis is not installed. Installing Redis..."

        # Install necessary packages
        $DRY_RUN || sudo apt-get install -y lsb-release curl gpg

        # Add Redis GPG key
        $DRY_RUN || curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
        $DRY_RUN || sudo chmod 644 /usr/share/keyrings/redis-archive-keyring.gpg

        # Add Redis repository to sources list
        $DRY_RUN || echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

        # Update apt repositories and install Redis
        $DRY_RUN || sudo apt-get update
        $DRY_RUN || sudo apt-get install -y redis

        # Prompt user for systemctl or service choice
        log_success "Redis installation is complete. Choose your service manager."
        local choice
        while true; do
            read -p "Use 'systemctl' or 'service' to start and enable Redis? (systemctl/service): " choice
            case "$choice" in
                systemctl)
                    $DRY_RUN || { sudo systemctl enable redis && sudo systemctl start redis; }
                    log_success "Redis started and enabled using systemctl."
                    break
                    ;;
                service)
                    $DRY_RUN || { sudo service redis-server start && sudo service redis-server enable; }
                    log_success "Redis started and enabled using service."
                    break
                    ;;
                *)
                    log_error "Invalid choice. Please enter 'systemctl' or 'service'."
                    ;;
            esac
        done
    else
        log_success "Redis is already installed."
    fi
}

# Install Bun
function install_bun() {
    if ! command -v bun &>/dev/null; then
        log_success "Bun is not installed. Installing Bun..."
        $DRY_RUN || curl -fsSL https://bun.sh/install | bash
        source_shell_config
    else
        log_success "Bun is already installed."
    fi
}

# Check Node.js installation
function check_nodejs() {
    if ! command -v node &>/dev/null; then
        log_error "Node.js is not installed. Please install it from https://nodejs.org."
        exit 1
    else
        log_success "Node.js is already installed."
    fi
}

# Check Git installation
function check_git() {
    if ! command -v git &>/dev/null; then
        log_error "Git is not installed. Please install Git to continue."
        exit 1
    fi
}

# Clone and setup Prism repository
function setup_prism() {
    if [ -d "Prism" ]; then
        log_success "Prism is already cloned. Please navigate to the Prism directory to continue."
    else
        log_success "Cloning the Prism repository..."
        $DRY_RUN || git clone https://github.com/PrismFOSS/Prism || {
            log_error "Failed to clone the repository. Check your internet connection."
            exit 1
        }
        cd Prism || exit
        log_success "Installing dependencies..."
        $DRY_RUN || bun install || { log_error "Failed to install dependencies."; exit 1; }

        log_success "Creating configuration file..."
        $DRY_RUN || cp example_config.toml config.toml || {
            log_error "Failed to create configuration file. Check file permissions."
            exit 1
        }

        log_success "Building and starting Prism..."
        cd app || exit
        $DRY_RUN || npm install && npm run build || {
            log_error "Failed to build the application."
            exit 1
        }
        cd ../
        prompt_run_program
    fi
}

# Prompt user to run the program
function prompt_run_program() {
    local run_program
    for _ in {1..3}; do
        read -t 30 -p "Installation complete. Do you want to run the program now? (y/n): " run_program
        case "$run_program" in
            y|Y)
                $DRY_RUN || bun run app.js
                return
                ;;
            n|N)
                log_success "You can run the program later by navigating to the Prism directory and executing 'bun run app.js'."
                return
                ;;
            *) log_error "Invalid input. Please enter 'y' or 'n'." ;;
        esac
    done
    log_error "No valid input provided. Exiting..."
}

# Main Execution
install_redis
install_bun
check_nodejs
check_git
setup_prism

log_success "Script execution complete!"
