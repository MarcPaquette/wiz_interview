#!/usr/bin/env bash
set -xe

MONGO_DB_NAME="admin"
MONGO_DB_USER="mongodb"
MONGO_DB_PASSWORD="thisisinsecure"

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

sleep 30 # Wait for MongoDB to start before proceeding

# Ensure MongoDB uses authentication so you can construct a MongoDB connection string.
mongosh mongodb://localhost:27017 <<EOF
use admin
db.createUser(
  {
    user: "$MONGO_DB_USER",
    pwd: "$MONGO_DB_PASSWORD",
    roles: [ { role: "userAdminAnyDatabase", db: "$MONGO_DB_NAME" },
             { role: "backup", db: "$MONGO_DB_NAME"}
           ]
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

# MongoDB Backups: Create a Script which regularly backups the MongoDB
# and transfers them to the created bucket.
sudo mkdir -p /var/backups/mongobackups
 
 # Backup every 15 minutes
(sudo crontab -l 2>/dev/null; echo "*/10 * * * * mongodump --db $MONGO_DB_NAME -u $MONGO_DB_USER -p $MONGO_DB_PASSWORD --authenticationDatabase $MONGO_DB_NAME --out /var/backups/mongobackups/\$\(date +'%m-%d-%y'\)") | sudo crontab -
