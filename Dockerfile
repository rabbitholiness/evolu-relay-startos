# Use the official Evolu relay image
FROM evoluhq/relay:latest

USER root

# Install netcat for health checks and su-exec for dropping privileges
RUN apk add --no-cache netcat-openbsd su-exec

# Ensure data directory exists
RUN mkdir -p /app/data

# Copy scripts
COPY docker_entrypoint.sh /app/
COPY health-check.sh /app/
RUN chmod +x /app/docker_entrypoint.sh /app/health-check.sh

WORKDIR /app

EXPOSE 4000

# Run as root initially so entrypoint can fix permissions, then drop to evolu
ENTRYPOINT ["/app/docker_entrypoint.sh"]
