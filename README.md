<div align="center">

## 🗨️ Ciphera 

| ![ScreenSelect_20241019_173432_Emulator](https://github.com/user-attachments/assets/f59ded29-ecc2-4653-a1c6-141549ff63af) | ![ScreenSelect_20241019_173438_Emulator](https://github.com/user-attachments/assets/2e1394f4-e4d0-4531-9c1b-53519000ebd4) | ![ScreenSelect_20241019_173809_Emulator](https://github.com/user-attachments/assets/50ae41d0-fe52-45c6-9245-3c2c7012d9a9) | ![ScreenSelect_20241019_173540_Emulator](https://github.com/user-attachments/assets/f9fc6f57-6ce8-4a26-9875-fc3cbfec7df7) | ![ScreenSelect_20241019_173824_Emulator](https://github.com/user-attachments/assets/46114db3-3f75-4968-b200-540b5e46bf2a) | ![ScreenSelect_20241019_173829_Emulator](https://github.com/user-attachments/assets/ad6bc1c8-0d5e-4f0a-8735-c3cbbf74cab7) |
|---|---|---|---|---|---|

<samp>
Secure messaging was never this easy.
</samp>

</div>

## About this app
Ciphera is a decentralized multi-platform (Flutter) Matrix client messaging app. 
It allows for secure messaging with full support for end-to-end encryption using the Matrix REST API and the Olm/Megolm protocols.

## Features

- **Decentralized**: The backend server can be hosted by anyone.
- **Cross-platform support**: This app is made in Flutter which supports building for all major platforms.
- **Secure Messaging**: All data is AES-256 encrypted at rest
- **End-to-End Encryption**: E2EE for direct chats using [Olm/Megolm](https://gitlab.matrix.org/matrix-org/olm)
- **Light/Dark Modes**

## Setup

<details>
  <summary>Setting up Synapse</summary>

  [Synapse](https://github.com/element-hq/synapse) is an open-source Matrix homeserver implementation. We will be using this for our messaging service.

  - Go to `synapse` directory and run the following command:
    
    ```bash
    sudo docker run -it --rm
    -v $(pwd)/data:/data
    -e SYNAPSE_SERVER_NAME=<your ip address>
    -e SYNAPSE_REPORT_STATS=yes
    matrixdotorg/synapse:latest generate
    ```
  - A `homeserver.yaml` file will be generated in the `data` directory. We have to modify a few lines in this file so as to use Postgres database instead of the default SQLite. You might need to use terminal-based editors on Linux since these require admin privileges.
    
    ```yaml
    # /data/homeserver.yaml
    # Change the database part
    ....
    ...
    database:
      name: psycopg2
      args:
        user: synapse_user
        password: your_password
        database: synapse
        host: postgres
        port: 5432
      allow_unsafe_locale: true
    ...
    ...
    # ..and a bit of server modifications to ease the registration process
    allow_public_users: true
    enable_registration: true
    enable_registeration_captcha: false
    enable_registration_without_verification: true
    suppress_key_server_warning: true
    rate_limiting:
      enabled: true
      per_second: 10
      burst_size: 20
    ```
  - Make docker containers.

    ```bash
    docker-compose up -d --build

    # check status of containers
    docker ps

    ## Stop compose
    docker-compose stop

    ## Start compose
    docker-compose start

    ## Register a user using cli
    docker exec -it synapse register_new_matrix_user http://localhost:8008 -c /data/homeserver.yaml -u username -p password --no-admin
    ```
</details>

<details>
  <summary>Setting up Registration Server (optional if not using the register button in app)</summary>

  - Run the Flask app.

    ```bash
    cd registration-backend

    sudo pip install flask

    sudo python app.py
    ```
</details>

<details>
  <summary>Building the Ciphera app</summary>

  Since this app is made using Flutter, we can build and run applications for Linux, ChromeOS, Windows, Android and macOS. For further information, check [Flutter website](https://docs.flutter.dev/get-started/install).

  - Run the app.

    ```bash
    cd flutter-app

    # get required programs to run on your desired platform

    # check devices
    flutter device

    flutter run
    ```
</details>
