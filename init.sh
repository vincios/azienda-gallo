#!/bin/bash
# Create files and folders
FOLDERS=(./secrets ./mariadb/data/ ./mosquitto/data ./mosquitto/log ./traefik/log ./traefik/config/acme/)
FILES=(./secrets/duckdns_token.txt ./secrets/mariadb_password.txt ./secrets/vscode_password.txt ./mosquitto/config/mosquitto.passwd)

echo "Creating folders..."
for folder in "${FOLDERS[@]}"; do
  echo -n "  $folder"
  if [ ! -d "$folder" ] ; then
      mkdir "$folder"
      sudo chown -R "$USER":"$USER" "$folder"
  else
    echo -e "\talready exists"
  fi

  echo -e "\n"
done

echo " "

# Create files
echo "Creating files..."
for file in "${FILES[@]}"; do
  echo -n "  $file"
  if [ ! -f "$file" ] ; then
      touch "$file"
      sudo chown -R "$USER":"$USER" "$file"
  else
    echo -e "\talready exists"
  fi

  echo -e "\n"
done

echo " "

# Create the acme.json file
echo "Creating acme.json file..."
touch ./traefik/config/acme/acme.json
chmod 600 ./traefik/config/acme/acme.json

# Create the .env file
echo "Creating .env file..."
HOST_IP=`hostname -I | cut -d " " -f1`

cat > .env <<EOL
DUCKDNS_DOMAIN=<YOUR_DUCKDNS_DOMAIN>
HOST_IP=${HOST_IP}
EOL

echo "Creating homeassistant/secrets.yaml file..."
cat > ./homeassistant/secrets.yaml <<EOL
# Use this file to store secrets like usernames and passwords.
# Learn more at https://www.home-assistant.io/docs/configuration/secrets/
mariadb_url: mysql://<YOUR_MYSQL_USER>:<YOUR_MYSQL_PASSWORD>@mariadb/homeassistant?charset=utf8mb4
EOL

echo "Setting privileges..."
sudo chown -R homeassistant:homeassistant ./homeassistant/
sudo chmod -R g+rwx ./homeassistant/
sudo chmod +x ./homeassistant/run