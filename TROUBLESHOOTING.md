# Troubleshooting Guide

## Common Issues

### Service Stuck in "Starting" State

**Symptoms:**
- Service alternates between "Starting" and "Running" every ~0.5 seconds
- Health check never passes

**Cause:** SQLite database permission error. StartOS mounts volumes with `root:root` ownership, but the Evolu relay runs as the `evolu` user.

**Solution (implemented in v0.3.5.7):**
1. Container starts as root
2. Entrypoint runs `chown -R evolu:nodejs /app/data` to fix permissions
3. Uses `su-exec evolu` to drop privileges before starting the server

**Logs showing this issue:**
```
Error: SQLITE_CANTOPEN: unable to open database file
```

### Health Check Failures

**Symptoms:**
- Service running but health check shows failing
- No "Evolu Relay is ready" message

**Verification:**
```bash
# From your Mac (same network)
curl -k "https://<your-relay>.local:4000/"

# Should connect. For WebSocket test:
curl -v -k \
  -H "Upgrade: websocket" \
  -H "Connection: Upgrade" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  -H "Sec-WebSocket-Version: 13" \
  "https://<your-relay>.local:4000/"

# Should return: HTTP/1.1 101 Switching Protocols
```

### Tor Address Not Working (from Tauri/Native App)

**Symptoms:**
```
WebSocket connection to 'ws://...onion:4000/' failed:
The Internet connection appears to be offline.
```

**Cause:** Native apps (Tauri, Electron) cannot connect to `.onion` addresses directly. They require a Tor proxy.

**Solutions:**
1. **LAN access** (same network): Use `wss://<relay>.local:4000`
2. **Remote access**: Requires Tor proxy integration (see Tor Implementation section)
3. **VPN**: Use Tailscale/WireGuard to access LAN remotely

### ProtocolQuotaError

**Symptoms:**
```
[Sync Debug] Evolu error: {type: "ProtocolQuotaError", ownerId: "..."}
```

**Cause:** Free relay storage quota exceeded.

**Solution:** Use self-hosted relay as primary (which has no quota limits).

---

## Verifying the Relay Works

### 1. Check App Logs

Look for successful connection:
```
[sync] "createWebSocket" – {url: "wss://...local:4000"}
[sync] "onOpen" – {transportKey: "WebSocket:wss://...local:4000", ...}
[sync] "send" – {message: Uint8Array}
[sync] "onMessage" – {transportKey: "WebSocket:wss://...local:4000", ...}
```

### 2. Check Database File on Start9

SSH into Start9:
```bash
ssh start9@<your-server>.local
ls -la /embassy-data/package-data/volumes/evolu-relay/data/main/
```

Should show `evolu-relay.db` with recent timestamp and non-zero size:
```
-rw-r--r-- 1 kiosk start9 2314240 Feb  5 20:30 evolu-relay.db
```

### 3. Test WebSocket Endpoint

```bash
# From any machine on the same network
curl -v -k \
  -H "Upgrade: websocket" \
  -H "Connection: Upgrade" \
  -H "Sec-WebSocket-Key: test" \
  -H "Sec-WebSocket-Version: 13" \
  "https://<your-relay>.local:4000/"
```

Success response:
```
< HTTP/1.1 101 Switching Protocols
< Upgrade: websocket
< Connection: Upgrade
< Sec-WebSocket-Accept: ...
```

---

## Architecture Notes

### Volume Permissions

StartOS mounts the `/app/data` volume with `root:root` ownership. The Evolu relay (using better-sqlite3) needs write access as the `evolu` user.

**Pattern used:**
```dockerfile
# Dockerfile
USER root
RUN apk add --no-cache su-exec
```

```bash
# docker_entrypoint.sh
chown -R evolu:nodejs /app/data
exec su-exec evolu node /app/dist/index.js
```

### Health Check

Uses netcat to check if port 4000 is listening:
```bash
if nc -z localhost 4000 2>/dev/null; then
    echo '{"result":null}'
else
    echo '{"error":"Evolu Relay is not responding on port 4000"}'
fi
```

The health check runs as a Docker container with `inject: true`, sharing the network namespace with the main container.

### Network Access

| Method | URL Format | Requirements |
|--------|-----------|--------------|
| LAN | `wss://<relay>.local:4000` | Same network |
| Tor | `ws://<onion>:4000` | Tor proxy |
| VPN | `wss://<relay>.local:4000` | Tailscale/WireGuard |

---

## SSH Access to Start9

1. Generate SSH key (if needed):
   ```bash
   ssh-keygen -t ed25519
   cat ~/.ssh/id_ed25519.pub
   ```

2. Add key in StartOS: **System → SSH → Add SSH Key**

3. Connect:
   ```bash
   ssh start9@<your-server>.local
   # or
   ssh start9@192.168.x.x
   ```

---

## Logs Location

- **Start9 UI:** Service → Evolu Relay → Logs
- **SSH:**
  ```bash
  # Container logs vary by StartOS version
  # Data directory:
  /embassy-data/package-data/volumes/evolu-relay/data/main/
  ```
