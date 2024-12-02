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

   #!/bin/bash

####################################################################################
#                                   AirInstall                                      #
#                                                                                    #
#   © 2018 - 2024 InfiniteeDev                                                       #
#                                                                                    #
#   Author: InfiniteeDev                                                             #
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

# Display the ASCII Art logo with author and updated date
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

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please run as root or use sudo."
    exit 1
fi

# Go to the /var/www/ directory and clone the repository
cd /var/www/
echo "Cloning the repository..."
git clone https://github.com/AirlinkLabs/panel.git
cd panel || { echo "Failed to enter the panel directory."; exit 1; }

# Install TypeScript globally
echo "Installing TypeScript globally..."
npm install -g typescript

# Install project dependencies
echo "Installing project dependencies..."
npm install --production

# Run database migration
echo "Running database migration..."
npm run migrate-deploy

# Build the TypeScript project
echo "Building the TypeScript project..."
npm run build-ts

# Final message
echo "AirLink Panel setup complete!"


             Author: InfiniteeDev
             Last Updated: 2024-11-13
\033[0m"

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "This script requires root privileges. Please run as root or use sudo."
    exit 1
fi

# Go to the /var/www/ directory and clone the repository
cd /var/www/
echo "Cloning the repository..."
git clone https://github.com/AirlinkLabs/panel.git
cd panel || { echo "Failed to enter the panel directory."; exit 1; }

# Install TypeScript globally
echo "Installing TypeScript globally..."
npm install -g typescript

# Install project dependencies
echo "Installing project dependencies..."
npm install --production

# Run database migration
echo "Running database migration..."
npm run migrate-deploy

# Build the TypeScript project
echo "Building the TypeScript project..."
npm run build-ts

# Final message
echo "AirLink Panel setup complete!"
