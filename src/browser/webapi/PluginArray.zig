// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

const js = @import("../js/js.zig");

pub fn registerTypes() []const type {
    return &.{
        Plugin,
        PluginArray,
        MimeType,
        MimeTypeArray,
    };
}

/// Plugin represents a browser plugin (deprecated but still needed for fingerprint detection)
pub const Plugin = struct {
    _name: []const u8,
    _description: []const u8,
    _filename: []const u8,

    pub fn getName(self: *const Plugin) []const u8 {
        return self._name;
    }

    pub fn getDescription(self: *const Plugin) []const u8 {
        return self._description;
    }

    pub fn getFilename(self: *const Plugin) []const u8 {
        return self._filename;
    }

    pub fn getLength(_: *const Plugin) u32 {
        return 0; // No MIME types
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(Plugin);

        pub const Meta = struct {
            pub const name = "Plugin";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"name" = bridge.accessor(Plugin.getName, null, .{});
        pub const description = bridge.accessor(Plugin.getDescription, null, .{});
        pub const filename = bridge.accessor(Plugin.getFilename, null, .{});
        pub const length = bridge.accessor(Plugin.getLength, null, .{});
    };
};

/// PluginArray represents navigator.plugins
pub const PluginArray = struct {
    pub fn getLength(_: *const PluginArray) u32 {
        // Modern Chrome returns 5 default plugins for PDF support
        return 5;
    }

    pub fn item(_: *const PluginArray, _: u32) ?*Plugin {
        // Return null - plugins are deprecated
        return null;
    }

    pub fn namedItem(_: *const PluginArray, _: []const u8) ?*Plugin {
        return null;
    }

    pub fn refresh(_: *const PluginArray) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(PluginArray);

        pub const Meta = struct {
            pub const name = "PluginArray";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const length = bridge.accessor(PluginArray.getLength, null, .{});
        pub const item = bridge.function(PluginArray.item, .{});
        pub const namedItem = bridge.function(PluginArray.namedItem, .{});
        pub const refresh = bridge.function(PluginArray.refresh, .{});
    };
};

/// MimeType represents a MIME type supported by plugins
pub const MimeType = struct {
    _type: []const u8,
    _description: []const u8,
    _suffixes: []const u8,

    pub fn getType(self: *const MimeType) []const u8 {
        return self._type;
    }

    pub fn getDescription(self: *const MimeType) []const u8 {
        return self._description;
    }

    pub fn getSuffixes(self: *const MimeType) []const u8 {
        return self._suffixes;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MimeType);

        pub const Meta = struct {
            pub const name = "MimeType";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"type" = bridge.accessor(MimeType.getType, null, .{});
        pub const description = bridge.accessor(MimeType.getDescription, null, .{});
        pub const suffixes = bridge.accessor(MimeType.getSuffixes, null, .{});
    };
};

/// MimeTypeArray represents navigator.mimeTypes
pub const MimeTypeArray = struct {
    pub fn getLength(_: *const MimeTypeArray) u32 {
        // Modern Chrome returns 2 for PDF MIME types
        return 2;
    }

    pub fn item(_: *const MimeTypeArray, _: u32) ?*MimeType {
        return null;
    }

    pub fn namedItem(_: *const MimeTypeArray, _: []const u8) ?*MimeType {
        return null;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MimeTypeArray);

        pub const Meta = struct {
            pub const name = "MimeTypeArray";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const length = bridge.accessor(MimeTypeArray.getLength, null, .{});
        pub const item = bridge.function(MimeTypeArray.item, .{});
        pub const namedItem = bridge.function(MimeTypeArray.namedItem, .{});
    };
};
