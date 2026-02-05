# Evolu Relay

## What is Evolu Relay?

Evolu Relay is a self-hosted sync server for applications built with Evolu,
a local-first database library. All data synced through this relay is
end-to-end encrypted - the relay only sees opaque blobs and cannot read
your data.

## Connection URL

### Tor (Recommended)
Use the `.onion` address shown in your service details:
```
ws://<your-onion-address>:4000
```

### LAN (Local Network Only)
Use your Start9 server's local address:
```
wss://<your-start9-local>:4000
```

## Configuring SatsFlow

In SatsFlow's relay configuration, add your Evolu Relay URL as the primary
relay, with the free relay as backup:

```typescript
transports: [
  { type: "WebSocket", url: "ws://<your-onion-address>:4000" },
  { type: "WebSocket", url: "wss://free.evoluhq.com" },
],
```

Or set the environment variable before building:
```bash
VITE_EVOLU_RELAY_URL="ws://<your-onion-address>:4000" npm run tauri build
```

## Data Storage

All relay data is stored in `/app/data` and will be included in backups.
The relay stores encrypted sync blobs - it cannot read your actual data.

## Privacy

- All data is encrypted client-side before reaching the relay
- The relay only sees encrypted blobs
- No logs of user activity are kept
- Running on your own hardware gives you complete control
