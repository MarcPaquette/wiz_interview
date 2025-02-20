#!/usr/bin/env bash
set -xe

MONGO_DB_NAME="admin"
MONGO_DB_USER="mongodb"
MONGO_DB_PASSWORD="thisisinsecure"
MONGO_DB_BACKUP_DIRECTORY="/var/backups/mongodb"

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
sudo mkdir -p "$MONGO_DB_BACKUP_DIRECTORY"
 
# Backup every 10 minutes
sudo systemctl enable cron
sudo crontab -l 2> /dev/null || true #this is hack to prime crontab for first use
#echo "*/10 * * * * mongodump --db $MONGO_DB_NAME -u $MONGO_DB_USER -p $MONGO_DB_PASSWORD --authenticationDatabase $MONGO_DB_NAME --out $MONGO_DB_BACKUP_DIRECTORY/\$(date +\%s)/" | sudo crontab -

# Package and Ship backups every 10 min
#(sudo crontab -l ; echo "*/10 * * * * /snap/bin/gcloud storage cp /var/backups/mongodb/* gs://mongodb-backups-s3 --recursive") | sudo crontab -
echo "*/10 * * * * mongodump --db $MONGO_DB_NAME -u $MONGO_DB_USER -p $MONGO_DB_PASSWORD --authenticationDatabase $MONGO_DB_NAME --out $MONGO_DB_BACKUP_DIRECTORY/\$(date +\%s)/ && /snap/bin/gcloud storage cp $MONGO_DB_BACKUP_DIRECTORY/* gs://mongodb-backups-s3 --recursive") | sudo crontab -

echo "We good!"
