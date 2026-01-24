// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

const js = @import("../../js/js.zig");

/// TextMetrics interface represents the dimensions of a piece of text in the canvas.
/// https://developer.mozilla.org/en-US/docs/Web/API/TextMetrics
const TextMetrics = @This();

_width: f64,
_actual_bounding_box_left: f64,
_actual_bounding_box_right: f64,
_font_bounding_box_ascent: f64,
_font_bounding_box_descent: f64,
_actual_bounding_box_ascent: f64,
_actual_bounding_box_descent: f64,
_em_height_ascent: f64,
_em_height_descent: f64,
_hanging_baseline: f64,
_alphabetic_baseline: f64,
_ideographic_baseline: f64,

pub fn init(text: []const u8, font_size: f64) TextMetrics {
    // Approximate text width based on character count and font size
    // Average character width is roughly 0.5-0.6 of font size for most fonts
    const char_width_ratio: f64 = 0.55;
    const width = @as(f64, @floatFromInt(text.len)) * font_size * char_width_ratio;

    return TextMetrics{
        ._width = width,
        ._actual_bounding_box_left = 0.0,
        ._actual_bounding_box_right = width,
        ._font_bounding_box_ascent = font_size * 0.8,
        ._font_bounding_box_descent = font_size * 0.2,
        ._actual_bounding_box_ascent = font_size * 0.75,
        ._actual_bounding_box_descent = font_size * 0.15,
        ._em_height_ascent = font_size * 0.8,
        ._em_height_descent = font_size * 0.2,
        ._hanging_baseline = font_size * 0.7,
        ._alphabetic_baseline = 0.0,
        ._ideographic_baseline = font_size * -0.1,
    };
}

pub fn getWidth(self: *const TextMetrics) f64 {
    return self._width;
}

pub fn getActualBoundingBoxLeft(self: *const TextMetrics) f64 {
    return self._actual_bounding_box_left;
}

pub fn getActualBoundingBoxRight(self: *const TextMetrics) f64 {
    return self._actual_bounding_box_right;
}

pub fn getFontBoundingBoxAscent(self: *const TextMetrics) f64 {
    return self._font_bounding_box_ascent;
}

pub fn getFontBoundingBoxDescent(self: *const TextMetrics) f64 {
    return self._font_bounding_box_descent;
}

pub fn getActualBoundingBoxAscent(self: *const TextMetrics) f64 {
    return self._actual_bounding_box_ascent;
}

pub fn getActualBoundingBoxDescent(self: *const TextMetrics) f64 {
    return self._actual_bounding_box_descent;
}

pub fn getEmHeightAscent(self: *const TextMetrics) f64 {
    return self._em_height_ascent;
}

pub fn getEmHeightDescent(self: *const TextMetrics) f64 {
    return self._em_height_descent;
}

pub fn getHangingBaseline(self: *const TextMetrics) f64 {
    return self._hanging_baseline;
}

pub fn getAlphabeticBaseline(self: *const TextMetrics) f64 {
    return self._alphabetic_baseline;
}

pub fn getIdeographicBaseline(self: *const TextMetrics) f64 {
    return self._ideographic_baseline;
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(TextMetrics);

    pub const Meta = struct {
        pub const name = "TextMetrics";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const width = bridge.accessor(TextMetrics.getWidth, null, .{});
    pub const actualBoundingBoxLeft = bridge.accessor(TextMetrics.getActualBoundingBoxLeft, null, .{});
    pub const actualBoundingBoxRight = bridge.accessor(TextMetrics.getActualBoundingBoxRight, null, .{});
    pub const fontBoundingBoxAscent = bridge.accessor(TextMetrics.getFontBoundingBoxAscent, null, .{});
    pub const fontBoundingBoxDescent = bridge.accessor(TextMetrics.getFontBoundingBoxDescent, null, .{});
    pub const actualBoundingBoxAscent = bridge.accessor(TextMetrics.getActualBoundingBoxAscent, null, .{});
    pub const actualBoundingBoxDescent = bridge.accessor(TextMetrics.getActualBoundingBoxDescent, null, .{});
    pub const emHeightAscent = bridge.accessor(TextMetrics.getEmHeightAscent, null, .{});
    pub const emHeightDescent = bridge.accessor(TextMetrics.getEmHeightDescent, null, .{});
    pub const hangingBaseline = bridge.accessor(TextMetrics.getHangingBaseline, null, .{});
    pub const alphabeticBaseline = bridge.accessor(TextMetrics.getAlphabeticBaseline, null, .{});
    pub const ideographicBaseline = bridge.accessor(TextMetrics.getIdeographicBaseline, null, .{});
};
