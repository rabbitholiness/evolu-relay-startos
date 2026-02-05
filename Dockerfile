# Use the official Evolu relay image
FROM evoluhq/relay:latest

USER root

# Install netcat for health checks
RUN apk add --no-cache netcat-openbsd

# Ensure data directory exists with correct permissions
RUN mkdir -p /app/data && chown -R evolu:nodejs /app/data

# Copy scripts
COPY docker_entrypoint.sh /app/
COPY health-check.sh /app/
RUN chmod +x /app/docker_entrypoint.sh /app/health-check.sh && \
    chown evolu:nodejs /app/docker_entrypoint.sh /app/health-check.sh

USER evolu

WORKDIR /app

EXPOSE 4000

ENTRYPOINT ["/app/docker_entrypoint.sh"]
