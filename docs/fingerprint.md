# Fingerprint System

Lightpanda browser implements a comprehensive fingerprinting system to emulate real browser behavior and avoid detection.

## Overview

The fingerprint system operates at two levels:

1. **Browser API Level** - JavaScript APIs return configurable values (Navigator, Screen, Canvas, WebGL, Audio)
2. **Network Level** - TLS/HTTP2 fingerprinting via curl-impersonate (optional)

## Fingerprint Profiles

### Available Profiles

Pre-configured profiles are available in the `examples/` directory:

| Profile | Chrome Version | Platform |
|---------|---------------|----------|
| `fingerprint-chrome131-macos.json` | 131 | macOS (Apple Silicon) |
| `fingerprint-chrome131-windows.json` | 131 | Windows 10 |
| `fingerprint-chrome131-linux.json` | 131 | Linux x86_64 |
| `fingerprint-chrome132-macos.json` | 132 | macOS (Apple Silicon) |
| `fingerprint-chrome132-windows.json` | 132 | Windows 10 |
| `fingerprint-chrome132-linux.json` | 132 | Linux x86_64 |
| `fingerprint-macos-chrome124.json` | 124 | macOS (Legacy) |
| `fingerprint-windows-chrome124.json` | 124 | Windows (Legacy) |

### Using a Profile

```bash
# Use a specific fingerprint profile
./lightpanda --fingerprint_profile examples/fingerprint-chrome131-macos.json serve

# Default profile (macOS Chrome 124) is used if not specified
./lightpanda serve
```

### Profile Structure

```json
{
  "chromeVersion": "131.0.0.0",
  "userAgent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) ...",
  "userAgentData": {
    "brands": [...],
    "platform": "macOS",
    "platformVersion": "15.0.0",
    "architecture": "arm",
    "mobile": false
  },
  "platform": "MacIntel",
  "languages": ["en-US", "en"],
  "language": "en-US",
  "timezone": "America/Los_Angeles",
  "screen": {
    "width": 2560,
    "height": 1440,
    "availWidth": 2560,
    "availHeight": 1415,
    "colorDepth": 30,
    "pixelDepth": 30
  },
  "window": {
    "innerWidth": 2560,
    "innerHeight": 1329,
    "outerWidth": 2560,
    "outerHeight": 1415,
    "screenX": 0,
    "screenY": 25,
    "devicePixelRatio": 2.0
  },
  "hardwareConcurrency": 10,
  "maxTouchPoints": 0,
  "deviceMemory": 8,
  "vendor": "Google Inc.",
  "product": "Gecko",
  "media": {
    "audioCodecs": ["audio/mpeg", ...],
    "videoCodecs": ["video/mp4; codecs=\"avc1.42E01E\"", ...]
  },
  "webgl": {
    "vendor": "Google Inc. (Apple)",
    "renderer": "ANGLE (Apple, ANGLE Metal Renderer: Apple M1 Pro, ...)"
  },
  "canvas": {
    "mode": "stable",
    "seed": "chrome131-macos-default"
  },
  "audio": {
    "mode": "stable", 
    "seed": "chrome131-macos-default"
  },
  "connection": {
    "effectiveType": "4g",
    "downlink": 10.0,
    "rtt": 50,
    "saveData": false
  },
  "tls": {
    "impersonateTarget": "chrome131"
  }
}
```

## Fingerprint Surfaces

### Navigator API
- `navigator.userAgent` - Full user agent string
- `navigator.userAgentData` - Structured UA data (brands, platform, etc.)
- `navigator.platform` - Platform identifier
- `navigator.hardwareConcurrency` - CPU core count
- `navigator.deviceMemory` - RAM in GB
- `navigator.maxTouchPoints` - Touch capability
- `navigator.vendor` / `navigator.product` - Browser vendor info
- `navigator.webdriver` - Always returns `false`
- `navigator.connection` - Network information (effectiveType, downlink, rtt)

### Screen API
- `screen.width` / `screen.height` - Screen dimensions
- `screen.availWidth` / `screen.availHeight` - Available dimensions
- `screen.colorDepth` / `screen.pixelDepth` - Color depth

### Window API
- `window.innerWidth` / `window.innerHeight` - Viewport size
- `window.outerWidth` / `window.outerHeight` - Window size
- `window.screenX` / `window.screenY` - Window position
- `window.devicePixelRatio` - Pixel density

### Canvas Fingerprinting
- `canvas.toDataURL()` generates deterministic output based on seed
- Mode `stable`: Consistent fingerprint per seed
- Mode `noise`: Adds slight variation (not yet implemented)

### WebGL Fingerprinting
- `UNMASKED_VENDOR_WEBGL` - Returns profile's WebGL vendor
- `UNMASKED_RENDERER_WEBGL` - Returns profile's WebGL renderer
- `WEBGL_debug_renderer_info` extension enabled

### Audio Fingerprinting
- `OfflineAudioContext.startRendering()` - Deterministic audio buffer
- `AudioBuffer.getChannelData()` - Seed-based pseudo-random samples

## TLS Fingerprinting (curl-impersonate)

For complete fingerprint emulation, including TLS/HTTP2 fingerprinting, you can optionally build with curl-impersonate.

### Building with curl-impersonate

```bash
# 1. Initialize submodule
git submodule update --init vendor/curl-impersonate

# 2. Build curl-impersonate (requires Go, cmake, autoconf)
./scripts/build-curl-impersonate.sh

# 3. Enable in Http.zig
# Set ENABLE_IMPERSONATE = true in src/http/Http.zig

# 4. Rebuild Lightpanda with libcurl-impersonate
# (requires modifying build.zig to link curl-impersonate)
```

### TLS Impersonate Targets

The `tls.impersonateTarget` field supports:
- Chrome: `chrome131`, `chrome124`, `chrome116`, `chrome99`
- Firefox: `ff117`, `ff109`, `ff102`
- Safari: `safari15_5`, `safari15_3`

**Important**: The `tls.impersonateTarget` should match the `chromeVersion` for consistency.

## CDP API

Fingerprint profiles can be changed at runtime via Chrome DevTools Protocol:

```javascript
// Set global fingerprint profile
await client.send('Fingerprint.setProfile', { profile: {...} });

// Set per-page fingerprint override
await client.send('Fingerprint.setProfileForPage', { 
  targetId: 'page-id',
  profile: {...} 
});

// Clear per-page override
await client.send('Fingerprint.clearProfileForPage', { 
  targetId: 'page-id' 
});
```

## Creating Custom Profiles

1. Copy an existing profile as a template
2. Modify values to match your target browser/platform
3. Ensure consistency between related fields:
   - `chromeVersion` ↔ `userAgent` ↔ `userAgentData.brands` ↔ `tls.impersonateTarget`
   - `platform` ↔ `userAgentData.platform`
   - `screen` dimensions ↔ `window` dimensions

## Anti-Detection Tips

1. **Consistency**: All fingerprint values should be internally consistent
2. **Realistic values**: Use values from real browser configurations
3. **Canvas/Audio seeds**: Use unique seeds per identity to avoid correlation
4. **TLS fingerprinting**: Enable curl-impersonate for complete network-level emulation
