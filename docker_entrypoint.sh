#!/bin/sh
set -e

cd /app

# Start the Evolu relay server
exec node dist/index.js
