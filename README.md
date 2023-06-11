# FreePBX and Asterisk on Docker (Raspberry Pi 4).

Based on https://github.com/epandi/tiredofit-freepbx-arm 
Thank you [Dave Conroy](https://github.com/tiredofit).

# Introduction

This will build a container for [FreePBX](https://www.freepbx.org/) - A Voice over IP manager for Asterisk. Upon starting this image it will give you a turn-key PBX system for SIP calling.

    Latest release FreePBX 16
    Latest release Asterisk 18
    Choice of running embedded database or modifies to support external MariaDB Database and only require one DB.
    Supports data persistence
    Fail2Ban installed to block brute force attacks
    Ubuntu base w/ Apache2
    NodeJS 10.x
    Automatically installs User Control Panel and displays at first page
    Option to Install Flash Operator Panel 2
    Customizable FOP and Admin URLs

# Authors

- [Dave Conroy](https://github.com/tiredofit)

# Table of Contents

1. [Introduction](#introduction)
2. [Authors](#authors)
3. [Table of Contents](#table-of-contents)
4. [Prerequisites](prerequisites)
5. [Installation](#installation)
   1. [Quick Start](#quick-start)
6. [Configuration](#configuration)
   1. [Data Volumes](#data-volumes)
   2. [Environment Variables](#environment-variables)
   3. [Networking](#networking)
7. [Maintenance](#maintenance)
   1. [Shell Access](#shell-access)
8. [References](#references)

# Prerequisites

This image assumes that you are using a reverse proxy such as [jwilder/nginx-proxy](https://github.com/nginx-proxy/nginx-proxy) and optionally the Let's Encrypt Proxy Companion @ https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion in order to serve your pages. However, it will run just fine on it's own if you map appropriate ports.

You will also need an external MySQL/MariaDB container, although it can use an internally provided service (not recommended).

# Installation

Automated builds of the image are available on [Github](https://github.com/elraro/freepbx-asterisk-arm/pkgs/container/freepbx-asterisk-arm) and is the recommended method of installation.

    docker pull elraro/freepbx-asterisk-arm:(imagetag)

The following image tags are available:

* `latest` - Asterisk 18, Freepbx 15 - Ubuntu Focal

You can also visit the image tags section on [Github](https://github.com/elraro/freepbx-asterisk-arm/pkgs/container/freepbx-asterisk-arm) to pull a version that follows the CHANGELOG.

## Quick Start

* The quickest way to get started is using [docker-compose](https://github.com/elraro/freepbx-asterisk-arm/blob/master/docker-compose.yaml). See the example's folder for a working docker-compose.yml that can be modified for development or production use.
* Set various [environment variables](#environment-variables) to understand the capabilities of this image.
* Map [persistent storage](#data-volumes) for access to configuration and data files for backup.
* Make [networking ports](#networking) available for public access if necessary

The first boot can take from 3 minutes - 30 minutes depending on your internet connection as there is a considerable amount of downloading to do!

Login to the web server's admin URL (default /admin) and enter in your admin username, admin password, and email address and start configuring the system!

# Configuration

## Data-Volumes

The container supports data persistence and during Dockerfile build creates symbolic links for `/var/lib/asterisk`, `/var/spool/asterisk`, `/home/asterisk`, and `/etc/asterisk`. Upon startup configuration files are copied and generated to support portability.

The following directories are used for configure and can be mapped for persistent storage.

| Directory        | Description                                                             |
|:----------------:|:-----------------------------------------------------------------------:|
| `/certs`         | Drop your certificates here for TLS w/PJSIP / UCP / HTTPd/ FOP          |
| `/var/www/html`  | FreePBX web files                                                       |
| `/var/log/`      | Apache, Asterisk and FreePBX Log Files                                  |
| `/data`          | Data persistence for Asterisk and FreePBX and FOP                       |
| `/assets/custom` | *OPTIONAL* - If you would like to overwrite some files in the container |

## Environment Variables

Along with the environment variables from the Base image, below is the complete list of available options that can be used to customize your installation.

| Parameter                    | Description                                                                                                     | Default                 |
|:----------------------------:|:---------------------------------------------------------------------------------------------------------------:|:-----------------------:|
| `ADMIN_DIRECTORY`            | What folder to access admin panel                                                                               | `/admin`                |
| `DB_EMBEDDED`                | Allows you to use an internally provided MariaDB Server e.g. `TRUE` or `FALSE`                                  |                         |
| `DB_HOST`                    | Host or container name of MySQL Server e.g. `freepbx-db`                                                        |                         |
| `DB_PORT`                    | MySQL Port                                                                                                      | `3306`                  | 
| `DB_NAME`                    | MySQL Database name e.g. `asterisk`                                                                             |                         |
| `DB_USER`                    | MySQL Username for above database e.g. `asterisk`                                                               |                         |
| `DB_PASS`                    | MySQL Password for above database e.g. `password`                                                               |                         |
| `ENABLE_FAIL2BAN`            | Enable Fail2ban to block the "bad guys"                                                                         | `TRUE`                  |
| `ENABLE_FOP`                 | Enable Flash Operator Panel                                                                                     | `FALSE`                 |
| `ENABLE_SSL`                 | Enable HTTPd to serve SSL requests                                                                              | `FALSE`                 |
| `ENABLE_XMPP`                | Enable XMPP Module with MongoDB                                                                                 | `FALSE`                 |
| `ENABLE_VM_TRANSCRIBE`       | Enable Voicemail Transcription with IBM Watson                                                                  | `FALSE`                 |
| `FOP_DIRECTORY`              | What folder to access FOP                                                                                       | `/fop`                  |
| `HTTP_PORT`                  | HTTP listening port                                                                                             | `80`                    |
| `HTTPS_PORT`                 | HTTPS listening port                                                                                            | `443`                   |
| `INSTALL_ADDITIONAL_MODULES` | Comma separated list of modules to additionally install on first container startup                              |                         |
| `RTP_START`                  | What port to start RTP transmissions                                                                            | `18000`                 |
| `RTP_FINISH`                 | What port to start RTP transmissions                                                                            | `20000`                 |
| `UCP_FIRST`                  | Load UCP as web frontpage `TRUE` or `FALSE`                                                                     | `TRUE`                  |
| `TLS_CERT`                   | TLS certificate to drop in /certs for HTTPS if no reverse proxy                                                 |                         |
| `TLS_KEY`                    | TLS Key to drop in /certs for HTTPS if no reverse proxy                                                         |                         |
| `WEBROOT`                    | If you wish to install to a subfolder use this. Example: `/var/www/html/pbx`                                    | `/var/www/html`         |
| `VM_TRANSCRIBE_APIKEY`       | API Key from Watson [See tutorial](http://nerdvittles.com/?page_id=25616)                                       |                         |
| `VM_TRANSCRIBE_MODEL`        | Watson Voice Model - See [here](https://cloud.ibm.com/docs/speech-to-text?topic=speech-to-text-models) for list | `en-GB_NarrowbandModel` |

`ADMIN_DIRECTORY` and `FOP_DIRECTORY` may not work correctly if `WEBROOT` is changed or `UCP_FIRST=FALSE`

If setting `ENABLE_VM_TRANSCRIBE=TRUE` you will need to change the mailcmd in Freepbx voicemail settings to `/usr/bin/watson-transcription` and set the API Key.

## Networking

The following ports are exposed.

| Port              | Description |
|:-----------------:|:-----------:|
| `80`              | HTTP        |
| `443`             | HTTPS       |
| `4445`            | FOP         |
| `4569`            | IAX         |
| `5060`            | PJSIP       |
| `5160`            | SIP         |
| `8001`            | UCP         |
| `8003`            | UCP SSL     |
| `8008`            | UCP         |
| `8009`            | UCP SSL     |
| `18000-20000/udp` | RTP ports   |

## Fail2Ban

For fail2ban rules to kickin, the `security` log level needs to be enable for asterisk `full` log file. This can be done from the Settings > Log File Settings > Log files.

# Maintenance

* There seems to be a problem with the CDR Module when updating where it refuses to update when using an external DB Server. If that happens, simply enter the container (as shown below) and execute `upgrade-cdr`, which will download the latest CDR module, apply a tweak, install, and reload the system for you.

# Known Bugs

* When installing Parking Lot or Feature Codes you sometimes get `SQLSTATE[22001]: String data, right truncated: 1406 Data too long for column 'helptext' at row 1`. To resolve login to your SQL server and issue this statement: `alter table featurecodes modify column helptext varchar(500);`
* If you find yourself needing to update the framework or core modules and experience issues, enter the container and run `upgrade-core` which will truncate the column and auto upgrade the core and framework modules.

# Shell Access

For debugging and maintenance purposes you may want access the containers shell.

    docker exec -it (whatever your container name is e.g. freepbx) bash

# References

* https://hub.docker.com/r/tiredofit/freepbx
* https://github.com/epandi/tiredofit-freepbx-arm
* https://freepbx.org/
