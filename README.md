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

7. Set the [Systemd Service](#systemd-service)

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

5. Import (i.e. copy-paste) into the HomeAssistant dashboard the `frontend.yml` file


## Systemd Service
Usually, set `restart: unless-stopped` on all docker compose containers should be enough to restart them after a system reboot. But, for some reasons, in this way the docker's hostname resolution [doesn't work](https://github.com/moby/libnetwork/issues/2049) after the reboot. So, the `homeassistant` container cannot connect to the `mariadb` and `mosquitto` services.

As workaround, we'll manually start and stop the docker compose with a `systemd` service.

1. Create the file `/etc/systemd/system/iot-server.service` with the following content

    <details>
    <summary>✨ Click to see the code</summary>

    ```ini
    [Unit]
    Description=IOT Server Service
    Requires=docker.service
    After=docker.service

    [Service]
    Type=oneshot
    RemainAfterExit=yes
    WorkingDirectory=/home/raspi/iot-server
    ExecStart=/usr/bin/docker compose up
    ExecStop=/usr/bin/docker compose down
    TimeoutStartSec=0

    [Install]
    WantedBy=multi-user.target
    ```

    </details>

    ⚠️ Make sure that `WorkingDirectory` points to your `docker-compose.yml` folder.

2. Set file permissions

    ```bash
    $ sudo chown root:root /etc/systemd/system/iot-server.service
    $ sudo chmod 644 /etc/systemd/system/iot-server.service
    ```

4. Reload systemd and enable the service

    ```bash
    $ sudo systemctl daemon-reload
    $ sudo systemctl enable iot-server.service
    $ sudo systemctl start iot-server.service
    ```