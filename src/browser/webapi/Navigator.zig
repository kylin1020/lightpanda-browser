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
const js = @import("../js/js.zig");
const Page = @import("../Page.zig");
const App = @import("../../App.zig");
const Permissions = @import("Permissions.zig");
const BatteryManager = @import("BatteryManager.zig");
const PluginArray = @import("PluginArray.zig");
const log = @import("../../log.zig");

const Navigator = @This();
_pad: bool = false,

// Debug flag for fingerprint tracking
const FINGERPRINT_DEBUG = true;

pub const init: Navigator = .{};

pub fn getUserAgent(_: *const Navigator, page: *Page) []const u8 {
    const value = page.fingerprintProfile().userAgent;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.userAgent", .{ .value = value });
    return value;
}

pub fn getAppName(_: *const Navigator) []const u8 {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.appName", .{ .value = "Netscape" });
    return "Netscape";
}

pub fn getAppCodeName(_: *const Navigator) []const u8 {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.appCodeName", .{ .value = "Mozilla" });
    return "Mozilla";
}

pub fn getAppVersion(_: *const Navigator, page: *Page) []const u8 {
    // Real Chrome returns the full user agent string without "Mozilla/"
    // e.g., "5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36..."
    const ua = page.fingerprintProfile().userAgent;
    // Skip "Mozilla/" prefix if present
    if (std.mem.startsWith(u8, ua, "Mozilla/")) {
        const value = ua[8..];
        if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.appVersion", .{ .value = value });
        return value;
    }
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.appVersion", .{ .value = ua });
    return ua;
}

pub fn getPlatform(_: *const Navigator, page: *Page) []const u8 {
    const value = page.fingerprintProfile().platform;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.platform", .{ .value = value });
    return value;
}

pub fn getLanguage(_: *const Navigator, page: *Page) []const u8 {
    const value = page.fingerprintProfile().language;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.language", .{ .value = value });
    return value;
}

pub fn getLanguages(_: *const Navigator, page: *Page) []const []const u8 {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.languages", .{});
    return page.fingerprintProfile().languages;
}

pub fn getOnLine(_: *const Navigator) bool {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.onLine", .{ .value = true });
    return true;
}

pub fn getCookieEnabled(_: *const Navigator) bool {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.cookieEnabled", .{ .value = true });
    return true;
}

pub fn getHardwareConcurrency(_: *const Navigator, page: *Page) u32 {
    const value = page.fingerprintProfile().hardwareConcurrency;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.hwConcurrency", .{ .value = value });
    return value;
}

pub fn getMaxTouchPoints(_: *const Navigator, page: *Page) u32 {
    const value = page.fingerprintProfile().maxTouchPoints;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.maxTouchPts", .{ .value = value });
    return value;
}

/// Returns the vendor name
pub fn getVendor(_: *const Navigator, page: *Page) []const u8 {
    const value = page.fingerprintProfile().vendor;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.vendor", .{ .value = value });
    return value;
}

/// Returns the product name (typically "Gecko" for compatibility)
pub fn getProduct(_: *const Navigator, page: *Page) []const u8 {
    const value = page.fingerprintProfile().product;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.product", .{ .value = value });
    return value;
}

/// Returns whether Java is enabled (always false)
pub fn javaEnabled(_: *const Navigator) bool {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.javaEnabled", .{});
    return false;
}

/// Returns whether the browser is controlled by automation (always false)
pub fn getWebdriver(_: *const Navigator) bool {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.webdriver", .{ .value = false });
    return false;
}

pub fn getUserAgentData(_: *const Navigator, page: *Page) !*NavigatorUAData {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.userAgentData", .{});
    return page._factory.create(NavigatorUAData{ ._page = page });
}

pub fn getPlugins(_: *const Navigator, page: *Page) !*PluginArray.PluginArray {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.plugins", .{});
    return page._factory.create(PluginArray.PluginArray{});
}

pub fn getMimeTypes(_: *const Navigator, page: *Page) !*PluginArray.MimeTypeArray {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.mimeTypes", .{});
    return page._factory.create(PluginArray.MimeTypeArray{});
}

pub fn getDeviceMemory(_: *const Navigator, page: *Page) u32 {
    const value = page.fingerprintProfile().deviceMemory;
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.deviceMemory", .{ .value = value });
    return value;
}

pub fn getConnection(_: *const Navigator, page: *Page) !*NetworkInformation {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.connection", .{});
    return page._factory.create(NetworkInformation{ ._page = page });
}

pub fn getPermissions(_: *const Navigator, page: *Page) !*Permissions.Permissions {
    if (FINGERPRINT_DEBUG) log.debug(.browser, "FP nav.permissions", .{});
    return Permissions.Permissions.init(page);
}

