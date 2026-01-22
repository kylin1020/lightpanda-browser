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

const Navigator = @This();
_pad: bool = false,

pub const init: Navigator = .{};

pub fn getUserAgent(_: *const Navigator, page: *Page) []const u8 {
    return page.fingerprintProfile().userAgent;
}

pub fn getAppName(_: *const Navigator) []const u8 {
    return "Netscape";
}

pub fn getAppCodeName(_: *const Navigator) []const u8 {
    return "Netscape";
}

pub fn getAppVersion(_: *const Navigator) []const u8 {
    return "1.0";
}

pub fn getPlatform(_: *const Navigator, page: *Page) []const u8 {
    return page.fingerprintProfile().platform;
}

pub fn getLanguage(_: *const Navigator, page: *Page) []const u8 {
    return page.fingerprintProfile().language;
}

pub fn getLanguages(_: *const Navigator, page: *Page) []const []const u8 {
    return page.fingerprintProfile().languages;
}

pub fn getOnLine(_: *const Navigator) bool {
    return true;
}

pub fn getCookieEnabled(_: *const Navigator) bool {
    return true;
}

pub fn getHardwareConcurrency(_: *const Navigator, page: *Page) u32 {
    return page.fingerprintProfile().hardwareConcurrency;
}

pub fn getMaxTouchPoints(_: *const Navigator, page: *Page) u32 {
    return page.fingerprintProfile().maxTouchPoints;
}

/// Returns the vendor name
pub fn getVendor(_: *const Navigator, page: *Page) []const u8 {
    return page.fingerprintProfile().vendor;
}

/// Returns the product name (typically "Gecko" for compatibility)
pub fn getProduct(_: *const Navigator, page: *Page) []const u8 {
    return page.fingerprintProfile().product;
}

/// Returns whether Java is enabled (always false)
pub fn javaEnabled(_: *const Navigator) bool {
    return false;
}

/// Returns whether the browser is controlled by automation (always false)
pub fn getWebdriver(_: *const Navigator) bool {
    return false;
}

pub fn getUserAgentData(_: *const Navigator, page: *Page) App.FingerprintProfile.UserAgentData {
    return page.fingerprintProfile().userAgentData;
}

pub fn getPlugins(_: *const Navigator) []const []const u8 {
    return &.{};
}

pub fn getDeviceMemory(_: *const Navigator, page: *Page) u32 {
    return page.fingerprintProfile().deviceMemory;
}

pub fn getConnection(_: *const Navigator, page: *Page) !*NetworkInformation {
    return page._factory.create(NetworkInformation{ ._page = page });
}

pub fn getPermissions(_: *const Navigator, page: *Page) !*Permissions.Permissions {
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
    pub const connection = bridge.accessor(Navigator.getConnection, null, .{});
    pub const permissions = bridge.accessor(Navigator.getPermissions, null, .{});
    pub const registerProtocolHandler = bridge.function(Navigator.registerProtocolHandler, .{ .dom_exception = true });
    pub const unregisterProtocolHandler = bridge.function(Navigator.unregisterProtocolHandler, .{ .dom_exception = true });

    // Methods
    pub const javaEnabled = bridge.function(Navigator.javaEnabled, .{});
    pub const getBattery = bridge.function(Navigator.getBattery, .{});
};
