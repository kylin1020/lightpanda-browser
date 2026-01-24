// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

const std = @import("std");
const js = @import("../../js/js.zig");
const Page = @import("../../Page.zig");

/// ImageData interface represents the underlying pixel data of an area of a canvas element.
/// https://developer.mozilla.org/en-US/docs/Web/API/ImageData
const ImageData = @This();

_width: u32,
_height: u32,
_color_space: []const u8 = "srgb",

pub const Options = struct {
    colorSpace: ?[]const u8 = null,
};

/// Constructor: new ImageData(width, height) or new ImageData(width, height, options)
pub fn constructor(width: u32, height: u32, options: ?Options, page: *Page) !*ImageData {
    const color_space = if (options) |o| o.colorSpace orelse "srgb" else "srgb";
    return page._factory.create(ImageData{
        ._width = width,
        ._height = height,
        ._color_space = color_space,
    });
}

pub fn getWidth(self: *const ImageData) u32 {
    return self._width;
}

pub fn getHeight(self: *const ImageData) u32 {
    return self._height;
}

pub fn getColorSpace(self: *const ImageData) []const u8 {
    return self._color_space;
}

/// Returns pixel data as Uint8ClampedArray.
/// For fingerprint protection, returns deterministic data.
pub fn getData(self: *const ImageData, page: *Page) !js.TypedArray(u8) {
    const size = self._width * self._height * 4; // RGBA
    const data = try page.call_arena.alloc(u8, size);

    // Fill with transparent black (default for new ImageData)
    @memset(data, 0);

    return js.TypedArray(u8){ .values = data };
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(ImageData);

    pub const Meta = struct {
        pub const name = "ImageData";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const constructor = bridge.constructor(ImageData.constructor, .{});
    pub const width = bridge.accessor(ImageData.getWidth, null, .{});
    pub const height = bridge.accessor(ImageData.getHeight, null, .{});
    pub const colorSpace = bridge.accessor(ImageData.getColorSpace, null, .{});
    pub const data = bridge.accessor(ImageData.getData, null, .{ .as_typed_array = true });
};
