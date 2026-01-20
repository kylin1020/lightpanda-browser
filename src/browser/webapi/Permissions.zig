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
const EventTarget = @import("EventTarget.zig");

pub fn registerTypes() []const type {
    return &.{
        Permissions,
        PermissionStatus,
    };
}

/// Permissions API for querying permission states
pub const Permissions = struct {
    _page: *Page,

    pub fn init(page: *Page) !*Permissions {
        return page._factory.create(Permissions{ ._page = page });
    }

    const QueryOptions = struct {
        name: []const u8,
    };

    /// Query the permission state for a given permission name.
    /// Returns a PermissionStatus with state based on permission type.
    pub fn query(self: *Permissions, options: QueryOptions) !js.Promise {
        // Determine permission state based on the permission name
        // Most sensitive permissions are "prompt" or "denied" by default in headless mode
        const state: []const u8 = getDefaultPermissionState(options.name);

        const status = try self._page._factory.eventTarget(PermissionStatus{
            ._proto = undefined,
            ._name = options.name,
            ._state = state,
        });

        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("Permissions.query", status);
        return resolver.promise();
    }

    fn getDefaultPermissionState(name: []const u8) []const u8 {
        // Sensitive permissions that should be denied by default
        const denied = std.StaticStringMap(void).initComptime(.{
            .{ "camera", {} },
            .{ "microphone", {} },
            .{ "geolocation", {} },
            .{ "notifications", {} },
            .{ "push", {} },
            .{ "midi", {} },
            .{ "bluetooth", {} },
            .{ "usb", {} },
            .{ "serial", {} },
            .{ "hid", {} },
            .{ "nfc", {} },
        });

        // Permissions that are typically granted
        const granted = std.StaticStringMap(void).initComptime(.{
            .{ "clipboard-read", {} },
            .{ "clipboard-write", {} },
            .{ "accelerometer", {} },
            .{ "gyroscope", {} },
            .{ "magnetometer", {} },
            .{ "ambient-light-sensor", {} },
        });

        if (denied.has(name)) {
            return "denied";
        }
        if (granted.has(name)) {
            return "granted";
        }
        return "prompt";
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(Permissions);

        pub const Meta = struct {
            pub const name = "Permissions";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const query = bridge.function(Permissions.query, .{});
    };
};

/// PermissionStatus represents the state of a permission
pub const PermissionStatus = struct {
    _proto: *EventTarget,
    _name: []const u8,
    _state: []const u8,
    _on_change: ?js.Function.Global = null,

    pub fn asEventTarget(self: *PermissionStatus) *EventTarget {
        return self._proto;
    }

    pub fn getName(self: *const PermissionStatus) []const u8 {
        return self._name;
    }

    pub fn getState(self: *const PermissionStatus) []const u8 {
        return self._state;
    }

    pub fn getOnChange(self: *const PermissionStatus) ?js.Function.Global {
        return self._on_change;
    }

    pub fn setOnChange(self: *PermissionStatus, handler: ?js.Function.Global) void {
        self._on_change = handler;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(PermissionStatus);

        pub const Meta = struct {
            pub const name = "PermissionStatus";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"name" = bridge.accessor(PermissionStatus.getName, null, .{});
        pub const state = bridge.accessor(PermissionStatus.getState, null, .{});
        pub const onchange = bridge.accessor(PermissionStatus.getOnChange, PermissionStatus.setOnChange, .{});
    };
};
