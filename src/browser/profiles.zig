// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

//! Browser Profiles
//!
//! Maps browser identifiers to complete fingerprint profiles including:
//! - Navigator properties (userAgent, platform, etc.)
//! - Screen/Window dimensions
//! - WebGL vendor/renderer
//! - Canvas/Audio fingerprint seeds
//! - TLS fingerprint target (curl-impersonate)
//!
//! Usage: `--browser chrome131-macos` or `--browser chrome132-windows`

const std = @import("std");
const App = @import("App.zig");
const FingerprintProfile = App.FingerprintProfile;

/// Supported browser profiles
pub const BrowserType = enum {
    // Chrome 131
    chrome131_macos,
    chrome131_windows,
    chrome131_linux,
    // Chrome 132
    chrome132_macos,
    chrome132_windows,
    chrome132_linux,
    // Chrome 124 (legacy)
    chrome124_macos,
    chrome124_windows,
    // Firefox (future)
    // firefox133_macos,
    // firefox133_windows,
    // firefox133_linux,

    pub fn fromString(s: []const u8) ?BrowserType {
        const map = std.StaticStringMap(BrowserType).initComptime(.{
            .{ "chrome131-macos", .chrome131_macos },
            .{ "chrome131-windows", .chrome131_windows },
            .{ "chrome131-linux", .chrome131_linux },
            .{ "chrome132-macos", .chrome132_macos },
            .{ "chrome132-windows", .chrome132_windows },
            .{ "chrome132-linux", .chrome132_linux },
            .{ "chrome124-macos", .chrome124_macos },
            .{ "chrome124-windows", .chrome124_windows },
            // Aliases
            .{ "chrome131", .chrome131_macos },
            .{ "chrome132", .chrome132_macos },
            .{ "chrome", .chrome131_macos },
        });
        return map.get(s);
    }

    pub fn toString(self: BrowserType) []const u8 {
        return switch (self) {
            .chrome131_macos => "chrome131-macos",
            .chrome131_windows => "chrome131-windows",
            .chrome131_linux => "chrome131-linux",
            .chrome132_macos => "chrome132-macos",
            .chrome132_windows => "chrome132-windows",
            .chrome132_linux => "chrome132-linux",
            .chrome124_macos => "chrome124-macos",
            .chrome124_windows => "chrome124-windows",
        };
    }
};

/// Get fingerprint profile for a browser type
pub fn getProfile(browser: BrowserType) FingerprintProfile {
    return switch (browser) {
        .chrome131_macos => chrome131MacOS(),
        .chrome131_windows => chrome131Windows(),
        .chrome131_linux => chrome131Linux(),
        .chrome132_macos => chrome132MacOS(),
        .chrome132_windows => chrome132Windows(),
        .chrome132_linux => chrome132Linux(),
        .chrome124_macos => FingerprintProfile.defaultMacOS(),
        .chrome124_windows => chrome124Windows(),
    };
}

/// Chrome 131 macOS (Apple Silicon)
/// Real fingerprint data based on Chrome 131 on macOS Sequoia
pub fn chrome131MacOS() FingerprintProfile {
    return .{
        .chromeVersion = "131.0.0.0",
        .userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        .userAgentData = .{
            .brands = &.{
                .{ .brand = "Google Chrome", .version = "131" },
                .{ .brand = "Chromium", .version = "131" },
                .{ .brand = "Not_A Brand", .version = "24" },
            },
            .fullVersionList = &.{
                .{ .brand = "Google Chrome", .version = "131.0.6778.86" },
                .{ .brand = "Chromium", .version = "131.0.6778.86" },
                .{ .brand = "Not_A Brand", .version = "24.0.0.0" },
            },
            .platform = "macOS",
            .platformVersion = "15.1.0",
            .architecture = "arm",
            .model = "",
            .mobile = false,
        },
        .platform = "MacIntel",
        .languages = &.{ "en-US", "en" },
        .language = "en-US",
        .timezone = "America/Los_Angeles",
        .screen = .{
            .width = 2560,
            .height = 1440,
            .availWidth = 2560,
            .availHeight = 1415,
            .colorDepth = 30,
            .pixelDepth = 30,
        },
        .window = .{
            .innerWidth = 2560,
            .innerHeight = 1329,
            .outerWidth = 2560,
            .outerHeight = 1415,
            .screenX = 0,
            .screenY = 25,
            .devicePixelRatio = 2.0,
        },
        .hardwareConcurrency = 10,
        .maxTouchPoints = 0,
        .deviceMemory = 8,
        .vendor = "Google Inc.",
        .product = "Gecko",
        .media = .{
            .audioCodecs = &.{
                "audio/mpeg",
                "audio/ogg; codecs=\"vorbis\"",
                "audio/ogg; codecs=\"opus\"",
                "audio/wav; codecs=\"1\"",
                "audio/webm; codecs=\"opus\"",
                "audio/webm; codecs=\"vorbis\"",
                "audio/flac",
                "audio/mp4; codecs=\"mp4a.40.2\"",
            },
            .videoCodecs = &.{
                "video/mp4; codecs=\"avc1.42E01E\"",
                "video/mp4; codecs=\"avc1.4D401E\"",
                "video/mp4; codecs=\"avc1.64001E\"",
                "video/mp4; codecs=\"hvc1.1.6.L93.B0\"",
                "video/webm; codecs=\"vp8\"",
                "video/webm; codecs=\"vp9\"",
                "video/webm; codecs=\"av01.0.01M.08\"",
            },
        },
        .webgl = .{
            .vendor = "Google Inc. (Apple)",
            .renderer = "ANGLE (Apple, ANGLE Metal Renderer: Apple M1 Pro, Unspecified Version)",
            .params = .null,
        },
        .canvas = .{
            .mode = .stable,
            .seed = "chrome131-macos-v1",
        },
        .audio = .{
            .mode = .stable,
            .seed = "chrome131-macos-v1",
        },
        .connection = .{
            .effectiveType = "4g",
            .downlink = 10.0,
            .rtt = 50,
            .saveData = false,
        },
        .tls = .{
            .impersonateTarget = "chrome131",
        },
    };
}

