#!/bin/bash

# Display the ASCII Art logo in white
echo -e "\033[97m
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

# Start the project using npm run start
echo "Starting the project with npm run start..."
npm run start

# Final message
echo "Airlink Panel installation and setup complete!"
