<p align="center">
    <img src="docs/assets/img/traefik-checkmk.png" width="600" />
</p>

# Docker Compose CheckMk - Traefik

> Proxy Container Service (Cloudflare)

This guide shows you how to deploy `CheckMK` behind `Traefik` reverse-proxy. It will obtain and refresh `HTTPS` & `CHECK AGENT` certificates automatically and it comes with password-protected Traefik dashboard.

## Docker container

### Main container and version

-   CheckMk Raw: 2.3.0-latest
-   Docker Socket Proxy: 1.26.2/latest
-   Traefik: 2.11.x or 3.1.x
-   Logger Alpine Linux: 3.19 or 3.20

### Docker service documentation

-   CheckMk [Document](https://checkmk.com/)
-   Docker Socket Proxy (security) - `Linuxserver.io` [Document](https://hub.docker.com/r/linuxserver/socket-proxy)
-   Traefik [Document](https://hub.docker.com/_/traefik)
-   Logger (logrotate & cron) `Custom for Alpine`

### Step 1: Make Sure You Have Required Dependencies

-   Git
-   Docker
-   Docker Compose

#### Example Installation on Debian-based Systems:

Official documentation for install Docker with new Docker Compose V2 [doc](https://docs.docker.com/engine/install/), and you can install too Docker Compose V1. Follow official documentation.

```bash
sudo apt get install git docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

### Step 2: Clone the Repository

```bash
git clone https://github.com/asapdotid/dcc-checkmk-traefik.git
cd dcc-checkmk-traefik
```

Make command help:

```bash
make help
```

### Step 3: Make Initial Environment Variables

```bash
make init
```

Modified file in `.make/.env` for build image

```ini
...
# Project variables
DOCKER_REGISTRY=docker.io
DOCKER_NAMESPACE=asapdotid
DOCKER_PROJECT_NAME=monitoring

# Docker image version
SOCKET_PROXY_VERSION=1.26.2
TRAEFIK_VERSION=3.1
ALPINE_VERSION=3.20
CHECKMK_VERSION=2.3.0-latest

# Timezone for os and log level
TIMEZONE=Asia/Jakarta
```

### Step 3: Make Docker Compose Initial Environment Variables

```bash
make env
```

Modified file in `src/.env` for build image

#### Checkmk environments

```bash
...

## CHECKMK
CHECKMK_USER_ID=1000
CHECKMK_GROUP_ID=1000
CHECKMK_SITE_ID=cmk
CHECKMK_ADMIN_PASSWORD=JYg0ZDYu23451
CHECKMK_DOMAIN_NAME=cmk.domain_name.com
```

Checkmk login using exiting config, you should change `site id`, `cmkadmin password` and `domain/subdomain`

```ini
username: cmkadmin
password: JYg0ZDYu23451
```

#### Traefik environments

The password is `adminpass` and you might want to change it before deploying to production.

##### Deploying on a Public Server With Real Domain

Traefik requires you to define "Certificate Resolvers" in the static configuration, which are responsible for retrieving certificates from an ACME server.

Then, each "router" is configured to enable TLS, and is associated to a certificate resolver through the tls.certresolver configuration option.

Read [Traefik Let's Encrypt](https://doc.traefik.io/traefik/https/acme/)

Here is a list of supported providers, on this project:

-   Cloudflare

Let's say you have a domain `example.com` and it's DNS records point to your production server. Just repeat the local deployment steps, but don't forget to update `TRAEFIK_DOMAIN_NAME`, `TRAEFIK_ACME_DNS_CHALLENGE_PROVIDER_EMAIL` & `TRAEFIK_ACME_DNS_CHALLENGE_PROVIDER_TOKEN` environment variables. In case of `example.com`, your `src/.env` file should have the following lines:

```ini
TRAEFIK_DOMAIN_NAME=example.com
TRAEFIK_ACME_DNS_CHALLENGE_PROVIDER_EMAIL=email@mail.com
TRAEFIK_ACME_DNS_CHALLENGE_PROVIDER_TOKEN=coudflare-access-token-123ABC
```

Setting correct email is important because it allows Let’s Encrypt to contact you in case there are any present and future issues with your certificates.

## Redirect `WWW` to `NON WWW`

Example labels redirect www to npn www:

```yaml
labels:
    - traefik.enable=true
    - traefik.http.routers.whoami.entrypoints=https
    - traefik.http.routers.whoami.rule=Host(`jogjascript.com`)||Host(`www.jogjascript.com`)
    # Add redirect middlewares for http and https
    - traefik.http.routers.whoami.middlewares=redirect-http-www@file,redirect-https-www@file
```

### Step 4: Set Your Own Password

Note: when used in docker-compose.yml all dollar signs in the hash need to be doubled for escaping.

> Install `Apache Tools` package to using `htpasswd`
> To create a `user`:`password` pair, the following command can be used:

```bash
echo $(htpasswd -nb user)

# OR

echo $(htpasswd -nb user password)
```

Running script:

```bash
echo $(htpasswd -nb admin)

New password:
Re-type new password:

admin:$apr1$W3jHMbEG$TCzyOICAWv/6kkraCHKYC0
```

or

```bash
echo $(htpasswd -nb admin adminpass)

admin:$apr1$W3jHMbEG$TCzyOICAWv/6kkraCHKYC0
```

The output has the following format: `username`:`password_hash`. The username doesn't have to be `admin`, feel free to change it (in the first line).

Encode password hash with `base64`:

```bash
echo '$apr1$W3jHMbEG$TCzyOICAWv/6kkraCHKYC0' | openssl enc -e -base64
JGFwcjEkVzNqSE1iRUckVEN6eU9JQ0FXdi82a2tyYUNIS1lDMAo=
```

Check decode:

```bash
echo 'JGFwcjEkVzNqSE1iRUckVEN6eU9JQ0FXdi82a2tyYUNIS1lDMAo=' | openssl enc -d -base64
```

You can paste the username into the `TRAEFIK_BASIC_AUTH_USERNAME` environment variable. The other part, `hashedPassword`, should be assigned to `TRAEFIK_BASIC_AUTH_PASSWORD_HASH`. Now you have your own `username`:`password` pair.

### Step 5: Launch Your Deployment

Optional create docker network `secure` & `proxy` for external used with other docker containers:

```bash
docker network create secure
```

and

```bash
docker network create proxy
```

```bash
make env

make build
```

Docker composer make commands:

```bash
make up
# or
make down
```

### Step 6: Pointing CLoudflare DNS Record to your IP Server/VM

```bash
curl -I https://{domain_name.com}/
```

#### Checkmk access

-   Checkmk Dashboard: `https://cmk.{domain_name.com}/`
-   Checkmk Agent (9443 => 8000): `https://cmk.{domain_name.com:9443}/`

#### Traefik access

-   Traefik Dashboard: `https://monitor.{domain_name.com}/`

## License

MIT / BSD

## Author Information

©️2024 by [Asapdotid](https://github.com/asapdotid) 🚀
