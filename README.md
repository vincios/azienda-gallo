# IOT Server configuration

## General Setup
0. Clone this repository

    ```sh
    $ git clone https://github.com/vincios/azienda-gallo.git
    ```

1. Create a `homeassistant` user and a `homeassistant` group

    ```sh
    $ sudo groupadd --gid 8123 homeassistant
    $ sudo useradd -r --uid 8123 -gid 8123 homeassistant
    $ sudo usermod -a -G homeassistant $USER
    ```

2. Run the `init.sh` script

3. Fill the `.env` file, with the following content

    ```env
    DUCKDNS_DOMAIN=<YOUR_DUCKDNS_DOMAIN>
    HOST_IP=<YOUR_HOST_STATIC_IP>
    ```

4. Fill the secrets files, into the `secrets` folder   

    ⚠️ Make sure to not add special characters (like newlines or unwanted spaces) in the secret files!

    💡 In `mariadb_password.txt` you can write anything, and it will be your database's root and user password

5. Set the mosquitto password

    1. Run the mosquitto container
        
        ```sh
        $ docker compose up -d mosquitto
        $ docker exec -it mosquitto sh
        ```

    2. Set the password for the user `mosquitto_usr`

        ```sh
        $ mosquitto_passwd -c /mosquitto/config/mosquitto.passwd mosquitto_usr
        ```

    3. Exit and dispose the container

        ```sh
        $ exit
        $ docker compose down
        ```

6. Set the LetsEncrypt email in the `traefik/config/traefik.yml` file

7. Fill the `homeassistant/secrets.yaml` file with the required fields

8. Perform a first run. Use the logs to check for errors

    1. Start the containers, without the `-d` option
    
        ```sh
        $ docker compose up
        ```

    2. When you see `Starting homeassistant...`, open the browser at the url

        ```
        http://<YOUR_HOST_LOCAL_IP>:8123
        ```

        And complete the Onboarding process
    
    3. Check if also the following urls works

        ```
        https://dashboard.<DUCKDNS_DOMAIN>.duckdns.org
        https://editor.<DUCKDNS_DOMAIN>.duckdns.org
        https://traefik.<DUCKDNS_DOMAIN>.duckdns.org
        ws://mqtt.<DUCKDNS_DOMAIN>.duckdns.org
        ```

        ⚠️ To check `ws://mqtt.<DUCKDNS_DOMAIN>.duckdns.org` you need a [MQTT client](http://mqtt-explorer.com/).

9. Stop with `Ctrl-C` and dispose the containers

    ```sh
    $ exit
    $ docker compose down
    ```

10. Install the [Systemd Service](#systemd-service)

## Home Assistant
1. Add the following integrations:

    1. `MQTT`

        💡 As the `Broker` field (i.e. broker url) you can use the Mosquitto Docker Compose service name: `mosquitto`
    2. ESPHome (if not auto dicovered)
    3. [HACS](https://hacs.xyz/)

2. Add the following Custom Components

    1.

3. Import (i.e. copy-paste) into the HomeAssistant dashboard the `frontend.yml` file


## Mosquitto
Mosquitto MQTT Broker is protected with TLS. You can access to the broker either inside the local network or from outside, and either with the **ws://** protocol or the **TCP (mqtt://)** protocol.

Inside the local network:
- **mqtt:// protocol (with TLS)**
    
    Address: YOUR_HOST_STATIC_IP
    
    Port: 1883

- **mqtt:// protocol (without TLS)**
    
    Address: YOUR_HOST_STATIC_IP
    
    Port: 1884

- **ws:// protocol (without TLS)**
    
    Address: YOUR_HOST_STATIC_IP
    
    Port: 9001

From Internet:
- **mqtt:// protocol (with TLS)** (only if port 1883 opened on your router)
    
    Address: mqtt.<YOUR_DUCKDNS_DOMAIN>.duckdns.org
    
    Port: 1883

- **ws:// protocol (with TLS)**
    
    Address: mqtt.<YOUR_DUCKDNS_DOMAIN>.duckdns.org

    Port: 443

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