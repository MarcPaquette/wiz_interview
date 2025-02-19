#!/usr/bin/env bash
set -xe


# Prerequisits
sudo apt-get install gnupg curl

# Install an older MongoDB Major release package on this VM
curl -fsSL https://www.mongodb.org/static/pgp/server-5.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-5.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-5.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list

sudo apt-get update
sudo apt-get install -y mongodb-org


# Ensure MongoDB uses authentication so you can construct a MongoDB connection string.


# MongoDB Backups: Create a Script which regularly backups the MongoDB databases 
# and transfers them to the created bucket.
 

# Enable mongodb service and run it
sudo systemctl enable mongod
sudo systemctl daemon-reload
sudo systemctl start mongod


