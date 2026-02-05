#!/bin/sh

# Check if WebSocket port is listening
if nc -z localhost 4000 2>/dev/null; then
  echo '{"result": {"status": "running"}}'
  exit 0
else
  echo '{"result": {"status": "stopped"}}'
  exit 1
fi
