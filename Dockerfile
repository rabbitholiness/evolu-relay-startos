FROM node:20-alpine

WORKDIR /app

# Install evolu relay from npm
RUN npm install -g @evolu/server

# Create data directory
RUN mkdir -p /app/data

# Copy scripts
COPY docker_entrypoint.sh /app/
COPY scripts/health.sh /app/
RUN chmod +x /app/*.sh

EXPOSE 4000

ENTRYPOINT ["/app/docker_entrypoint.sh"]
