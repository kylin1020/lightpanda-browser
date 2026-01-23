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
        BatteryManager,
    };
}

/// BatteryManager provides information about the system's battery charge level
/// Values are configurable via the fingerprint profile for anti-fingerprinting
pub const BatteryManager = struct {
    _proto: *EventTarget,
    _page: *Page,
    _on_charging_change: ?js.Function.Global = null,
    _on_charging_time_change: ?js.Function.Global = null,
    _on_discharging_time_change: ?js.Function.Global = null,
    _on_level_change: ?js.Function.Global = null,

    pub fn init(page: *Page) !*BatteryManager {
        return page._factory.eventTarget(BatteryManager{
            ._proto = undefined,
            ._page = page,
        });
    }

    pub fn asEventTarget(self: *BatteryManager) *EventTarget {
        return self._proto;
    }

    /// Returns whether the battery is currently being charged
    /// Value from fingerprint profile
    pub fn getCharging(self: *const BatteryManager) bool {
        return self._page.fingerprintProfile().battery.charging;
    }

    /// Returns the time remaining until the battery is fully charged (in seconds)
    /// Returns Infinity if not charging, or 0 if fully charged
    /// Value from fingerprint profile
    pub fn getChargingTime(self: *const BatteryManager) f64 {
        return self._page.fingerprintProfile().battery.chargingTime;
    }

    /// Returns the time remaining until the battery is empty (in seconds)
    /// Returns Infinity if charging or if can't be determined
    /// Value from fingerprint profile
    pub fn getDischargingTime(self: *const BatteryManager) f64 {
        return self._page.fingerprintProfile().battery.dischargingTime;
    }

    /// Returns the battery charge level as a value between 0.0 and 1.0
    /// Value from fingerprint profile
    pub fn getLevel(self: *const BatteryManager) f64 {
        return self._page.fingerprintProfile().battery.level;
    }

    pub fn getOnChargingChange(self: *const BatteryManager) ?js.Function.Global {
        return self._on_charging_change;
    }

    pub fn setOnChargingChange(self: *BatteryManager, handler: ?js.Function.Global) void {
        self._on_charging_change = handler;
    }

    pub fn getOnChargingTimeChange(self: *const BatteryManager) ?js.Function.Global {
        return self._on_charging_time_change;
    }

    pub fn setOnChargingTimeChange(self: *BatteryManager, handler: ?js.Function.Global) void {
        self._on_charging_time_change = handler;
    }

    pub fn getOnDischargingTimeChange(self: *const BatteryManager) ?js.Function.Global {
        return self._on_discharging_time_change;
    }

    pub fn setOnDischargingTimeChange(self: *BatteryManager, handler: ?js.Function.Global) void {
        self._on_discharging_time_change = handler;
    }

    pub fn getOnLevelChange(self: *const BatteryManager) ?js.Function.Global {
        return self._on_level_change;
    }

    pub fn setOnLevelChange(self: *BatteryManager, handler: ?js.Function.Global) void {
        self._on_level_change = handler;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(BatteryManager);

        pub const Meta = struct {
            pub const name = "BatteryManager";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const charging = bridge.accessor(BatteryManager.getCharging, null, .{});
        pub const chargingTime = bridge.accessor(BatteryManager.getChargingTime, null, .{});
        pub const dischargingTime = bridge.accessor(BatteryManager.getDischargingTime, null, .{});
        pub const level = bridge.accessor(BatteryManager.getLevel, null, .{});
        pub const onchargingchange = bridge.accessor(BatteryManager.getOnChargingChange, BatteryManager.setOnChargingChange, .{});
        pub const onchargingtimechange = bridge.accessor(BatteryManager.getOnChargingTimeChange, BatteryManager.setOnChargingTimeChange, .{});
        pub const ondischargingtimechange = bridge.accessor(BatteryManager.getOnDischargingTimeChange, BatteryManager.setOnDischargingTimeChange, .{});
        pub const onlevelchange = bridge.accessor(BatteryManager.getOnLevelChange, BatteryManager.setOnLevelChange, .{});
    };
};
