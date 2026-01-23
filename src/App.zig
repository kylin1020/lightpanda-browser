// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// Francis Bouvier <francis@lightpanda.io>
// Pierre Tachoire <pierre@lightpanda.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");

const Allocator = std.mem.Allocator;

const log = @import("log.zig");
const Http = @import("http/Http.zig");
const Snapshot = @import("browser/js/Snapshot.zig");
const Platform = @import("browser/js/Platform.zig");
const json = std.json;

const Notification = @import("Notification.zig");
const Telemetry = @import("telemetry/telemetry.zig").Telemetry;

// Container for global state / objects that various parts of the system
// might need.
const App = @This();

http: Http,
config: Config,
platform: Platform,
snapshot: Snapshot,
telemetry: Telemetry,
allocator: Allocator,
app_dir_path: ?[]const u8,
notification: *Notification,
shutdown: bool = false,

pub const RunMode = enum {
    help,
    fetch,
    serve,
    version,
};

pub const FingerprintProfile = struct {
    chromeVersion: []const u8,
    userAgent: []const u8,
    userAgentData: UserAgentData,
    platform: []const u8,
    languages: []const []const u8,
    language: []const u8,
    timezone: []const u8,
    screen: ScreenProfile,
    window: WindowProfile,
    hardwareConcurrency: u32,
    maxTouchPoints: u32,
    deviceMemory: u32,
    vendor: []const u8,
    product: []const u8,
    media: MediaProfile,
    webgl: WebGlProfile,
    canvas: CanvasProfile,
    audio: AudioProfile,
    connection: ConnectionProfile,
    tls: TlsProfile = .{},
    battery: BatteryProfile = .{},

    pub const UserAgentData = struct {
        brands: []const Brand,
        fullVersionList: []const Brand,
        platform: []const u8,
        platformVersion: []const u8,
        architecture: []const u8,
        model: []const u8,
        mobile: bool,

        pub const Brand = struct {
            brand: []const u8,
            version: []const u8,
        };
    };

    pub const ScreenProfile = struct {
        width: u32,
        height: u32,
        availWidth: u32,
        availHeight: u32,
        colorDepth: u32,
        pixelDepth: u32,
    };

    pub const WindowProfile = struct {
        innerWidth: u32,
        innerHeight: u32,
        outerWidth: u32,
        outerHeight: u32,
        screenX: i32,
        screenY: i32,
        devicePixelRatio: f64,
    };

    pub const MediaProfile = struct {
        audioCodecs: []const []const u8,
        videoCodecs: []const []const u8,
    };

    pub const WebGlProfile = struct {
        vendor: []const u8,
        renderer: []const u8,
        params: json.Value = .null,
    };

    pub const CanvasProfile = struct {
        mode: Mode,
        seed: []const u8,

        pub const Mode = enum {
            stable,
            noise,
        };
    };

    pub const AudioProfile = struct {
        mode: Mode,
        seed: []const u8,

        pub const Mode = enum {
            stable,
            noise,
        };
    };

    pub const ConnectionProfile = struct {
        effectiveType: []const u8, // "4g", "3g", "2g", "slow-2g"
        downlink: f64, // Mbps
        rtt: u32, // ms
        saveData: bool,
    };

    /// TLS fingerprint profile for curl-impersonate
    /// Used to configure TLS/HTTP2 fingerprinting at the network layer
    /// IMPORTANT: impersonateTarget should match chromeVersion for fingerprint consistency
    pub const TlsProfile = struct {
        /// Target browser to impersonate for TLS fingerprinting
        /// Should match the chromeVersion field for consistency
        /// Supported Chrome values: "chrome131", "chrome124", "chrome116", "chrome99", etc.
        /// Supported Firefox values: "ff117", "ff109", "ff102", etc.
        /// Supported Safari values: "safari15_5", "safari15_3", etc.
        /// See curl-impersonate documentation for full list
        impersonateTarget: []const u8 = "chrome116",
    };

    /// Battery status profile for fingerprinting
    /// Controls the values returned by navigator.getBattery()
    pub const BatteryProfile = struct {
        /// Whether the battery is currently being charged
        charging: bool = true,
        /// Battery charge level (0.0 to 1.0)
        level: f64 = 1.0,
        /// Time until battery is fully charged (seconds), 0 if fully charged
        chargingTime: f64 = 0.0,
        /// Time until battery is empty (seconds), Infinity if charging
        dischargingTime: f64 = std.math.inf(f64),
    };

    pub fn defaultMacOS() FingerprintProfile {
        return .{
            .chromeVersion = "124.0.0.0",
            .userAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36",
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
                .platform = "macOS",
                .platformVersion = "10.15.7",
                .architecture = "x86",
                .model = "",
                .mobile = false,
            },
            .platform = "MacIntel",
            .languages = &.{ "en-US", "en" },
            .language = "en-US",
            .timezone = "America/Los_Angeles",
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
                .innerHeight = 1080,
                .outerWidth = 1920,
                .outerHeight = 1080,
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
                .vendor = "Intel Inc.",
                .renderer = "Intel Iris OpenGL Engine",
                .params = .null,
            },
            .canvas = .{
                .mode = .stable,
                .seed = "macos-default",
            },
            .audio = .{
                .mode = .stable,
                .seed = "macos-default",
            },
            .connection = .{
                .effectiveType = "4g",
                .downlink = 10.0,
                .rtt = 50,
                .saveData = false,
            },
            .tls = .{
                .impersonateTarget = "chrome116",
            },
        };
    }

    pub fn validate(self: FingerprintProfile) !void {
        if (self.userAgent.len == 0) return error.InvalidFingerprintProfile;
        if (self.platform.len == 0) return error.InvalidFingerprintProfile;
        if (self.language.len == 0) return error.InvalidFingerprintProfile;
        if (self.languages.len == 0) return error.InvalidFingerprintProfile;
        if (self.chromeVersion.len == 0) return error.InvalidFingerprintProfile;
        if (self.screen.width == 0 or self.screen.height == 0) return error.InvalidFingerprintProfile;
        if (self.window.innerWidth == 0 or self.window.innerHeight == 0) return error.InvalidFingerprintProfile;
        if (self.deviceMemory == 0) return error.InvalidFingerprintProfile;
    }
};

