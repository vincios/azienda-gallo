# IOT Server configuration

## General Setup
1. Create a `homeassistant` user and a `homeassistant` group

    ```sh
    $ sudo groupadd --gid 8123 homeassistant
    $ sudo useradd -r --uid 8123 -gid 8123 homeassistant
    $ sudo usermod -a -G homeassistant $USER
    ```

2. Run the `init.sh` script

3. Make an `.env` file, with the following content

    ```env
    DUCKDNS_DOMAIN=<YOUR_DUCKDNS_DOMAIN>
    HOST_IP=<YOUR_HOST_STATIC_IP>
    ```

4. Fill the secrets files, into the `secrets` folder

    💡 In `mariadb_password.txt` you can write anything, and it will be your database's root and user password

5. Set the mosquitto password

  1. Run the mosquitto container
    
      ```sh
      $ docker exec -it mosquitto sh
      ```

  2. Set the password for the user `mosquitto_usr`

      ```sh
      $ mosquitto_passwd -c /mosquitto/config/mosquitto.passwd mosquitto_usr
      ```

6. Set the LetsEncrypt email in the `traefik/config/traefik.yml` file

## Home Assistant
1. Edit the `secret.yml` file, with the following content

    ```yml
    # Use this file to store secrets like usernames and passwords.
    # Learn more at https://www.home-assistant.io/docs/configuration/secrets/
    mariadb_url: mysql://user:<YOUR_MARIADB_PASSWORD>@mariadb/homeassistant?charset=utf8mb4
    ```

2. Add the following integrations:

    1. `MQTT`

        💡 As the `Broker` field (i.e. broker url) you can use the Mosquitto Docker Compose service name: `mosquitto`
    2. ESPHome (if not auto dicovered)
    3. [HACS](https://hacs.xyz/)

4. Add the following Custom Components

    1.