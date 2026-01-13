services:
  traefik:
    environment:
        # Environment variables for DNS provider - Place credentials in .env file.
        # This example utilizes implements AWS Route 53
      - AWS_ACCESS_KEY_ID
      - AWS_SECRET_ACCESS_KEY
      - AWS_REGION
      - AWS_HOSTED_ZONE_ID