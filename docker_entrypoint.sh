#!/bin/sh
set -e

cd /app/data

# Start Evolu relay
exec npx @evolu/server --port 4000
