#!/usr/bin/env bash
set -a && source .env && set +a
envsubst < ./config/traefik/tpl/traefik.yml.tpl > ./config/traefik/traefik.yml
envsubst < ./config/traefik/tpl/dynamic.yml.tpl > ./config/traefik/dynamic.yml