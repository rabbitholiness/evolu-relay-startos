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

After installation, find your Tor address in the service details. Configure your Evolu app to use:

```
ws://<your-onion-address>:4000
```

### SatsFlow Configuration

Set the environment variable before building:

```bash
VITE_EVOLU_RELAY_URL="ws://<your-onion-address>:4000" npm run tauri build
```

SatsFlow will use your self-hosted relay as primary, with the free relay as backup.

## Technical Details

- **Port:** 4000 (WebSocket)
- **Package:** `@evolu/server` from npm
- **Data:** Stored in `/app/data`, included in backups
- **Privacy:** All data is encrypted client-side; relay only sees opaque blobs

## License

MIT License - see [LICENSE](LICENSE)

## Related

- [Evolu](https://evolu.dev) - Local-first database library
- [SatsFlow](https://github.com/rabbitholiness/satsflow) - Bitcoin accounting app using Evolu
- [StartOS](https://start9.com) - Sovereign computing platform