/// Chrome 131 Windows
pub fn chrome131Windows() FingerprintProfile {
    return .{
        .chromeVersion = "131.0.0.0",
        .userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        .userAgentData = .{
            .brands = &.{
                .{ .brand = "Google Chrome", .version = "131" },
                .{ .brand = "Chromium", .version = "131" },
                .{ .brand = "Not_A Brand", .version = "24" },
            },
            .fullVersionList = &.{
                .{ .brand = "Google Chrome", .version = "131.0.6778.86" },
                .{ .brand = "Chromium", .version = "131.0.6778.86" },
                .{ .brand = "Not_A Brand", .version = "24.0.0.0" },
            },
            .platform = "Windows",
            .platformVersion = "10.0.0",
            .architecture = "x86",
            .model = "",
            .mobile = false,
        },
        .platform = "Win32",
        .languages = &.{ "en-US", "en" },
        .language = "en-US",
        .timezone = "America/New_York",
        .screen = .{
            .width = 1920,
            .height = 1080,
            .availWidth = 1920,
            .availHeight = 1032,
            .colorDepth = 24,
            .pixelDepth = 24,
        },
        .window = .{
            .innerWidth = 1920,
            .innerHeight = 969,
            .outerWidth = 1936,
            .outerHeight = 1056,
            .screenX = 0,
            .screenY = 0,
            .devicePixelRatio = 1.0,
        },
        .hardwareConcurrency = 16,
        .maxTouchPoints = 0,
        .deviceMemory = 8,
        .vendor = "Google Inc.",
        .product = "Gecko",
        .media = .{
            .audioCodecs = &.{
                "audio/mpeg",
                "audio/ogg; codecs=\"vorbis\"",
                "audio/ogg; codecs=\"opus\"",
                "audio/wav; codecs=\"1\"",
                "audio/webm; codecs=\"opus\"",
                "audio/flac",
                "audio/mp4; codecs=\"mp4a.40.2\"",
            },
            .videoCodecs = &.{
                "video/mp4; codecs=\"avc1.42E01E\"",
                "video/mp4; codecs=\"avc1.4D401E\"",
                "video/mp4; codecs=\"avc1.64001E\"",
                "video/webm; codecs=\"vp8\"",
                "video/webm; codecs=\"vp9\"",
            },
        },
        .webgl = .{
            .vendor = "Google Inc. (NVIDIA)",
            .renderer = "ANGLE (NVIDIA, NVIDIA GeForce RTX 4080 Direct3D11 vs_5_0 ps_5_0, D3D11)",
            .params = .null,
        },
        .canvas = .{
            .mode = .stable,
            .seed = "chrome131-windows-v1",
        },
        .audio = .{
            .mode = .stable,
            .seed = "chrome131-windows-v1",
        },
        .connection = .{
            .effectiveType = "4g",
            .downlink = 10.0,
            .rtt = 50,
            .saveData = false,
        },
        .tls = .{
            .impersonateTarget = "chrome131",
        },
    };
}

