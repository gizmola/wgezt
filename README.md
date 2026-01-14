# Wireguard Easy with Traefik (WGEZT)

## About this Project
This project provides a docker composed ["Wireguard Easy"](https://github.com/wg-easy/wg-easy) server using [Traefik](https://traefik.io/traefik) as the reverse proxy server and SSL certificate manager, and includes letsencrypt configuration and traefik routing and security.

It is designed to be self contained, and includes tools to configure this setup for a production installation.  It includes this file as documentation, and template files which include additional comments and examples.

To set up _Wireguard Easy_ and _Traefik_, you will copy a few template files, edit variables in a _.env_ file, run a few utilities and start the easy wireguard system using "docker compose".

It makes use of and depends on both the easy-wireguard project and traefik.

## Configuration ##
The Host machine/Server requires the following ports to be open for client connections:
- UDP 51820 (WireGuard)
- TCP/80
- TCP/443,UDP/443

### Create the Docker Network ###
You will need to do this initially, as the docker-compose.yml file specifies the network exist externally.

```
docker network create traefik
```
### Copy env.sample to .env
```
cp env.sample .env
```

### Copy acme.json.tpl to acme.json
You will not need to add or edit this file unless you have generated the contents manually which is not covered by this project.  Prior to installation the file will contain an empty json body: ```{}```
```
cp config/traefik/tpl/acme.json.tpl config/traefik/acme.json
chmod 600 config/traefik/acme.json
```

### config/traefik/tpl/compose.override.yml.tpl
This file is designed to allow configuration of different DNS Providers using the dnsChallenge method.

DNS Challenges are the most flexible way to generate 

By changing settings in this file, or if needed adding additional environment variables to the .env file, other DNS providers can be supported without requiring changes to the docker-compose.yml or template files.

The best way to understand how to support authorization is to read the Traefik documentation and refer to the [LEGO library](https://go-acme.github.io/lego/dns/index.html) documentation.

```
cp config/traefik/tpl/compose.override.yml.tpl compose.override.yml
```
### Customize variables and Settings
- Edit the .env and add required values.
- If you are using a specific DNS provider, you will need to determine what credentials/environment variables or settings that specific DNS provider uses.
- In general, the idea is that different providers allow API calls to read and update DNS entries which letsencrypt can use to authenticate you as the owner of the domain.  This is particularly useful in circumstances where a development certificate is needed for a localhost installation, or the installation is within a private network. 

Note: The included templates assume AWS Route53 is providing DNS Challenge authentication. 

This project is an attempt to support different DNS Challenge providers supported by Traefik, which utilizes the _"Let's Encrypt Go library (LEGO)"_. 

Primarily this is done by adding environment variables or other specific Traefik settings to a compose.override.yml file.  Docker compose will read the compose.override.yml file and add those settings to the traefik service. 

### Generating dynamic.yml and traefik.yml files
Docker reads environment variables from a .env file when it starts. However, this is not a feature generic to yml files, or other configuration files in general.  

In order to read values from the .env file, this project utilizes *...yml.tpl* templates which ```make_tpl.sh``` uses to generate the files needed for your production system.

### make_tpl.sh
make_tpl.sh is a simple bash script that performs replacement of values in the template file, using the environment variables you have set in the .env file and the envsubst utility which is available for most operating systems.

Once you have finished adding or changing variables in the .env file, run ```make_tpl.sh```

```
./make_tpl.sh
```
Anytime you make changes to your .env file values, make sure to run the make_tpl.sh to recreate dynamic.yml and traefik.yml.

*Alternatively you can manually copy the templates to the ```config/traefik``` directory, and manually edit them so that the values are statically set.*  

Those files are read as is, when the container is started, and environment variables will not be parsed.

### Notes on .env Settings
The .env file should be self documenting. An important concept is that traefik includes an administration console which requires its own hostname that is separate from the ez-wireguard admin system. To secure the admin console, you utilize the ADMIN_USER_AUTH= variable.  The contents of this variable should be generated using the htpasswd program that is part of the apache web server. It is strongly recommended that you generate admin users using the bcrypt format.  

This is an example that generates a password for a user named 'admin'.  You will be prompted to enter the password twice.

```
htpasswd -nB admin
```
The hash provided should be copied into the .env file and enclosed in single quotes.  You must use _single quotes_ or the $ signs in the password will confuse the template process.

*Example: Variable set in the .env file.*
```
ADMIN_USER_AUTH='admin:$.y$..$yQA3XXXXXXXXXXXXXXXXX.....FZbb2'
```
Note that you do not have to use 'admin' as the user name you supply to htpasswd as the final parameter. Use any username that suits you, but make sure you provide a strong password.

## Ready to run? ##
```
docker compose up -d
```

## What to expect? ##
If everything works correctly, the containers will be created, the certs will be obtained, traefik will be reloaded and you should be able to connect to your wireguard administration using the https://your.domain (configured in your .env). It's important that you set up your wireguard immediately, as the first time you connect to the wireguard server you will be prompted to create an administration user and password.

While not specific to wireguard, keep in mind that user configuration and accounts you create will be stored inside the easy wireguard 

### Debugging Traefik issues ###
There are many potential configuration and environment problems that can occur with Traefik, particularly in regards to it retrieving certificates from lets encrypt. 

The ```config/traefik/acme.json``` file is updated by traefik with the letsencrypt credentials and certs retrieved.  Checking this file may help.  Keep in mind that fetching certificates may take a few minutes, and the file will be updated several times during this process.  Traefik will be dynamically updated.

If you are having trouble determining what is going wrong, it is often helpful to set ```LOG_LEVEL=debug``` in the .env file. Stop the containers and change the level, but remember to run ```./make_tpl.sh```

### Questions or comments?
Feel free to add a github issue.

## License ##
See the LICENSE File