# Caddy + Cloudflare DNS plugin, rebuilt weekly so Go, Alpine and the plugin stay current.

# Builder: newest Go 1.x toolchain (not tied to Caddy's release cadence)
FROM golang:1-alpine AS builder
ENV CGO_ENABLED=0
RUN apk add --no-cache git && \
    go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest
# Optional: pin a Caddy version via build-arg, otherwise xcaddy uses the latest release
ARG CADDY_VERSION=latest
RUN xcaddy build ${CADDY_VERSION} \
      --with github.com/caddy-dns/cloudflare \
      --output /usr/bin/caddy

# Runtime: official Caddy image (same paths/volumes as slothcroissant), patched to current Alpine
FROM caddy:2-alpine
RUN apk upgrade --no-cache
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN caddy version && caddy list-modules | grep -q dns.providers.cloudflare
