// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

const DOMRectList = @This();

const std = @import("std");
const js = @import("../js/js.zig");
const Page = @import("../Page.zig");
const DOMRect = @import("DOMRect.zig");

_rects: []*DOMRect,

pub fn init(rects: []*DOMRect) DOMRectList {
    return DOMRectList{ ._rects = rects };
}

pub fn getLength(self: *const DOMRectList) u32 {
    return @intCast(self._rects.len);
}

pub fn item(self: *const DOMRectList, index: u32) ?*DOMRect {
    if (index >= self._rects.len) {
        return null;
    }
    return self._rects[index];
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(DOMRectList);

    pub const Meta = struct {
        pub const name = "DOMRectList";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const length = bridge.accessor(DOMRectList.getLength, null, .{});
    pub const @"[]" = bridge.indexed(DOMRectList.item, .{ .null_as_undefined = true });
    pub const @"item" = bridge.function(DOMRectList.item, .{});
};
