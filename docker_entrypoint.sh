#!/bin/sh
set -e

echo "=== Evolu Relay Starting ==="
echo "Fixing data directory permissions..."

# Fix ownership of data directory (mounted by Start9 as root)
chown -R evolu:nodejs /app/data

echo "Starting server as evolu user..."

# Switch to evolu user and start the server
exec su-exec evolu node /app/dist/index.js
