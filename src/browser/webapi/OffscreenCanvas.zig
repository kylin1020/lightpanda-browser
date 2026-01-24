// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

const std = @import("std");
const js = @import("../js/js.zig");
const Page = @import("../Page.zig");
const CanvasRenderingContext2D = @import("canvas/CanvasRenderingContext2D.zig");

pub fn registerTypes() []const type {
    return &.{
        OffscreenCanvas,
        Path2D,
        DOMMatrix,
        DOMMatrixReadOnly,
    };
}

/// OffscreenCanvas interface
/// https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas
pub const OffscreenCanvas = struct {
    _width: u32 = 300,
    _height: u32 = 150,
    _ctx: ?*CanvasRenderingContext2D = null,

    pub fn constructor(width: ?u32, height: ?u32, page: *Page) !*OffscreenCanvas {
        return page._factory.create(OffscreenCanvas{
            ._width = width orelse 300,
            ._height = height orelse 150,
        });
    }

    pub fn getWidth(self: *const OffscreenCanvas) u32 {
        return self._width;
    }

    pub fn setWidth(self: *OffscreenCanvas, value: u32) void {
        self._width = value;
    }

    pub fn getHeight(self: *const OffscreenCanvas) u32 {
        return self._height;
    }

    pub fn setHeight(self: *OffscreenCanvas, value: u32) void {
        self._height = value;
    }

    pub fn getContext(self: *OffscreenCanvas, context_type: []const u8, _: ?js.Object, page: *Page) !?*CanvasRenderingContext2D {
        _ = self;
        if (std.mem.eql(u8, context_type, "2d")) {
            // Return a new 2D context (without canvas reference since we're offscreen)
            return page._factory.create(CanvasRenderingContext2D{});
        }
        return null;
    }

    pub fn toDataURL(self: *const OffscreenCanvas, mime_type: ?[]const u8, page: *Page) ![]const u8 {
        const width = self._width;
        const height = self._height;
        const profile = page.fingerprintProfile();
        const seed = profile.canvas.seed;

        var hasher = std.hash.Fnv1a_64.init();
        hasher.update(seed);
        hasher.update(std.mem.asBytes(&width));
        hasher.update(std.mem.asBytes(&height));
        hasher.update("offscreen");
        if (mime_type) |mt| hasher.update(mt);
        const hash = hasher.final();

        const result_type = mime_type orelse "image/png";
        return try std.fmt.allocPrint(page.call_arena, "data:{s};base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=={x:0>16}", .{ result_type, hash });
    }

    pub fn transferToImageBitmap(_: *OffscreenCanvas) ?js.Object {
        return null;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(OffscreenCanvas);

        pub const Meta = struct {
            pub const name = "OffscreenCanvas";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(OffscreenCanvas.constructor, .{});
        pub const width = bridge.accessor(OffscreenCanvas.getWidth, OffscreenCanvas.setWidth, .{});
        pub const height = bridge.accessor(OffscreenCanvas.getHeight, OffscreenCanvas.setHeight, .{});
        pub const getContext = bridge.function(OffscreenCanvas.getContext, .{});
        pub const toDataURL = bridge.function(OffscreenCanvas.toDataURL, .{});
        pub const transferToImageBitmap = bridge.function(OffscreenCanvas.transferToImageBitmap, .{});
    };
};

/// Path2D interface for complex path drawing
/// https://developer.mozilla.org/en-US/docs/Web/API/Path2D
pub const Path2D = struct {
    _: u8 = 0,

    pub fn constructor(path: ?[]const u8, page: *Page) !*Path2D {
        _ = path;
        return page._factory.create(Path2D{});
    }

    pub fn addPath(_: *Path2D, _: *Path2D) void {}
    pub fn closePath(_: *Path2D) void {}
    pub fn moveTo(_: *Path2D, _: f64, _: f64) void {}
    pub fn lineTo(_: *Path2D, _: f64, _: f64) void {}
    pub fn bezierCurveTo(_: *Path2D, _: f64, _: f64, _: f64, _: f64, _: f64, _: f64) void {}
    pub fn quadraticCurveTo(_: *Path2D, _: f64, _: f64, _: f64, _: f64) void {}
    pub fn arc(_: *Path2D, _: f64, _: f64, _: f64, _: f64, _: f64, _: ?bool) void {}
    pub fn arcTo(_: *Path2D, _: f64, _: f64, _: f64, _: f64, _: f64) void {}
    pub fn ellipse(_: *Path2D, _: f64, _: f64, _: f64, _: f64, _: f64, _: f64, _: f64, _: ?bool) void {}
    pub fn rect(_: *Path2D, _: f64, _: f64, _: f64, _: f64) void {}
    pub fn roundRect(_: *Path2D, _: f64, _: f64, _: f64, _: f64, _: ?f64) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(Path2D);

        pub const Meta = struct {
            pub const name = "Path2D";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(Path2D.constructor, .{});
        pub const addPath = bridge.function(Path2D.addPath, .{});
        pub const closePath = bridge.function(Path2D.closePath, .{});
        pub const moveTo = bridge.function(Path2D.moveTo, .{});
        pub const lineTo = bridge.function(Path2D.lineTo, .{});
        pub const bezierCurveTo = bridge.function(Path2D.bezierCurveTo, .{});
        pub const quadraticCurveTo = bridge.function(Path2D.quadraticCurveTo, .{});
        pub const arc = bridge.function(Path2D.arc, .{});
        pub const arcTo = bridge.function(Path2D.arcTo, .{});
        pub const ellipse = bridge.function(Path2D.ellipse, .{});
        pub const rect = bridge.function(Path2D.rect, .{});
        pub const roundRect = bridge.function(Path2D.roundRect, .{});
    };
};

/// DOMMatrixReadOnly interface
/// https://developer.mozilla.org/en-US/docs/Web/API/DOMMatrixReadOnly
pub const DOMMatrixReadOnly = struct {
    a: f64 = 1, // m11
    b: f64 = 0, // m12
    c: f64 = 0, // m21
    d: f64 = 1, // m22
    e: f64 = 0, // m41 (translateX)
    f: f64 = 0, // m42 (translateY)
    m11: f64 = 1,
    m12: f64 = 0,
    m13: f64 = 0,
    m14: f64 = 0,
    m21: f64 = 0,
    m22: f64 = 1,
    m23: f64 = 0,
    m24: f64 = 0,
    m31: f64 = 0,
    m32: f64 = 0,
    m33: f64 = 1,
    m34: f64 = 0,
    m41: f64 = 0,
    m42: f64 = 0,
    m43: f64 = 0,
    m44: f64 = 1,

    pub fn getA(self: *const DOMMatrixReadOnly) f64 {
        return self.a;
    }
    pub fn getB(self: *const DOMMatrixReadOnly) f64 {
        return self.b;
    }
    pub fn getC(self: *const DOMMatrixReadOnly) f64 {
        return self.c;
    }
    pub fn getD(self: *const DOMMatrixReadOnly) f64 {
        return self.d;
    }
    pub fn getE(self: *const DOMMatrixReadOnly) f64 {
        return self.e;
    }
    pub fn getF(self: *const DOMMatrixReadOnly) f64 {
        return self.f;
    }
    pub fn getM11(self: *const DOMMatrixReadOnly) f64 {
        return self.m11;
    }
    pub fn getM12(self: *const DOMMatrixReadOnly) f64 {
        return self.m12;
    }
    pub fn getM13(self: *const DOMMatrixReadOnly) f64 {
        return self.m13;
    }
    pub fn getM14(self: *const DOMMatrixReadOnly) f64 {
        return self.m14;
    }
    pub fn getM21(self: *const DOMMatrixReadOnly) f64 {
        return self.m21;
    }
    pub fn getM22(self: *const DOMMatrixReadOnly) f64 {
        return self.m22;
    }
    pub fn getM23(self: *const DOMMatrixReadOnly) f64 {
        return self.m23;
    }
    pub fn getM24(self: *const DOMMatrixReadOnly) f64 {
        return self.m24;
    }
    pub fn getM31(self: *const DOMMatrixReadOnly) f64 {
        return self.m31;
    }
    pub fn getM32(self: *const DOMMatrixReadOnly) f64 {
        return self.m32;
    }
    pub fn getM33(self: *const DOMMatrixReadOnly) f64 {
        return self.m33;
    }
    pub fn getM34(self: *const DOMMatrixReadOnly) f64 {
        return self.m34;
    }
    pub fn getM41(self: *const DOMMatrixReadOnly) f64 {
        return self.m41;
    }
    pub fn getM42(self: *const DOMMatrixReadOnly) f64 {
        return self.m42;
    }
    pub fn getM43(self: *const DOMMatrixReadOnly) f64 {
        return self.m43;
    }
    pub fn getM44(self: *const DOMMatrixReadOnly) f64 {
        return self.m44;
    }

    pub fn getIs2D(_: *const DOMMatrixReadOnly) bool {
        return true;
    }

    pub fn getIsIdentity(self: *const DOMMatrixReadOnly) bool {
        return self.a == 1 and self.b == 0 and self.c == 0 and self.d == 1 and self.e == 0 and self.f == 0;
    }

    pub fn toFloat32Array(_: *const DOMMatrixReadOnly) []const f32 {
        return &.{ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    }

    pub fn toFloat64Array(_: *const DOMMatrixReadOnly) []const f64 {
        return &.{ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 };
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(DOMMatrixReadOnly);

        pub const Meta = struct {
            pub const name = "DOMMatrixReadOnly";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"a" = bridge.accessor(DOMMatrixReadOnly.getA, null, .{});
        pub const @"b" = bridge.accessor(DOMMatrixReadOnly.getB, null, .{});
        pub const @"c" = bridge.accessor(DOMMatrixReadOnly.getC, null, .{});
        pub const @"d" = bridge.accessor(DOMMatrixReadOnly.getD, null, .{});
        pub const @"e" = bridge.accessor(DOMMatrixReadOnly.getE, null, .{});
        pub const @"f" = bridge.accessor(DOMMatrixReadOnly.getF, null, .{});
        pub const @"m11" = bridge.accessor(DOMMatrixReadOnly.getM11, null, .{});
        pub const @"m12" = bridge.accessor(DOMMatrixReadOnly.getM12, null, .{});
        pub const @"m13" = bridge.accessor(DOMMatrixReadOnly.getM13, null, .{});
        pub const @"m14" = bridge.accessor(DOMMatrixReadOnly.getM14, null, .{});
        pub const @"m21" = bridge.accessor(DOMMatrixReadOnly.getM21, null, .{});
        pub const @"m22" = bridge.accessor(DOMMatrixReadOnly.getM22, null, .{});
        pub const @"m23" = bridge.accessor(DOMMatrixReadOnly.getM23, null, .{});
        pub const @"m24" = bridge.accessor(DOMMatrixReadOnly.getM24, null, .{});
        pub const @"m31" = bridge.accessor(DOMMatrixReadOnly.getM31, null, .{});
        pub const @"m32" = bridge.accessor(DOMMatrixReadOnly.getM32, null, .{});
        pub const @"m33" = bridge.accessor(DOMMatrixReadOnly.getM33, null, .{});
        pub const @"m34" = bridge.accessor(DOMMatrixReadOnly.getM34, null, .{});
        pub const @"m41" = bridge.accessor(DOMMatrixReadOnly.getM41, null, .{});
        pub const @"m42" = bridge.accessor(DOMMatrixReadOnly.getM42, null, .{});
        pub const @"m43" = bridge.accessor(DOMMatrixReadOnly.getM43, null, .{});
        pub const @"m44" = bridge.accessor(DOMMatrixReadOnly.getM44, null, .{});
        pub const is2D = bridge.accessor(DOMMatrixReadOnly.getIs2D, null, .{});
        pub const isIdentity = bridge.accessor(DOMMatrixReadOnly.getIsIdentity, null, .{});
        pub const toFloat32Array = bridge.function(DOMMatrixReadOnly.toFloat32Array, .{});
        pub const toFloat64Array = bridge.function(DOMMatrixReadOnly.toFloat64Array, .{});
    };
};

/// DOMMatrix interface (extends DOMMatrixReadOnly)
/// https://developer.mozilla.org/en-US/docs/Web/API/DOMMatrix
pub const DOMMatrix = struct {
    _: DOMMatrixReadOnly = DOMMatrixReadOnly{},

    pub fn constructor(init: ?[]const u8, page: *Page) !*DOMMatrix {
        _ = init;
        return page._factory.create(DOMMatrix{});
    }

    pub fn getA(self: *const DOMMatrix) f64 {
        return self._.a;
    }
    pub fn setA(self: *DOMMatrix, value: f64) void {
        self._.a = value;
        self._.m11 = value;
    }
    pub fn getB(self: *const DOMMatrix) f64 {
        return self._.b;
    }
    pub fn setB(self: *DOMMatrix, value: f64) void {
        self._.b = value;
        self._.m12 = value;
    }
    pub fn getC(self: *const DOMMatrix) f64 {
        return self._.c;
    }
    pub fn setC(self: *DOMMatrix, value: f64) void {
        self._.c = value;
        self._.m21 = value;
    }
    pub fn getD(self: *const DOMMatrix) f64 {
        return self._.d;
    }
    pub fn setD(self: *DOMMatrix, value: f64) void {
        self._.d = value;
        self._.m22 = value;
    }
    pub fn getE(self: *const DOMMatrix) f64 {
        return self._.e;
    }
    pub fn setE(self: *DOMMatrix, value: f64) void {
        self._.e = value;
        self._.m41 = value;
    }
    pub fn getF(self: *const DOMMatrix) f64 {
        return self._.f;
    }
    pub fn setF(self: *DOMMatrix, value: f64) void {
        self._.f = value;
        self._.m42 = value;
    }

    pub fn getIs2D(_: *const DOMMatrix) bool {
        return true;
    }

    pub fn getIsIdentity(self: *const DOMMatrix) bool {
        return self._.getIsIdentity();
    }

    pub fn invertSelf(self: *DOMMatrix) *DOMMatrix {
        return self;
    }

    pub fn multiplySelf(self: *DOMMatrix, _: ?js.Object) *DOMMatrix {
        return self;
    }

    pub fn preMultiplySelf(self: *DOMMatrix, _: ?js.Object) *DOMMatrix {
        return self;
    }

    pub fn translateSelf(self: *DOMMatrix, _: ?f64, _: ?f64, _: ?f64) *DOMMatrix {
        return self;
    }

    pub fn scaleSelf(self: *DOMMatrix, _: ?f64, _: ?f64, _: ?f64, _: ?f64, _: ?f64, _: ?f64) *DOMMatrix {
        return self;
    }

    pub fn rotateSelf(self: *DOMMatrix, _: ?f64, _: ?f64, _: ?f64) *DOMMatrix {
        return self;
    }

    pub fn rotateAxisAngleSelf(self: *DOMMatrix, _: ?f64, _: ?f64, _: ?f64, _: ?f64) *DOMMatrix {
        return self;
    }

    pub fn skewXSelf(self: *DOMMatrix, _: ?f64) *DOMMatrix {
        return self;
    }

    pub fn skewYSelf(self: *DOMMatrix, _: ?f64) *DOMMatrix {
        return self;
    }

    pub fn setMatrixValue(self: *DOMMatrix, _: []const u8) *DOMMatrix {
        return self;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(DOMMatrix);

        pub const Meta = struct {
            pub const name = "DOMMatrix";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(DOMMatrix.constructor, .{});
        pub const @"a" = bridge.accessor(DOMMatrix.getA, DOMMatrix.setA, .{});
        pub const @"b" = bridge.accessor(DOMMatrix.getB, DOMMatrix.setB, .{});
        pub const @"c" = bridge.accessor(DOMMatrix.getC, DOMMatrix.setC, .{});
        pub const @"d" = bridge.accessor(DOMMatrix.getD, DOMMatrix.setD, .{});
        pub const @"e" = bridge.accessor(DOMMatrix.getE, DOMMatrix.setE, .{});
        pub const @"f" = bridge.accessor(DOMMatrix.getF, DOMMatrix.setF, .{});
        pub const is2D = bridge.accessor(DOMMatrix.getIs2D, null, .{});
        pub const isIdentity = bridge.accessor(DOMMatrix.getIsIdentity, null, .{});
        pub const invertSelf = bridge.function(DOMMatrix.invertSelf, .{});
        pub const multiplySelf = bridge.function(DOMMatrix.multiplySelf, .{});
        pub const preMultiplySelf = bridge.function(DOMMatrix.preMultiplySelf, .{});
        pub const translateSelf = bridge.function(DOMMatrix.translateSelf, .{});
        pub const scaleSelf = bridge.function(DOMMatrix.scaleSelf, .{});
        pub const rotateSelf = bridge.function(DOMMatrix.rotateSelf, .{});
        pub const rotateAxisAngleSelf = bridge.function(DOMMatrix.rotateAxisAngleSelf, .{});
        pub const skewXSelf = bridge.function(DOMMatrix.skewXSelf, .{});
        pub const skewYSelf = bridge.function(DOMMatrix.skewYSelf, .{});
        pub const setMatrixValue = bridge.function(DOMMatrix.setMatrixValue, .{});
    };
};
