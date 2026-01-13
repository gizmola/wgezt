log:
    level: ${LOG_LEVEL}
entryPoints:
    web:
        address: ':80/tcp'
        http:
            redirections:
                entryPoint:
                    to: websecure
                    scheme: https
    websecure:
        address: ':443/tcp'
        http:
            middlewares:
                - compress@file
                - hsts@file
            tls:
                certResolver: myResolver
        http3: {}
api:
    dashboard: true

certificatesResolvers:
    myResolver:
        acme:
            email: ${LE_EMAIL}
            storage: acme.json
            dnsChallenge:
                provider: ${DNS_PROVIDER}
                propagation:
                    delayBeforeChecks: "30s"
providers:
    docker:
        watch: true
        network: traefik
        exposedByDefault: false
    file:
        filename: traefik_dynamic.yml
serversTransport:
    insecureSkipVerify: true