#!/bin/sh
# Check if port 4000 is listening
if nc -z localhost 4000 2>/dev/null; then
    echo '{"result":null}'
    exit 0
else
    echo '{"error":"Evolu Relay is not responding on port 4000"}'
    exit 0
fi