/// Chrome 131 Linux
pub fn chrome131Linux() FingerprintProfile {
    return .{
        .chromeVersion = "131.0.0.0",
        .userAgent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
        .userAgentData = .{
            .brands = &.{
                .{ .brand = "Google Chrome", .version = "131" },
                .{ .brand = "Chromium", .version = "131" },
                .{ .brand = "Not_A Brand", .version = "24" },
            },
            .fullVersionList = &.{
                .{ .brand = "Google Chrome", .version = "131.0.6778.86" },
                .{ .brand = "Chromium", .version = "131.0.6778.86" },
                .{ .brand = "Not_A Brand", .version = "24.0.0.0" },
            },
            .platform = "Linux",
            .platformVersion = "6.5.0",
            .architecture = "x86",
            .model = "",
            .mobile = false,
        },
        .platform = "Linux x86_64",
        .languages = &.{ "en-US", "en" },
        .language = "en-US",
        .timezone = "America/Chicago",
        .screen = .{
            .width = 1920,
            .height = 1080,
            .availWidth = 1920,
            .availHeight = 1053,
            .colorDepth = 24,
            .pixelDepth = 24,
        },
        .window = .{
            .innerWidth = 1920,
            .innerHeight = 979,
            .outerWidth = 1920,
            .outerHeight = 1053,
            .screenX = 0,
            .screenY = 27,
            .devicePixelRatio = 1.0,
        },
        .hardwareConcurrency = 12,
        .maxTouchPoints = 0,
        .deviceMemory = 8,
        .vendor = "Google Inc.",
        .product = "Gecko",
        .media = .{
            .audioCodecs = &.{
                "audio/mpeg",
                "audio/ogg; codecs=\"vorbis\"",
                "audio/ogg; codecs=\"opus\"",
                "audio/wav; codecs=\"1\"",
                "audio/webm; codecs=\"opus\"",
                "audio/flac",
            },
            .videoCodecs = &.{
                "video/mp4; codecs=\"avc1.42E01E\"",
                "video/mp4; codecs=\"avc1.4D401E\"",
                "video/webm; codecs=\"vp8\"",
                "video/webm; codecs=\"vp9\"",
            },
        },
        .webgl = .{
            .vendor = "Google Inc. (AMD)",
            .renderer = "ANGLE (AMD, AMD Radeon RX 6800 XT (radeonsi, navi21, LLVM 15.0.7, DRM 3.54, 6.5.0-44-generic), OpenGL 4.6)",
            .params = .null,
        },
        .canvas = .{
            .mode = .stable,
            .seed = "chrome131-linux-v1",
        },
        .audio = .{
            .mode = .stable,
            .seed = "chrome131-linux-v1",
        },
        .connection = .{
            .effectiveType = "4g",
            .downlink = 10.0,
            .rtt = 50,
            .saveData = false,
        },
        .tls = .{
            .impersonateTarget = "chrome131",
        },
    };
}

/// Chrome 132 macOS
pub fn chrome132MacOS() FingerprintProfile {
    var profile = chrome131MacOS();
    profile.chromeVersion = "132.0.0.0";
    profile.userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36";
    profile.userAgentData = .{
        .brands = &.{
            .{ .brand = "Google Chrome", .version = "132" },
            .{ .brand = "Chromium", .version = "132" },
            .{ .brand = "Not_A Brand", .version = "24" },
        },
        .fullVersionList = &.{
            .{ .brand = "Google Chrome", .version = "132.0.6834.57" },
            .{ .brand = "Chromium", .version = "132.0.6834.57" },
            .{ .brand = "Not_A Brand", .version = "24.0.0.0" },
        },
        .platform = "macOS",
        .platformVersion = "15.2.0",
        .architecture = "arm",
        .model = "",
        .mobile = false,
    };
    profile.canvas.seed = "chrome132-macos-v1";
    profile.audio.seed = "chrome132-macos-v1";
    // Chrome 132 TLS fingerprint (use chrome131 as closest available in curl-impersonate)
    profile.tls.impersonateTarget = "chrome131";
    return profile;
}

/// Chrome 132 Windows
pub fn chrome132Windows() FingerprintProfile {
    var profile = chrome131Windows();
    profile.chromeVersion = "132.0.0.0";
    profile.userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36";
    profile.userAgentData = .{
        .brands = &.{
            .{ .brand = "Google Chrome", .version = "132" },
            .{ .brand = "Chromium", .version = "132" },
            .{ .brand = "Not_A Brand", .version = "24" },
        },
        .fullVersionList = &.{
            .{ .brand = "Google Chrome", .version = "132.0.6834.57" },
            .{ .brand = "Chromium", .version = "132.0.6834.57" },
            .{ .brand = "Not_A Brand", .version = "24.0.0.0" },
        },
        .platform = "Windows",
        .platformVersion = "10.0.0",
        .architecture = "x86",
        .model = "",
        .mobile = false,
    };
    profile.canvas.seed = "chrome132-windows-v1";
    profile.audio.seed = "chrome132-windows-v1";
    profile.tls.impersonateTarget = "chrome131";
    return profile;
}

