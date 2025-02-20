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

# Enable mongodb service and run it
sudo systemctl enable mongod
sudo systemctl daemon-reload
sudo systemctl start mongod

# Ensure MongoDB uses authentication so you can construct a MongoDB connection string.
mongo mongodb://localhost:27017 <<EOF
use admin
db.createUser(
  {
    user: "mongodb",
    pwd: "thisisinsecure",
    roles: [ { role: "userAdminAnyDatabase", db: "admin" } ]
  }
)
EOF

# Update mongod.conf to enable authorization
security_config="
security:
    authorization: enabled
"

echo "$security_config" | sudo tee -a /etc/mongod.conf


# Reload the config
sudo systemctl daemon-reload
sudo systemctl restart mongod

# MongoDB Backups: Create a Script which regularly backups the MongoDB databases 
# and transfers them to the created bucket.
 


