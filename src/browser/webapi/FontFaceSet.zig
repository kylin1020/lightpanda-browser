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

//! FontFaceSet stub implementation for anti-fingerprinting
//!
//! This module provides stub implementations of the CSS Font Loading API
//! that prevent font enumeration fingerprinting. The API reports "loaded"
//! status but doesn't expose actual system fonts.

const std = @import("std");
const js = @import("../js/js.zig");
const Page = @import("../Page.zig");
const EventTarget = @import("EventTarget.zig");

pub fn registerTypes() []const type {
    return &.{
        FontFaceSet,
        FontFace,
    };
}

/// FontFaceSet - represents the set of fonts available to a document
/// Stub implementation that prevents font enumeration fingerprinting
pub const FontFaceSet = struct {
    _proto: *EventTarget,
    _page: *Page,
    _on_loading: ?js.Function.Global = null,
    _on_loading_done: ?js.Function.Global = null,
    _on_loading_error: ?js.Function.Global = null,

    pub fn init(page: *Page) !*FontFaceSet {
        return page._factory.eventTarget(FontFaceSet{
            ._proto = undefined,
            ._page = page,
        });
    }

    pub fn asEventTarget(self: *FontFaceSet) *EventTarget {
        return self._proto;
    }

    /// Returns "loaded" to indicate fonts are ready
    pub fn getStatus(_: *const FontFaceSet) []const u8 {
        return "loaded";
    }

    /// Returns a promise that resolves immediately (fonts always "ready")
    pub fn getReady(self: *FontFaceSet) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("FontFaceSet.ready", self);
        return resolver.promise();
    }

    /// Returns the number of fonts (always 0 to prevent enumeration)
    pub fn getSize(_: *const FontFaceSet) u32 {
        return 0;
    }

    /// Check if a font is available - always returns a resolved promise with empty array
    /// This prevents fingerprinting via font checking
    pub fn check(_: *FontFaceSet, _: []const u8, _: ?[]const u8) bool {
        // Always return true to indicate the font is "available"
        // This prevents fingerprinting by checking for specific fonts
        return true;
    }

    /// Load fonts - returns a promise that resolves with undefined (empty result)
    pub fn load(self: *FontFaceSet, _: []const u8, _: ?[]const u8) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        // Resolve with undefined - no fonts loaded
        resolver.resolve("FontFaceSet.load", {});
        return resolver.promise();
    }

    /// Add a font face - no-op for stub
    pub fn add(_: *FontFaceSet, _: *FontFace) void {
        // No-op
    }

    /// Delete a font face - always returns true
    pub fn delete(_: *FontFaceSet, _: *FontFace) bool {
        return true;
    }

    /// Clear all font faces - no-op for stub
    pub fn clear(_: *FontFaceSet) void {
        // No-op
    }

    /// Check if font face exists - always returns false
    pub fn has(_: *FontFaceSet, _: *FontFace) bool {
        return false;
    }

    /// forEach - no-op since set is empty
    pub fn forEach(_: *FontFaceSet, _: js.Function) void {
        // No-op - set is empty
    }

    /// entries - returns undefined (stub for empty set)
    pub fn entries(_: *FontFaceSet) void {
        // No-op - returns undefined
    }

    /// keys - returns undefined (stub for empty set)
    pub fn keys(_: *FontFaceSet) void {
        // No-op - returns undefined
    }

    /// values - returns undefined (stub for empty set)
    pub fn values(_: *FontFaceSet) void {
        // No-op - returns undefined
    }

    // Event handlers

    pub fn getOnLoading(self: *const FontFaceSet) ?js.Function.Global {
        return self._on_loading;
    }

    pub fn setOnLoading(self: *FontFaceSet, handler: ?js.Function.Global) void {
        self._on_loading = handler;
    }

    pub fn getOnLoadingDone(self: *const FontFaceSet) ?js.Function.Global {
        return self._on_loading_done;
    }

    pub fn setOnLoadingDone(self: *FontFaceSet, handler: ?js.Function.Global) void {
        self._on_loading_done = handler;
    }

    pub fn getOnLoadingError(self: *const FontFaceSet) ?js.Function.Global {
        return self._on_loading_error;
    }

    pub fn setOnLoadingError(self: *FontFaceSet, handler: ?js.Function.Global) void {
        self._on_loading_error = handler;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(FontFaceSet);

        pub const Meta = struct {
            pub const name = "FontFaceSet";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        // Properties
        pub const status = bridge.accessor(FontFaceSet.getStatus, null, .{});
        pub const ready = bridge.accessor(FontFaceSet.getReady, null, .{});
        pub const size = bridge.accessor(FontFaceSet.getSize, null, .{});

        // Methods
        pub const check = bridge.function(FontFaceSet.check, .{});
        pub const load = bridge.function(FontFaceSet.load, .{});
        pub const add = bridge.function(FontFaceSet.add, .{});
        pub const delete = bridge.function(FontFaceSet.delete, .{});
        pub const clear = bridge.function(FontFaceSet.clear, .{});
        pub const has = bridge.function(FontFaceSet.has, .{});
        pub const forEach = bridge.function(FontFaceSet.forEach, .{});
        pub const entries = bridge.function(FontFaceSet.entries, .{});
        pub const keys = bridge.function(FontFaceSet.keys, .{});
        pub const values = bridge.function(FontFaceSet.values, .{});

        // Event handlers
        pub const onloading = bridge.accessor(FontFaceSet.getOnLoading, FontFaceSet.setOnLoading, .{});
        pub const onloadingdone = bridge.accessor(FontFaceSet.getOnLoadingDone, FontFaceSet.setOnLoadingDone, .{});
        pub const onloadingerror = bridge.accessor(FontFaceSet.getOnLoadingError, FontFaceSet.setOnLoadingError, .{});
    };
};

