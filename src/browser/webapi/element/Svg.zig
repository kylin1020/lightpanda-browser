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

const String = @import("../../../string.zig").String;

const js = @import("../../js/js.zig");
const Page = @import("../../Page.zig");

const Node = @import("../Node.zig");
const Element = @import("../Element.zig");
const DOMRect = @import("../DOMRect.zig");

pub const Generic = @import("svg/Generic.zig");

const Svg = @This();
_type: Type,
_proto: *Element,
_tag_name: String, // Svg elements are case-preserving

pub const Type = union(enum) {
    svg,
    generic: *Generic,
};

pub fn is(self: *Svg, comptime T: type) ?*T {
    inline for (@typeInfo(Type).@"union".fields) |f| {
        if (@field(Type, f.name) == self._type) {
            if (f.type == T) {
                return &@field(self._type, f.name);
            }
            if (f.type == *T) {
                return @field(self._type, f.name);
            }
        }
    }
    return null;
}

pub fn asElement(self: *Svg) *Element {
    return self._proto;
}
pub fn asNode(self: *Svg) *Node {
    return self.asElement().asNode();
}

/// Returns the bounding box of the SVG element.
/// Returns a simple deterministic rect for fingerprint consistency.
pub fn getBBox(_: *Svg, page: *Page) !*DOMRect {
    // Return a deterministic bounding box for SVG elements
    // Real implementations would compute based on SVG content
    return page._factory.create(DOMRect{
        ._x = 0,
        ._y = 0,
        ._width = 100,
        ._height = 100,
    });
}

/// Returns the total length of the path (for SVGGeometryElement compatibility)
pub fn getTotalLength(_: *Svg) f64 {
    return 100.0; // Deterministic value for fingerprint consistency
}

/// Returns the computed text length (for SVGTextContentElement compatibility)
pub fn getComputedTextLength(_: *Svg) f64 {
    return 50.0; // Deterministic value for fingerprint consistency
}

/// Returns the number of characters (for SVGTextContentElement compatibility)
pub fn getNumberOfChars(_: *Svg) u32 {
    return 0;
}

/// Returns the extent of a character at the given index (for SVGTextContentElement)
pub fn getExtentOfChar(_: *Svg, _: u32, page: *Page) !*DOMRect {
    // Return a deterministic rect for fingerprint consistency
    return page._factory.create(DOMRect{
        ._x = 0,
        ._y = 0,
        ._width = 10,
        ._height = 14,
    });
}

/// Returns the start position of a character (for SVGTextContentElement)
pub fn getStartPositionOfChar(_: *Svg, _: u32, page: *Page) !*SVGPoint {
    return page._factory.create(SVGPoint{ ._x = 0, ._y = 0 });
}

/// Returns the end position of a character (for SVGTextContentElement)
pub fn getEndPositionOfChar(_: *Svg, _: u32, page: *Page) !*SVGPoint {
    return page._factory.create(SVGPoint{ ._x = 10, ._y = 0 });
}

/// Returns the rotation of a character (for SVGTextContentElement)
pub fn getRotationOfChar(_: *Svg, _: u32) f64 {
    return 0.0;
}

/// Returns the character index at a given point (for SVGTextContentElement)
pub fn getCharNumAtPosition(_: *Svg, _: ?*SVGPoint) i32 {
    return -1; // No character at position
}

/// Returns the length of a substring (for SVGTextContentElement)
pub fn getSubStringLength(_: *Svg, _: u32, _: u32) f64 {
    return 50.0; // Deterministic value
}

/// Selects a substring (for SVGTextContentElement)
pub fn selectSubString(_: *Svg, _: u32, _: u32) void {}

/// SVGPoint type for position methods
pub const SVGPoint = struct {
    _x: f64 = 0,
    _y: f64 = 0,

    pub fn getX(self: *const SVGPoint) f64 {
        return self._x;
    }

    pub fn getY(self: *const SVGPoint) f64 {
        return self._y;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SVGPoint);

        pub const Meta = struct {
            pub const name = "SVGPoint";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const x = bridge.accessor(SVGPoint.getX, null, .{});
        pub const y = bridge.accessor(SVGPoint.getY, null, .{});
    };
};

pub fn registerTypes() []const type {
    return &.{
        Svg,
        SVGPoint,
    };
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(Svg);

    pub const Meta = struct {
        pub const name = "SVGElement";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const getBBox = bridge.function(Svg.getBBox, .{});
    pub const getTotalLength = bridge.function(Svg.getTotalLength, .{});
    pub const getComputedTextLength = bridge.function(Svg.getComputedTextLength, .{});
    pub const getNumberOfChars = bridge.function(Svg.getNumberOfChars, .{});
    pub const getExtentOfChar = bridge.function(Svg.getExtentOfChar, .{});
    pub const getStartPositionOfChar = bridge.function(Svg.getStartPositionOfChar, .{});
    pub const getEndPositionOfChar = bridge.function(Svg.getEndPositionOfChar, .{});
    pub const getRotationOfChar = bridge.function(Svg.getRotationOfChar, .{});
    pub const getCharNumAtPosition = bridge.function(Svg.getCharNumAtPosition, .{});
    pub const getSubStringLength = bridge.function(Svg.getSubStringLength, .{});
    pub const selectSubString = bridge.function(Svg.selectSubString, .{});
};

const testing = @import("../../../testing.zig");
test "WebApi: Svg" {
    try testing.htmlRunner("element/svg", .{});
}
