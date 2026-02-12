// Copyright (C) 2023-2026  Lightpanda (Selecy SAS)
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

const js = @import("../js/js.zig");

pub fn registerTypes() []const type {
    return &.{ Chrome, ChromeRuntime, ChromeRuntimeEvent };
}

const Chrome = @This();

_runtime: ChromeRuntime = .{},

pub const init: Chrome = .{};

pub fn getRuntime(self: *Chrome) *ChromeRuntime {
    return &self._runtime;
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(Chrome);

    pub const Meta = struct {
        pub const name = "chrome";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const runtime = bridge.accessor(Chrome.getRuntime, null, .{});
};

pub const ChromeRuntime = struct {
    _on_connect: ChromeRuntimeEvent = .{},
    _on_message: ChromeRuntimeEvent = .{},
    _on_installed: ChromeRuntimeEvent = .{},

    pub fn getOnConnect(self: *ChromeRuntime) *ChromeRuntimeEvent {
        return &self._on_connect;
    }

    pub fn getOnMessage(self: *ChromeRuntime) *ChromeRuntimeEvent {
        return &self._on_message;
    }

    pub fn getOnInstalled(self: *ChromeRuntime) *ChromeRuntimeEvent {
        return &self._on_installed;
    }

    pub fn connect(_: *ChromeRuntime) void {}

    pub fn sendMessage(_: *ChromeRuntime) void {}

    pub fn getURL(_: *ChromeRuntime, path: ?[]const u8) []const u8 {
        _ = path;
        return "";
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(ChromeRuntime);

        pub const Meta = struct {
            pub const name = "runtime";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const id = bridge.property(null, .{ .template = false });
        pub const connect = bridge.function(ChromeRuntime.connect, .{});
        pub const sendMessage = bridge.function(ChromeRuntime.sendMessage, .{});
        pub const getURL = bridge.function(ChromeRuntime.getURL, .{});
        pub const onConnect = bridge.accessor(ChromeRuntime.getOnConnect, null, .{});
        pub const onMessage = bridge.accessor(ChromeRuntime.getOnMessage, null, .{});
        pub const onInstalled = bridge.accessor(ChromeRuntime.getOnInstalled, null, .{});
    };
};

pub const ChromeRuntimeEvent = struct {
    pub fn addListener(_: *ChromeRuntimeEvent) void {}

    pub fn removeListener(_: *ChromeRuntimeEvent) void {}

    pub fn hasListener(_: *ChromeRuntimeEvent) bool {
        return false;
    }

    pub fn hasListeners(_: *ChromeRuntimeEvent) bool {
        return false;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(ChromeRuntimeEvent);

        pub const Meta = struct {
            pub const name = "ChromeRuntimeEvent";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
            pub const empty_with_no_proto = true;
        };

        pub const addListener = bridge.function(ChromeRuntimeEvent.addListener, .{});
        pub const removeListener = bridge.function(ChromeRuntimeEvent.removeListener, .{});
        pub const hasListener = bridge.function(ChromeRuntimeEvent.hasListener, .{});
        pub const hasListeners = bridge.function(ChromeRuntimeEvent.hasListeners, .{});
    };
};