/// FontFace - represents a single font face
/// Stub implementation that accepts font definitions but doesn't load actual fonts
pub const FontFace = struct {
    _family: []const u8,
    _source: []const u8,
    _style: []const u8,
    _weight: []const u8,
    _stretch: []const u8,
    _unicode_range: []const u8,
    _variant: []const u8,
    _feature_settings: []const u8,
    _variation_settings: []const u8,
    _display: []const u8,
    _ascent_override: []const u8,
    _descent_override: []const u8,
    _line_gap_override: []const u8,
    _page: *Page,

    const Descriptors = struct {
        style: ?[]const u8 = null,
        weight: ?[]const u8 = null,
        stretch: ?[]const u8 = null,
        unicodeRange: ?[]const u8 = null,
        variant: ?[]const u8 = null,
        featureSettings: ?[]const u8 = null,
        variationSettings: ?[]const u8 = null,
        display: ?[]const u8 = null,
        ascentOverride: ?[]const u8 = null,
        descentOverride: ?[]const u8 = null,
        lineGapOverride: ?[]const u8 = null,
    };

    pub fn constructor(family: []const u8, source: []const u8, descriptors: ?Descriptors, page: *Page) !*FontFace {
        const d = descriptors orelse Descriptors{};
        return page._factory.create(FontFace{
            ._family = family,
            ._source = source,
            ._style = d.style orelse "normal",
            ._weight = d.weight orelse "normal",
            ._stretch = d.stretch orelse "normal",
            ._unicode_range = d.unicodeRange orelse "U+0-10FFFF",
            ._variant = d.variant orelse "normal",
            ._feature_settings = d.featureSettings orelse "normal",
            ._variation_settings = d.variationSettings orelse "normal",
            ._display = d.display orelse "auto",
            ._ascent_override = d.ascentOverride orelse "normal",
            ._descent_override = d.descentOverride orelse "normal",
            ._line_gap_override = d.lineGapOverride orelse "normal",
            ._page = page,
        });
    }

    pub fn getFamily(self: *const FontFace) []const u8 {
        return self._family;
    }

    pub fn setFamily(self: *FontFace, value: []const u8) void {
        self._family = value;
    }

    pub fn getStyle(self: *const FontFace) []const u8 {
        return self._style;
    }

    pub fn setStyle(self: *FontFace, value: []const u8) void {
        self._style = value;
    }

    pub fn getWeight(self: *const FontFace) []const u8 {
        return self._weight;
    }

    pub fn setWeight(self: *FontFace, value: []const u8) void {
        self._weight = value;
    }

    pub fn getStretch(self: *const FontFace) []const u8 {
        return self._stretch;
    }

    pub fn setStretch(self: *FontFace, value: []const u8) void {
        self._stretch = value;
    }

    pub fn getUnicodeRange(self: *const FontFace) []const u8 {
        return self._unicode_range;
    }

    pub fn setUnicodeRange(self: *FontFace, value: []const u8) void {
        self._unicode_range = value;
    }

    pub fn getVariant(self: *const FontFace) []const u8 {
        return self._variant;
    }

    pub fn setVariant(self: *FontFace, value: []const u8) void {
        self._variant = value;
    }

    pub fn getFeatureSettings(self: *const FontFace) []const u8 {
        return self._feature_settings;
    }

    pub fn setFeatureSettings(self: *FontFace, value: []const u8) void {
        self._feature_settings = value;
    }

    pub fn getVariationSettings(self: *const FontFace) []const u8 {
        return self._variation_settings;
    }

    pub fn setVariationSettings(self: *FontFace, value: []const u8) void {
        self._variation_settings = value;
    }

    pub fn getDisplay(self: *const FontFace) []const u8 {
        return self._display;
    }

    pub fn setDisplay(self: *FontFace, value: []const u8) void {
        self._display = value;
    }

    pub fn getAscentOverride(self: *const FontFace) []const u8 {
        return self._ascent_override;
    }

    pub fn setAscentOverride(self: *FontFace, value: []const u8) void {
        self._ascent_override = value;
    }

    pub fn getDescentOverride(self: *const FontFace) []const u8 {
        return self._descent_override;
    }

    pub fn setDescentOverride(self: *FontFace, value: []const u8) void {
        self._descent_override = value;
    }

    pub fn getLineGapOverride(self: *const FontFace) []const u8 {
        return self._line_gap_override;
    }

    pub fn setLineGapOverride(self: *FontFace, value: []const u8) void {
        self._line_gap_override = value;
    }

    /// Font loading status - always returns "loaded"
    pub fn getStatus(_: *const FontFace) []const u8 {
        return "loaded";
    }

    /// Load the font - returns a promise that resolves immediately
    pub fn load(self: *FontFace) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("FontFace.load", self);
        return resolver.promise();
    }

    /// Returns a promise that resolves when the font is "loaded" (immediately)
    pub fn getLoaded(self: *FontFace) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("FontFace.loaded", self);
        return resolver.promise();
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(FontFace);

        pub const Meta = struct {
            pub const name = "FontFace";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(FontFace.constructor, .{});

        // Properties
        pub const family = bridge.accessor(FontFace.getFamily, FontFace.setFamily, .{});
        pub const style = bridge.accessor(FontFace.getStyle, FontFace.setStyle, .{});
        pub const weight = bridge.accessor(FontFace.getWeight, FontFace.setWeight, .{});
        pub const stretch = bridge.accessor(FontFace.getStretch, FontFace.setStretch, .{});
        pub const unicodeRange = bridge.accessor(FontFace.getUnicodeRange, FontFace.setUnicodeRange, .{});
        pub const variant = bridge.accessor(FontFace.getVariant, FontFace.setVariant, .{});
        pub const featureSettings = bridge.accessor(FontFace.getFeatureSettings, FontFace.setFeatureSettings, .{});
        pub const variationSettings = bridge.accessor(FontFace.getVariationSettings, FontFace.setVariationSettings, .{});
        pub const display = bridge.accessor(FontFace.getDisplay, FontFace.setDisplay, .{});
        pub const ascentOverride = bridge.accessor(FontFace.getAscentOverride, FontFace.setAscentOverride, .{});
        pub const descentOverride = bridge.accessor(FontFace.getDescentOverride, FontFace.setDescentOverride, .{});
        pub const lineGapOverride = bridge.accessor(FontFace.getLineGapOverride, FontFace.setLineGapOverride, .{});
        pub const status = bridge.accessor(FontFace.getStatus, null, .{});
        pub const loaded = bridge.accessor(FontFace.getLoaded, null, .{});

        // Methods
        pub const load = bridge.function(FontFace.load, .{});
    };
};
