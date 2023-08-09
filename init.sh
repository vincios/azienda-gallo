#!/bin/bash
# Create the user
echo "Setting privileges..."
sudo chown -R homeassistant:homeassistant ./homeassistant/
sudo chmod -R g+rwx ./homeassistant/
sudo chmod +x ./homeassistant/run

# Create files and folders
FOLDERS=(./secrets ./mariadb/data/ ./mosquitto/data ./mosquitto/log ./traefik/log ./traefik/config/acme/)
FILES=(./secrets/duckdns_token.txt ./secrets/mariadb_password.txt)

echo "Creating folders..."
for folder in "${FOLDERS[@]}"; do
  echo -n "  $folder"
  if [ ! -d "$folder" ] ; then
      mkdir "$folder"
      sudo chown -R "$USER":"$USER" "$folder"
  else
    echo -e "\talready exists"
  fi

done

# Create secrets files
echo "Creating files..."
for file in "${FILES[@]}"; do
  echo -n "  $file"
  if [ ! -f "$file" ] ; then
      touch "$file"
      sudo chown -R "$USER":"$USER" "$file"
  else
    echo -e "\talready exists"
  fi

done

# Create the acme.json file
touch ./traefik/config/acme/acme.json
chmod 600 ./traefik/config/acme/acme.json