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
const js = @import("../../../js/js.zig");
const Page = @import("../../../Page.zig");
const Node = @import("../../Node.zig");
const Element = @import("../../Element.zig");
const HtmlElement = @import("../Html.zig");

const CanvasRenderingContext2D = @import("../../canvas/CanvasRenderingContext2D.zig");
const WebGLRenderingContext = @import("../../canvas/WebGLRenderingContext.zig");

const Canvas = @This();
_proto: *HtmlElement,

pub fn asElement(self: *Canvas) *Element {
    return self._proto._proto;
}
pub fn asConstElement(self: *const Canvas) *const Element {
    return self._proto._proto;
}
pub fn asNode(self: *Canvas) *Node {
    return self.asElement().asNode();
}

pub fn getWidth(self: *const Canvas) u32 {
    const attr = self.asConstElement().getAttributeSafe("width") orelse return 300;
    return std.fmt.parseUnsigned(u32, attr, 10) catch 300;
}

pub fn setWidth(self: *Canvas, value: u32, page: *Page) !void {
    const str = try std.fmt.allocPrint(page.call_arena, "{d}", .{value});
    try self.asElement().setAttributeSafe("width", str, page);
}

pub fn getHeight(self: *const Canvas) u32 {
    const attr = self.asConstElement().getAttributeSafe("height") orelse return 150;
    return std.fmt.parseUnsigned(u32, attr, 10) catch 150;
}

pub fn setHeight(self: *Canvas, value: u32, page: *Page) !void {
    const str = try std.fmt.allocPrint(page.call_arena, "{d}", .{value});
    try self.asElement().setAttributeSafe("height", str, page);
}

/// Since there's no base class rendering contextes inherit from,
/// we're using tagged union.
const DrawingContext = union(enum) {
    @"2d": *CanvasRenderingContext2D,
    webgl: *WebGLRenderingContext,
};

pub fn getContext(self: *Canvas, context_type: []const u8, _: ?js.Object, page: *Page) !?DrawingContext {
    if (std.mem.eql(u8, context_type, "2d")) {
        const ctx = try page._factory.create(CanvasRenderingContext2D{ ._canvas = self });
        return .{ .@"2d" = ctx };
    }

    if (std.mem.eql(u8, context_type, "webgl") or std.mem.eql(u8, context_type, "experimental-webgl")) {
        const ctx = try page._factory.create(WebGLRenderingContext{ ._canvas = self });
        return .{ .webgl = ctx };
    }

    return null;
}

/// Returns a data URL containing a representation of the image.
/// The fingerprint is deterministic based on the profile seed.
pub fn toDataURL(self: *const Canvas, mime_type: ?[]const u8, page: *Page) ![]const u8 {
    const width = self.getWidth();
    const height = self.getHeight();
    const profile = page.fingerprintProfile();
    const seed = profile.canvas.seed;

    // Generate a deterministic "fingerprint" based on canvas dimensions and seed
    // This creates a stable but unique-per-profile PNG data URL
    var hasher = std.hash.Fnv1a_64.init();
    hasher.update(seed);
    hasher.update(std.mem.asBytes(&width));
    hasher.update(std.mem.asBytes(&height));
    if (mime_type) |mt| hasher.update(mt);
    const hash = hasher.final();

    // Generate a minimal valid PNG with the hash embedded in pixel data
    // For simplicity, return a data URL with hash-based content
    const result_type = mime_type orelse "image/png";
    if (std.mem.eql(u8, result_type, "image/png") or std.mem.startsWith(u8, result_type, "image/png")) {
        // Return a stable PNG-like data URL
        return try std.fmt.allocPrint(page.call_arena, "data:image/png;base64,{s}{x:0>16}", .{ "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==", hash });
    } else if (std.mem.eql(u8, result_type, "image/jpeg") or std.mem.startsWith(u8, result_type, "image/jpeg")) {
        return try std.fmt.allocPrint(page.call_arena, "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/{x:0>16}", .{hash});
    } else if (std.mem.eql(u8, result_type, "image/webp") or std.mem.startsWith(u8, result_type, "image/webp")) {
        return try std.fmt.allocPrint(page.call_arena, "data:image/webp;base64,UklGRh4AAABXRUJQVlA4TBEAAAAvAAAAAAfQ//73v/+BiOh/{x:0>16}", .{hash});
    }
    // Default to PNG
    return try std.fmt.allocPrint(page.call_arena, "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=={x:0>16}", .{hash});
}

/// Creates a Blob object representing the image contained in the canvas.
/// The callback receives the blob when it's ready.
pub fn toBlob(self: *const Canvas, callback: js.Function, mime_type: ?[]const u8, page: *Page) !void {
    // Generate the data URL and create a Blob-like response
    // In a real implementation this would create an actual Blob
    // For fingerprint testing, we just call the callback with a stub blob
    const data_url = try self.toDataURL(mime_type, page);

    // Create a minimal Blob object
    const blob = try page._factory.create(CanvasBlob{
        ._size = data_url.len,
        ._type = mime_type orelse "image/png",
    });

    // Call the callback with the blob
    _ = try callback.call(void, .{blob});
}

/// Minimal Blob type for toBlob callback
pub const CanvasBlob = struct {
    _size: usize,
    _type: []const u8,

    pub fn getSize(self: *const CanvasBlob) usize {
        return self._size;
    }

    pub fn getType(self: *const CanvasBlob) []const u8 {
        return self._type;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(CanvasBlob);

        pub const Meta = struct {
            pub const name = "Blob";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const size = bridge.accessor(CanvasBlob.getSize, null, .{});
        pub const @"type" = bridge.accessor(CanvasBlob.getType, null, .{});
    };
};

pub fn registerTypes() []const type {
    return &.{
        Canvas,
        CanvasBlob,
    };
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(Canvas);

    pub const Meta = struct {
        pub const name = "HTMLCanvasElement";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const width = bridge.accessor(Canvas.getWidth, Canvas.setWidth, .{});
    pub const height = bridge.accessor(Canvas.getHeight, Canvas.setHeight, .{});
    pub const getContext = bridge.function(Canvas.getContext, .{});
    pub const toDataURL = bridge.function(Canvas.toDataURL, .{});
    pub const toBlob = bridge.function(Canvas.toBlob, .{});
};
