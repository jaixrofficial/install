#!/bin/bash

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

# Install Redis
function install_redis() {
    if ! command -v redis-server &>/dev/null; then
        log_success "Redis is not installed. Installing Redis..."
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            if [[ -f /etc/debian_version ]]; then
                $DRY_RUN || sudo apt update && sudo apt install redis-server -y
            elif [[ -f /etc/redhat-release ]]; then
                $DRY_RUN || sudo dnf install epel-release -y && sudo dnf install redis -y
            else
                log_error "Unsupported Linux distribution. Please install Redis manually."
                exit 1
            fi
            $DRY_RUN || sudo systemctl enable redis && sudo systemctl start redis
        else
            log_error "Unsupported OS. Please install Redis manually."
            exit 1
        fi
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