/// Chrome 132 Linux
pub fn chrome132Linux() FingerprintProfile {
    var profile = chrome131Linux();
    profile.chromeVersion = "132.0.0.0";
    profile.userAgent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/132.0.0.0 Safari/537.36";
    profile.userAgentData = .{
        .brands = &.{
            .{ .brand = "Google Chrome", .version = "132" },
            .{ .brand = "Chromium", .version = "132" },
            .{ .brand = "Not_A Brand", .version = "24" },
        },
        .fullVersionList = &.{
            .{ .brand = "Google Chrome", .version = "132.0.6834.57" },
            .{ .brand = "Chromium", .version = "132.0.6834.57" },
            .{ .brand = "Not_A Brand", .version = "24.0.0.0" },
        },
        .platform = "Linux",
        .platformVersion = "6.6.0",
        .architecture = "x86",
        .model = "",
        .mobile = false,
    };
    profile.canvas.seed = "chrome132-linux-v1";
    profile.audio.seed = "chrome132-linux-v1";
    profile.tls.impersonateTarget = "chrome131";
    return profile;
}

/// Chrome 124 Windows (legacy)
pub fn chrome124Windows() FingerprintProfile {
    return .{
        .chromeVersion = "124.0.0.0",
        .userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
        .userAgentData = .{
            .brands = &.{
                .{ .brand = "Chromium", .version = "124" },
                .{ .brand = "Google Chrome", .version = "124" },
                .{ .brand = "Not_A Brand", .version = "99" },
            },
            .fullVersionList = &.{
                .{ .brand = "Chromium", .version = "124.0.0.0" },
                .{ .brand = "Google Chrome", .version = "124.0.0.0" },
                .{ .brand = "Not_A Brand", .version = "99.0.0.0" },
            },
            .platform = "Windows",
            .platformVersion = "10.0.0",
            .architecture = "x86",
            .model = "",
            .mobile = false,
        },
        .platform = "Win32",
        .languages = &.{ "en-US", "en" },
        .language = "en-US",
        .timezone = "America/New_York",
        .screen = .{
            .width = 1920,
            .height = 1080,
            .availWidth = 1920,
            .availHeight = 1040,
            .colorDepth = 24,
            .pixelDepth = 24,
        },
        .window = .{
            .innerWidth = 1920,
            .innerHeight = 969,
            .outerWidth = 1936,
            .outerHeight = 1056,
            .screenX = 0,
            .screenY = 0,
            .devicePixelRatio = 1.0,
        },
        .hardwareConcurrency = 8,
        .maxTouchPoints = 0,
        .deviceMemory = 8,
        .vendor = "Google Inc.",
        .product = "Gecko",
        .media = .{
            .audioCodecs = &.{
                "audio/mpeg",
                "audio/ogg; codecs=\"vorbis\"",
                "audio/wav; codecs=\"1\"",
            },
            .videoCodecs = &.{
                "video/mp4; codecs=\"avc1.42E01E\"",
                "video/webm; codecs=\"vp8\"",
            },
        },
        .webgl = .{
            .vendor = "Google Inc. (NVIDIA)",
            .renderer = "ANGLE (NVIDIA, NVIDIA GeForce RTX 3080 Direct3D11 vs_5_0 ps_5_0, D3D11)",
            .params = .null,
        },
        .canvas = .{
            .mode = .stable,
            .seed = "chrome124-windows-v1",
        },
        .audio = .{
            .mode = .stable,
            .seed = "chrome124-windows-v1",
        },
        .connection = .{
            .effectiveType = "4g",
            .downlink = 10.0,
            .rtt = 50,
            .saveData = false,
        },
        .tls = .{
            .impersonateTarget = "chrome124",
        },
    };
}

/// List all available browser profiles
pub fn listProfiles() void {
    const profiles = [_][]const u8{
        "chrome131-macos   - Chrome 131 on macOS (Apple Silicon)",
        "chrome131-windows - Chrome 131 on Windows 10",
        "chrome131-linux   - Chrome 131 on Linux x86_64",
        "chrome132-macos   - Chrome 132 on macOS (Apple Silicon)",
        "chrome132-windows - Chrome 132 on Windows 10",
        "chrome132-linux   - Chrome 132 on Linux x86_64",
        "chrome124-macos   - Chrome 124 on macOS (legacy)",
        "chrome124-windows - Chrome 124 on Windows (legacy)",
        "",
        "Aliases:",
        "  chrome131 -> chrome131-macos",
        "  chrome132 -> chrome132-macos",
        "  chrome    -> chrome131-macos (latest)",
    };
    for (profiles) |p| {
        std.debug.print("{s}\n", .{p});
    }
}
