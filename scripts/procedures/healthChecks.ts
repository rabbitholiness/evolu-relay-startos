import { types as T, ok, error, errorCode } from '../deps.ts';

// Local guard that uses Promise-based pattern (like working Syncthing package)
const guardDurationAboveMinimum = (input: {
  duration: number;
  minimumTime: number;
}) =>
  input.duration <= input.minimumTime
    ? Promise.reject(errorCode(60, "Starting"))
    : Promise.resolve(null);

export const health: T.ExpectedExports.health = {
  async 'web-ui'(effects, lastCall) {
    // Give the relay 10 seconds to start
    try {
      await guardDurationAboveMinimum({
        duration: lastCall,
        minimumTime: 10_000,
      });
    } catch (e) {
      return e;
    }

    try {
      // Try to connect to the relay
      // Even if it's a WebSocket server, attempting HTTP will tell us if it's listening
      await effects.fetch('http://evolu-relay.embassy:4000');
      // Any response (even error) means the server is running
      return ok;
    } catch (e) {
      const errorMsg = String(e);

      // Connection refused = server not running yet
      if (errorMsg.includes('ECONNREFUSED') || errorMsg.includes('connection refused')) {
        return error('Evolu Relay is not responding');
      }

      // Other errors (like WebSocket upgrade required) mean the server IS running
      // This is expected for a WebSocket-only server
      return ok;
    }
  },
};
