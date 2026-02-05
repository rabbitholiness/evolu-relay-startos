# Evolu Relay for StartOS

Self-hosted sync relay for [Evolu](https://evolu.dev) local-first applications, packaged for [Start9](https://start9.com) servers.

## What is Evolu Relay?

Evolu is a local-first database library that enables end-to-end encrypted sync across devices. The relay server stores only encrypted blobs - it cannot read your data.

This package runs the Evolu relay on your Start9 server, giving you:
- **Complete data sovereignty** - relay runs on your hardware
- **Tor-native access** - no domain names or SSL certificates needed
- **Automatic backups** - via StartOS backup system
- **Hybrid failover** - use with free relay as backup

## Installation

### Sideload (Recommended)

1. Download the latest `.s9pk` from [Releases](https://github.com/rabbitholiness/evolu-relay-startos/releases)
2. Go to StartOS → System → Sideload Service
3. Upload the `.s9pk` file
4. Start the service

### Build from Source

Requires the [Start9 SDK](https://docs.start9.com/latest/developer-docs/specification/start-sdk/):

```bash
git clone https://github.com/rabbitholiness/evolu-relay-startos
cd evolu-relay-startos
make
```

## Usage

After installation, find your connection URLs in the service Interfaces:

### LAN Access (Same Network)

Use the `.local` address with secure WebSocket:
```
wss://<your-relay>.local:4000
```

Best for: Desktop apps on the same network as your Start9.

### Tor Access (Remote/Mobile)

Use the `.onion` address:
```
ws://<your-onion-address>:4000
```

**Note:** Native apps (Tauri, Electron) cannot connect to `.onion` directly - they require a Tor proxy. See [Troubleshooting](TROUBLESHOOTING.md) for details.

### SatsFlow Configuration

**Option 1: In-App Settings (Recommended)**

1. Go to **Settings → FlowSync → Configure Relay**
2. Enter your relay URL (LAN or Tor)
3. Click **Save & Restart**

The free relay (`wss://free.evoluhq.com`) is always used as backup.

**Option 2: Environment Variable**

```bash
VITE_EVOLU_RELAY_URL="wss://<your-relay>.local:4000" npm run tauri dev
```

## Verifying It Works

1. **Check SatsFlow logs** for `[sync] "onOpen"` messages to your relay
2. **Check database file** on Start9:
   ```bash
   ssh start9@<your-server>.local
   ls -la /embassy-data/package-data/volumes/evolu-relay/data/main/
   # Should show evolu-relay.db with recent timestamp
   ```

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for detailed verification steps.

## Technical Details

- **Port:** 4000 (WebSocket)
- **Base Image:** `evoluhq/relay:latest`
- **Data:** SQLite database in `/app/data`, included in backups
- **Privacy:** All data is encrypted client-side; relay only sees opaque blobs
- **Architectures:** x86_64, aarch64

### Key Files

| File | Purpose |
|------|---------|
| `docker_entrypoint.sh` | Fixes volume permissions, starts server |
| `health-check.sh` | Netcat-based port check |
| `manifest.yaml` | StartOS service definition |

## Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for common issues including:
- Service stuck in "Starting" state (permission fix)
- Health check failures
- Tor address not working from native apps
- How to verify sync is working

## License

MIT License - see [LICENSE](LICENSE)

## Related

- [Evolu](https://evolu.dev) - Local-first database library
- [SatsFlow](https://github.com/rabbitholiness/satsflow) - Bitcoin accounting app using Evolu
- [StartOS](https://start9.com) - Sovereign computing platform
