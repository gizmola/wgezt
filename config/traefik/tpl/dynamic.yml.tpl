http:
    middlewares:
        services:
            basicAuth:
                users:
                    - '${ADMIN_USER_AUTH}'
        compress:
            compress: {}
        hsts:
            headers:
                stsSeconds: 2592000
    routers:
        api:
            rule: Host(`${TRAEFIK_HOST_URL}`)
            entrypoints:
                - websecure
            middlewares:
                - services
            service: api@internal
tls:
    options:
        default:
            cipherSuites:
                - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
                - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
                - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
            sniStrict: true