pub const Config = struct {
    run_mode: RunMode,
    tls_verify_host: bool = true,
    http_proxy: ?[:0]const u8 = null,
    proxy_bearer_token: ?[:0]const u8 = null,
    http_timeout_ms: ?u31 = null,
    http_connect_timeout_ms: ?u31 = null,
    http_max_host_open: ?u8 = null,
    http_max_concurrent: ?u8 = null,
    user_agent: [:0]const u8,
    fingerprint_profile: FingerprintProfile,
};

pub fn init(allocator: Allocator, config: Config) !*App {
    const app = try allocator.create(App);
    errdefer allocator.destroy(app);

    app.config = config;
    app.allocator = allocator;

    app.notification = try Notification.init(allocator, null);
    errdefer app.notification.deinit();

    app.http = try Http.init(allocator, .{
        .max_host_open = config.http_max_host_open orelse 4,
        .max_concurrent = config.http_max_concurrent orelse 10,
        .timeout_ms = config.http_timeout_ms orelse 5000,
        .connect_timeout_ms = config.http_connect_timeout_ms orelse 0,
        .http_proxy = config.http_proxy,
        .tls_verify_host = config.tls_verify_host,
        .proxy_bearer_token = config.proxy_bearer_token,
        .user_agent = config.user_agent,
        .impersonate_target = config.fingerprint_profile.tls.impersonateTarget,
    });
    errdefer app.http.deinit();

    app.platform = try Platform.init();
    errdefer app.platform.deinit();

    app.snapshot = try Snapshot.load();
    errdefer app.snapshot.deinit();

    app.app_dir_path = getAndMakeAppDir(allocator);

    app.telemetry = try Telemetry.init(app, config.run_mode);
    errdefer app.telemetry.deinit();

    try app.telemetry.register(app.notification);

    return app;
}

pub fn deinit(self: *App) void {
    if (@atomicRmw(bool, &self.shutdown, .Xchg, true, .monotonic)) {
        return;
    }

    const allocator = self.allocator;
    if (self.app_dir_path) |app_dir_path| {
        allocator.free(app_dir_path);
        self.app_dir_path = null;
    }
    self.telemetry.deinit();
    self.notification.deinit();
    self.http.deinit();
    self.snapshot.deinit();
    self.platform.deinit();

    allocator.destroy(self);
}

fn getAndMakeAppDir(allocator: Allocator) ?[]const u8 {
    if (@import("builtin").is_test) {
        return allocator.dupe(u8, "/tmp") catch unreachable;
    }
    const app_dir_path = std.fs.getAppDataDir(allocator, "lightpanda") catch |err| {
        log.warn(.app, "get data dir", .{ .err = err });
        return null;
    };

    std.fs.cwd().makePath(app_dir_path) catch |err| switch (err) {
        error.PathAlreadyExists => return app_dir_path,
        else => {
            allocator.free(app_dir_path);
            log.warn(.app, "create data dir", .{ .err = err, .path = app_dir_path });
            return null;
        },
    };
    return app_dir_path;
}