pub fn getBattery(_: *const Navigator, page: *Page) !js.Promise {
    const manager = try BatteryManager.BatteryManager.init(page);
    const resolver = page.js.createPromiseResolver();
    resolver.resolve("Navigator.getBattery", manager);
    return resolver.promise();
}

pub fn registerProtocolHandler(_: *const Navigator, scheme: []const u8, url: [:0]const u8, page: *const Page) !void {
    try validateProtocolHandlerScheme(scheme);
    try validateProtocolHandlerURL(url, page);
}
pub fn unregisterProtocolHandler(_: *const Navigator, scheme: []const u8, url: [:0]const u8, page: *const Page) !void {
    try validateProtocolHandlerScheme(scheme);
    try validateProtocolHandlerURL(url, page);
}

fn validateProtocolHandlerScheme(scheme: []const u8) !void {
    const allowed = std.StaticStringMap(void).initComptime(.{
        .{ "bitcoin", {} },
        .{ "cabal", {} },
        .{ "dat", {} },
        .{ "did", {} },
        .{ "dweb", {} },
        .{ "ethereum", .{} },
        .{ "ftp", {} },
        .{ "ftps", {} },
        .{ "geo", {} },
        .{ "im", {} },
        .{ "ipfs", {} },
        .{ "ipns", .{} },
        .{ "irc", {} },
        .{ "ircs", {} },
        .{ "hyper", {} },
        .{ "magnet", {} },
        .{ "mailto", {} },
        .{ "matrix", {} },
        .{ "mms", {} },
        .{ "news", {} },
        .{ "nntp", {} },
        .{ "openpgp4fpr", {} },
        .{ "sftp", {} },
        .{ "sip", {} },
        .{ "sms", {} },
        .{ "smsto", {} },
        .{ "ssb", {} },
        .{ "ssh", {} },
        .{ "tel", {} },
        .{ "urn", {} },
        .{ "webcal", {} },
        .{ "wtai", {} },
        .{ "xmpp", {} },
    });
    if (allowed.has(scheme)) {
        return;
    }

    if (scheme.len < 5 or !std.mem.startsWith(u8, scheme, "web+")) {
        return error.SecurityError;
    }
    for (scheme[4..]) |b| {
        if (std.ascii.isLower(b) == false) {
            return error.SecurityError;
        }
    }
}

fn validateProtocolHandlerURL(url: [:0]const u8, page: *const Page) !void {
    if (std.mem.indexOf(u8, url, "%s") == null) {
        return error.SyntaxError;
    }
    if (try page.isSameOrigin(url) == false) {
        return error.SyntaxError;
    }
}

pub fn registerTypes() []const type {
    return &.{
        Navigator,
        NetworkInformation,
        NavigatorUAData,
    };
}

