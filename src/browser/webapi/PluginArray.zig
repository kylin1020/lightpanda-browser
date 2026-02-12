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

const std = @import("std");
const js = @import("../js/js.zig");

const pdf_description = "Portable Document Format";
const pdf_filename = "internal-pdf-viewer";

pub fn registerTypes() []const type {
    return &.{ PluginArray, Plugin, MimeTypeArray, MimeType };
}

const PluginArray = @This();

_pad: bool = false,

pub fn refresh(_: *const PluginArray) void {}

pub fn length(_: *const PluginArray) usize {
    return plugins_data.len;
}

pub fn getAtIndex(_: *const PluginArray, index: usize) ?*Plugin {
    if (index >= plugins_data.len) {
        return null;
    }
    return &plugins_data[index];
}

pub fn getByName(_: *const PluginArray, name: []const u8) ?*Plugin {
    for (&plugins_data) |*plugin| {
        if (std.mem.eql(u8, plugin._name, name)) {
            return plugin;
        }
    }
    return null;
}

pub const MimeTypeArray = struct {
    _pad: bool = false,

    pub fn length(_: *const MimeTypeArray) usize {
        return mime_types_data.len;
    }

    pub fn getAtIndex(_: *const MimeTypeArray, index: usize) ?*MimeType {
        if (index >= mime_types_data.len) {
            return null;
        }
        return &mime_types_data[index];
    }

    pub fn getByName(_: *const MimeTypeArray, name: []const u8) ?*MimeType {
        for (&mime_types_data) |*mime_type| {
            if (std.mem.eql(u8, mime_type._type, name)) {
                return mime_type;
            }
        }
        return null;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(MimeTypeArray);

        pub const Meta = struct {
            pub const name = "MimeTypeArray";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const length = bridge.accessor(MimeTypeArray.length, null, .{});
        pub const @"[int]" = bridge.indexed(MimeTypeArray.getAtIndex, .{ .null_as_undefined = true });
        pub const @"[str]" = bridge.namedIndexed(MimeTypeArray.getByName, null, null, .{ .null_as_undefined = true });
        pub const item = bridge.function(_item, .{});
        pub const namedItem = bridge.function(MimeTypeArray.getByName, .{});

        fn _item(self: *const MimeTypeArray, index: i32) ?*MimeType {
            if (index < 0) {
                return null;
            }
            return self.getAtIndex(@intCast(index));
        }
    };
};

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

    pub fn length(_: *const Plugin) usize {
        return mime_types_data.len;
    }

    pub fn getAtIndex(_: *const Plugin, index: usize) ?*MimeType {
        if (index >= mime_types_data.len) {
            return null;
        }
        return &mime_types_data[index];
    }

    pub fn getByType(_: *const Plugin, mime_type: []const u8) ?*MimeType {
        for (&mime_types_data) |*mime| {
            if (std.mem.eql(u8, mime._type, mime_type)) {
                return mime;
            }
        }
        return null;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(Plugin);
        pub const Meta = struct {
            pub const name = "Plugin";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const name = bridge.accessor(Plugin.getName, null, .{});
        pub const description = bridge.accessor(Plugin.getDescription, null, .{});
        pub const filename = bridge.accessor(Plugin.getFilename, null, .{});
        pub const length = bridge.accessor(Plugin.length, null, .{});
        pub const @"[int]" = bridge.indexed(Plugin.getAtIndex, .{ .null_as_undefined = true });
        pub const @"[str]" = bridge.namedIndexed(Plugin.getByType, null, null, .{ .null_as_undefined = true });
        pub const item = bridge.function(_item, .{});
        pub const namedItem = bridge.function(Plugin.getByType, .{});

        fn _item(self: *const Plugin, index: i32) ?*MimeType {
            if (index < 0) {
                return null;
            }
            return self.getAtIndex(@intCast(index));
        }
    };
};

pub const MimeType = struct {
    _type: []const u8,
    _description: []const u8,
    _suffixes: []const u8,
    _enabled_plugin_index: u8,

    pub fn getType(self: *const MimeType) []const u8 {
        return self._type;
    }

    pub fn getDescription(self: *const MimeType) []const u8 {
        return self._description;
    }

    pub fn getSuffixes(self: *const MimeType) []const u8 {
        return self._suffixes;
    }

    pub fn getEnabledPlugin(self: *const MimeType) *Plugin {
        return &plugins_data[self._enabled_plugin_index];
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
        pub const enabledPlugin = bridge.accessor(MimeType.getEnabledPlugin, null, .{});
    };
};

pub const JsApi = struct {
    pub const bridge = js.Bridge(PluginArray);

    pub const Meta = struct {
        pub const name = "PluginArray";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const length = bridge.accessor(PluginArray.length, null, .{});
    pub const refresh = bridge.function(PluginArray.refresh, .{});
    pub const @"[int]" = bridge.indexed(PluginArray.getAtIndex, .{ .null_as_undefined = true });
    pub const @"[str]" = bridge.namedIndexed(PluginArray.getByName, null, null, .{ .null_as_undefined = true });
    pub const item = bridge.function(_item, .{});
    pub const namedItem = bridge.function(PluginArray.getByName, .{});

    fn _item(self: *const PluginArray, index: i32) ?*Plugin {
        if (index < 0) {
            return null;
        }
        return self.getAtIndex(@intCast(index));
    }
};

var plugins_data = [_]Plugin{
    .{ ._name = "PDF Viewer", ._description = pdf_description, ._filename = pdf_filename },
    .{ ._name = "Chrome PDF Viewer", ._description = pdf_description, ._filename = pdf_filename },
    .{ ._name = "Chromium PDF Viewer", ._description = pdf_description, ._filename = pdf_filename },
    .{ ._name = "Microsoft Edge PDF Viewer", ._description = pdf_description, ._filename = pdf_filename },
    .{ ._name = "WebKit built-in PDF", ._description = pdf_description, ._filename = pdf_filename },
};

var mime_types_data = [_]MimeType{
    .{ ._type = "application/pdf", ._description = pdf_description, ._suffixes = "pdf", ._enabled_plugin_index = 0 },
    .{ ._type = "text/pdf", ._description = pdf_description, ._suffixes = "pdf", ._enabled_plugin_index = 0 },
};