/// NetworkInformation API - provides connection information
pub const NetworkInformation = struct {
    _page: *Page,

    pub fn getEffectiveType(self: *const NetworkInformation) []const u8 {
        return self._page.fingerprintProfile().connection.effectiveType;
    }

    pub fn getDownlink(self: *const NetworkInformation) f64 {
        return self._page.fingerprintProfile().connection.downlink;
    }

    pub fn getRtt(self: *const NetworkInformation) u32 {
        return self._page.fingerprintProfile().connection.rtt;
    }

    pub fn getSaveData(self: *const NetworkInformation) bool {
        return self._page.fingerprintProfile().connection.saveData;
    }

    pub fn getType(_: *const NetworkInformation) []const u8 {
        return "wifi"; // Most common default
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(NetworkInformation);

        pub const Meta = struct {
            pub const name = "NetworkInformation";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const effectiveType = bridge.accessor(NetworkInformation.getEffectiveType, null, .{});
        pub const downlink = bridge.accessor(NetworkInformation.getDownlink, null, .{});
        pub const rtt = bridge.accessor(NetworkInformation.getRtt, null, .{});
        pub const saveData = bridge.accessor(NetworkInformation.getSaveData, null, .{});
        pub const @"type" = bridge.accessor(NetworkInformation.getType, null, .{});
    };
};

/// NavigatorUAData - provides user agent data with getHighEntropyValues
pub const NavigatorUAData = struct {
    _page: *Page,

    pub fn getBrands(self: *const NavigatorUAData) []const App.FingerprintProfile.UserAgentData.Brand {
        return self._page.fingerprintProfile().userAgentData.brands;
    }

    pub fn getMobile(self: *const NavigatorUAData) bool {
        return self._page.fingerprintProfile().userAgentData.mobile;
    }

    pub fn getPlatform(self: *const NavigatorUAData) []const u8 {
        return self._page.fingerprintProfile().userAgentData.platform;
    }

    /// Returns a Promise that resolves with high-entropy values
    pub fn getHighEntropyValues(self: *const NavigatorUAData, _: ?[]const []const u8) !js.Promise {
        const profile = self._page.fingerprintProfile().userAgentData;
        const resolver = self._page.js.createPromiseResolver();

        // Return the high entropy data as a JS object
        // The actual object construction will be handled by the bridge
        const result = HighEntropyValues{
            .brands = profile.brands,
            .fullVersionList = profile.fullVersionList,
            .platform = profile.platform,
            .platformVersion = profile.platformVersion,
            .architecture = profile.architecture,
            .model = profile.model,
            .mobile = profile.mobile,
        };

        resolver.resolve("NavigatorUAData.getHighEntropyValues", result);
        return resolver.promise();
    }

    pub fn toJSON(self: *const NavigatorUAData) ToJSONResult {
        const profile = self._page.fingerprintProfile().userAgentData;
        return ToJSONResult{
            .brands = profile.brands,
            .mobile = profile.mobile,
            .platform = profile.platform,
        };
    }

    pub const HighEntropyValues = struct {
        brands: []const App.FingerprintProfile.UserAgentData.Brand,
        fullVersionList: []const App.FingerprintProfile.UserAgentData.Brand,
        platform: []const u8,
        platformVersion: []const u8,
        architecture: []const u8,
        model: []const u8,
        mobile: bool,
    };

    pub const ToJSONResult = struct {
        brands: []const App.FingerprintProfile.UserAgentData.Brand,
        mobile: bool,
        platform: []const u8,
    };

    pub const JsApi = struct {
        pub const bridge = js.Bridge(NavigatorUAData);

        pub const Meta = struct {
            pub const name = "NavigatorUAData";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const brands = bridge.accessor(NavigatorUAData.getBrands, null, .{});
        pub const mobile = bridge.accessor(NavigatorUAData.getMobile, null, .{});
        pub const platform = bridge.accessor(NavigatorUAData.getPlatform, null, .{});
        pub const getHighEntropyValues = bridge.function(NavigatorUAData.getHighEntropyValues, .{});
        pub const toJSON = bridge.function(NavigatorUAData.toJSON, .{});
    };
};

pub const JsApi = struct {
    pub const bridge = js.Bridge(Navigator);

    pub const Meta = struct {
        pub const name = "Navigator";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
        pub const empty_with_no_proto = true;
    };

    // Read-only properties
    pub const userAgent = bridge.accessor(Navigator.getUserAgent, null, .{});
    pub const appName = bridge.accessor(Navigator.getAppName, null, .{});
    pub const appCodeName = bridge.accessor(Navigator.getAppCodeName, null, .{});
    pub const appVersion = bridge.accessor(Navigator.getAppVersion, null, .{});
    pub const platform = bridge.accessor(Navigator.getPlatform, null, .{});
    pub const language = bridge.accessor(Navigator.getLanguage, null, .{});
    pub const languages = bridge.accessor(Navigator.getLanguages, null, .{});
    pub const onLine = bridge.accessor(Navigator.getOnLine, null, .{});
    pub const cookieEnabled = bridge.accessor(Navigator.getCookieEnabled, null, .{});
    pub const hardwareConcurrency = bridge.accessor(Navigator.getHardwareConcurrency, null, .{});
    pub const maxTouchPoints = bridge.accessor(Navigator.getMaxTouchPoints, null, .{});
    pub const deviceMemory = bridge.accessor(Navigator.getDeviceMemory, null, .{});
    pub const vendor = bridge.accessor(Navigator.getVendor, null, .{});
    pub const product = bridge.accessor(Navigator.getProduct, null, .{});
    pub const webdriver = bridge.accessor(Navigator.getWebdriver, null, .{});
    pub const userAgentData = bridge.accessor(Navigator.getUserAgentData, null, .{});
    pub const plugins = bridge.accessor(Navigator.getPlugins, null, .{});
    pub const mimeTypes = bridge.accessor(Navigator.getMimeTypes, null, .{});
    pub const connection = bridge.accessor(Navigator.getConnection, null, .{});
    pub const permissions = bridge.accessor(Navigator.getPermissions, null, .{});
    pub const registerProtocolHandler = bridge.function(Navigator.registerProtocolHandler, .{ .dom_exception = true });
    pub const unregisterProtocolHandler = bridge.function(Navigator.unregisterProtocolHandler, .{ .dom_exception = true });

    // Methods
    pub const javaEnabled = bridge.function(Navigator.javaEnabled, .{});
    pub const getBattery = bridge.function(Navigator.getBattery, .{});
};
