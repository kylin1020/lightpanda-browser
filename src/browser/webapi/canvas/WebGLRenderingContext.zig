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

const js = @import("../../js/js.zig");
const Page = @import("../../Page.zig");
const HtmlCanvasElement = @import("../element/html/Canvas.zig");

pub fn registerTypes() []const type {
    return &.{
        WebGLRenderingContext,
        // Extension types should be runtime generated. We might want
        // to revisit this.
        Extension.Type.WEBGL_debug_renderer_info,
        Extension.Type.WEBGL_lose_context,
        // Additional WebGL types
        WebGLContextAttributes,
        WebGLShaderPrecisionFormat,
        WebGLShader,
        WebGLProgram,
        WebGLBuffer,
        WebGLTexture,
        WebGLFramebuffer,
        WebGLRenderbuffer,
        WebGLUniformLocation,
        WebGLActiveInfo,
    };
}

const WebGLRenderingContext = @This();

/// Reference to the parent canvas element.
_canvas: *HtmlCanvasElement = undefined,

/// Returns the canvas element that created this context.
pub fn getCanvas(self: *const WebGLRenderingContext) *HtmlCanvasElement {
    return self._canvas;
}

// WebGL constants - these are accessed as properties like gl.VERTEX_SHADER
pub const VERTEX_SHADER: u32 = 0x8B31;
pub const FRAGMENT_SHADER: u32 = 0x8B30;
pub const COMPILE_STATUS: u32 = 0x8B81;
pub const LINK_STATUS: u32 = 0x8B82;
pub const ARRAY_BUFFER: u32 = 0x8892;
pub const ELEMENT_ARRAY_BUFFER: u32 = 0x8893;
pub const STATIC_DRAW: u32 = 0x88E4;
pub const DYNAMIC_DRAW: u32 = 0x88E8;
pub const COLOR_BUFFER_BIT: u32 = 0x4000;
pub const DEPTH_BUFFER_BIT: u32 = 0x100;
pub const STENCIL_BUFFER_BIT: u32 = 0x400;
pub const TRIANGLES: u32 = 0x4;
pub const TRIANGLE_STRIP: u32 = 0x5;
pub const TRIANGLE_FAN: u32 = 0x6;
pub const POINTS: u32 = 0x0;
pub const LINES: u32 = 0x1;
pub const LINE_STRIP: u32 = 0x3;
pub const LINE_LOOP: u32 = 0x2;
pub const FLOAT: u32 = 0x1406;
pub const UNSIGNED_BYTE: u32 = 0x1401;
pub const UNSIGNED_SHORT: u32 = 0x1403;
pub const UNSIGNED_INT: u32 = 0x1405;
pub const TEXTURE_2D: u32 = 0x0DE1;
pub const TEXTURE0: u32 = 0x84C0;
pub const RGBA: u32 = 0x1908;
pub const RGB: u32 = 0x1907;
pub const NEAREST: u32 = 0x2600;
pub const LINEAR: u32 = 0x2601;
pub const TEXTURE_MIN_FILTER: u32 = 0x2801;
pub const TEXTURE_MAG_FILTER: u32 = 0x2800;
pub const TEXTURE_WRAP_S: u32 = 0x2802;
pub const TEXTURE_WRAP_T: u32 = 0x2803;
pub const CLAMP_TO_EDGE: u32 = 0x812F;
pub const REPEAT: u32 = 0x2901;
pub const FRAMEBUFFER: u32 = 0x8D40;
pub const RENDERBUFFER: u32 = 0x8D41;
pub const COLOR_ATTACHMENT0: u32 = 0x8CE0;
pub const DEPTH_ATTACHMENT: u32 = 0x8D00;
pub const DEPTH_COMPONENT16: u32 = 0x81A5;
pub const FRAMEBUFFER_COMPLETE: u32 = 0x8CD5;
pub const DEPTH_TEST: u32 = 0x0B71;
pub const BLEND: u32 = 0x0BE2;
pub const CULL_FACE: u32 = 0x0B44;
pub const SRC_ALPHA: u32 = 0x0302;
pub const ONE_MINUS_SRC_ALPHA: u32 = 0x0303;
pub const FUNC_ADD: u32 = 0x8006;
pub const NO_ERROR: u32 = 0x0;
pub const HIGH_FLOAT: u32 = 0x8DF2;
pub const MEDIUM_FLOAT: u32 = 0x8DF1;
pub const LOW_FLOAT: u32 = 0x8DF0;
pub const HIGH_INT: u32 = 0x8DF5;
pub const MEDIUM_INT: u32 = 0x8DF4;
pub const LOW_INT: u32 = 0x8DF3;

// Constant accessor functions (needed for bridge)
fn getVertexShader(_: *const WebGLRenderingContext) u32 { return VERTEX_SHADER; }
fn getFragmentShader(_: *const WebGLRenderingContext) u32 { return FRAGMENT_SHADER; }
fn getCompileStatus(_: *const WebGLRenderingContext) u32 { return COMPILE_STATUS; }
fn getLinkStatus(_: *const WebGLRenderingContext) u32 { return LINK_STATUS; }
fn getArrayBuffer(_: *const WebGLRenderingContext) u32 { return ARRAY_BUFFER; }
fn getElementArrayBuffer(_: *const WebGLRenderingContext) u32 { return ELEMENT_ARRAY_BUFFER; }
fn getStaticDraw(_: *const WebGLRenderingContext) u32 { return STATIC_DRAW; }
fn getDynamicDraw(_: *const WebGLRenderingContext) u32 { return DYNAMIC_DRAW; }
fn getColorBufferBit(_: *const WebGLRenderingContext) u32 { return COLOR_BUFFER_BIT; }
fn getDepthBufferBit(_: *const WebGLRenderingContext) u32 { return DEPTH_BUFFER_BIT; }
fn getStencilBufferBit(_: *const WebGLRenderingContext) u32 { return STENCIL_BUFFER_BIT; }
fn getTriangles(_: *const WebGLRenderingContext) u32 { return TRIANGLES; }
fn getTriangleStrip(_: *const WebGLRenderingContext) u32 { return TRIANGLE_STRIP; }
fn getTriangleFan(_: *const WebGLRenderingContext) u32 { return TRIANGLE_FAN; }
fn getPoints(_: *const WebGLRenderingContext) u32 { return POINTS; }
fn getLines(_: *const WebGLRenderingContext) u32 { return LINES; }
fn getLineStrip(_: *const WebGLRenderingContext) u32 { return LINE_STRIP; }
fn getLineLoop(_: *const WebGLRenderingContext) u32 { return LINE_LOOP; }
fn getFloat(_: *const WebGLRenderingContext) u32 { return FLOAT; }
fn getUnsignedByte(_: *const WebGLRenderingContext) u32 { return UNSIGNED_BYTE; }
fn getUnsignedShort(_: *const WebGLRenderingContext) u32 { return UNSIGNED_SHORT; }
fn getUnsignedInt(_: *const WebGLRenderingContext) u32 { return UNSIGNED_INT; }
fn getTexture2d(_: *const WebGLRenderingContext) u32 { return TEXTURE_2D; }
fn getTexture0(_: *const WebGLRenderingContext) u32 { return TEXTURE0; }
fn getRgba(_: *const WebGLRenderingContext) u32 { return RGBA; }
fn getRgb(_: *const WebGLRenderingContext) u32 { return RGB; }
fn getNearest(_: *const WebGLRenderingContext) u32 { return NEAREST; }
fn getLinear(_: *const WebGLRenderingContext) u32 { return LINEAR; }
fn getTextureMinFilter(_: *const WebGLRenderingContext) u32 { return TEXTURE_MIN_FILTER; }
fn getTextureMagFilter(_: *const WebGLRenderingContext) u32 { return TEXTURE_MAG_FILTER; }
fn getTextureWrapS(_: *const WebGLRenderingContext) u32 { return TEXTURE_WRAP_S; }
fn getTextureWrapT(_: *const WebGLRenderingContext) u32 { return TEXTURE_WRAP_T; }
fn getClampToEdge(_: *const WebGLRenderingContext) u32 { return CLAMP_TO_EDGE; }
fn getRepeat(_: *const WebGLRenderingContext) u32 { return REPEAT; }
fn getFramebuffer(_: *const WebGLRenderingContext) u32 { return FRAMEBUFFER; }
fn getRenderbuffer(_: *const WebGLRenderingContext) u32 { return RENDERBUFFER; }
fn getColorAttachment0(_: *const WebGLRenderingContext) u32 { return COLOR_ATTACHMENT0; }
fn getDepthAttachment(_: *const WebGLRenderingContext) u32 { return DEPTH_ATTACHMENT; }
fn getDepthComponent16(_: *const WebGLRenderingContext) u32 { return DEPTH_COMPONENT16; }
fn getFramebufferComplete(_: *const WebGLRenderingContext) u32 { return FRAMEBUFFER_COMPLETE; }
fn getDepthTest(_: *const WebGLRenderingContext) u32 { return DEPTH_TEST; }
fn getBlend(_: *const WebGLRenderingContext) u32 { return BLEND; }
fn getCullFace(_: *const WebGLRenderingContext) u32 { return CULL_FACE; }
fn getSrcAlpha(_: *const WebGLRenderingContext) u32 { return SRC_ALPHA; }
fn getOneMinusSrcAlpha(_: *const WebGLRenderingContext) u32 { return ONE_MINUS_SRC_ALPHA; }
fn getFuncAdd(_: *const WebGLRenderingContext) u32 { return FUNC_ADD; }
fn getNoError(_: *const WebGLRenderingContext) u32 { return NO_ERROR; }
fn getHighFloat(_: *const WebGLRenderingContext) u32 { return HIGH_FLOAT; }
fn getMediumFloat(_: *const WebGLRenderingContext) u32 { return MEDIUM_FLOAT; }
fn getLowFloat(_: *const WebGLRenderingContext) u32 { return LOW_FLOAT; }
fn getHighInt(_: *const WebGLRenderingContext) u32 { return HIGH_INT; }
fn getMediumInt(_: *const WebGLRenderingContext) u32 { return MEDIUM_INT; }
fn getLowInt(_: *const WebGLRenderingContext) u32 { return LOW_INT; }

/// On Chrome and Safari, a call to `getSupportedExtensions` returns total of 39.
/// The reference for it lists lesser number of extensions:
/// https://developer.mozilla.org/en-US/docs/Web/API/WebGL_API/Using_Extensions#extension_list
pub const Extension = union(enum) {
    ANGLE_instanced_arrays: void,
    EXT_blend_minmax: void,
    EXT_clip_control: void,
    EXT_color_buffer_half_float: void,
    EXT_depth_clamp: void,
    EXT_disjoint_timer_query: void,
    EXT_float_blend: void,
    EXT_frag_depth: void,
    EXT_polygon_offset_clamp: void,
    EXT_shader_texture_lod: void,
    EXT_texture_compression_bptc: void,
    EXT_texture_compression_rgtc: void,
    EXT_texture_filter_anisotropic: void,
    EXT_texture_mirror_clamp_to_edge: void,
    EXT_sRGB: void,
    KHR_parallel_shader_compile: void,
    OES_element_index_uint: void,
    OES_fbo_render_mipmap: void,
    OES_standard_derivatives: void,
    OES_texture_float: void,
    OES_texture_float_linear: void,
    OES_texture_half_float: void,
    OES_texture_half_float_linear: void,
    OES_vertex_array_object: void,
    WEBGL_blend_func_extended: void,
    WEBGL_color_buffer_float: void,
    WEBGL_compressed_texture_astc: void,
    WEBGL_compressed_texture_etc: void,
    WEBGL_compressed_texture_etc1: void,
    WEBGL_compressed_texture_pvrtc: void,
    WEBGL_compressed_texture_s3tc: void,
    WEBGL_compressed_texture_s3tc_srgb: void,
    WEBGL_debug_renderer_info: *Type.WEBGL_debug_renderer_info,
    WEBGL_debug_shaders: void,
    WEBGL_depth_texture: void,
    WEBGL_draw_buffers: void,
    WEBGL_lose_context: *Type.WEBGL_lose_context,
    WEBGL_multi_draw: void,
    WEBGL_polygon_mode: void,

    /// Reified enum type from the fields of this union.
    const Kind = blk: {
        const info = @typeInfo(Extension).@"union";
        const fields = info.fields;
        var items: [fields.len]std.builtin.Type.EnumField = undefined;
        for (fields, 0..) |field, i| {
            items[i] = .{ .name = field.name, .value = i };
        }

        break :blk @Type(.{
            .@"enum" = .{
                .tag_type = std.math.IntFittingRange(0, if (fields.len == 0) 0 else fields.len - 1),
                .fields = &items,
                .decls = &.{},
                .is_exhaustive = true,
            },
        });
    };

    /// Returns the `Extension.Kind` by its name.
    fn find(name: []const u8) ?Kind {
        // Just to make you really sad, this function has to be case-insensitive.
        // So here we copy what's being done in `std.meta.stringToEnum` but replace
        // the comparison function.
        const kvs = comptime build_kvs: {
            const T = Extension.Kind;
            const EnumKV = struct { []const u8, T };
            var kvs_array: [@typeInfo(T).@"enum".fields.len]EnumKV = undefined;
            for (@typeInfo(T).@"enum".fields, 0..) |enumField, i| {
                kvs_array[i] = .{ enumField.name, @field(T, enumField.name) };
            }
            break :build_kvs kvs_array[0..];
        };
        const Map = std.StaticStringMapWithEql(Extension.Kind, std.static_string_map.eqlAsciiIgnoreCase);
        const map = Map.initComptime(kvs);
        return map.get(name);
    }

    /// Extension types.
    pub const Type = struct {
        pub const WEBGL_debug_renderer_info = struct {
            _: u8 = 0,
            pub const UNMASKED_VENDOR_WEBGL: u64 = 0x9245;
            pub const UNMASKED_RENDERER_WEBGL: u64 = 0x9246;

            pub fn getUnmaskedVendorWebGL(_: *const WEBGL_debug_renderer_info) u64 {
                return UNMASKED_VENDOR_WEBGL;
            }

            pub fn getUnmaskedRendererWebGL(_: *const WEBGL_debug_renderer_info) u64 {
                return UNMASKED_RENDERER_WEBGL;
            }

            pub const JsApi = struct {
                pub const bridge = js.Bridge(WEBGL_debug_renderer_info);

                pub const Meta = struct {
                    pub const name = "WEBGL_debug_renderer_info";

                    pub const prototype_chain = bridge.prototypeChain();
                    pub var class_id: bridge.ClassId = undefined;
                };

                pub const UNMASKED_VENDOR_WEBGL = bridge.accessor(WEBGL_debug_renderer_info.getUnmaskedVendorWebGL, null, .{});
                pub const UNMASKED_RENDERER_WEBGL = bridge.accessor(WEBGL_debug_renderer_info.getUnmaskedRendererWebGL, null, .{});
            };
        };

        pub const WEBGL_lose_context = struct {
            _: u8 = 0,
            pub fn loseContext(_: *const WEBGL_lose_context) void {}
            pub fn restoreContext(_: *const WEBGL_lose_context) void {}

            pub const JsApi = struct {
                pub const bridge = js.Bridge(WEBGL_lose_context);

                pub const Meta = struct {
                    pub const name = "WEBGL_lose_context";

                    pub const prototype_chain = bridge.prototypeChain();
                    pub var class_id: bridge.ClassId = undefined;
                };

                pub const loseContext = bridge.function(WEBGL_lose_context.loseContext, .{});
                pub const restoreContext = bridge.function(WEBGL_lose_context.restoreContext, .{});
            };
        };
    };
};

/// This actually takes "GLenum" which, in fact, is a fancy way to say number.
/// Return value also depends on what's being passed as `pname`; we don't really
/// support any though.
pub fn getParameter(_: *const WebGLRenderingContext, pname: u32, page: *Page) []const u8 {
    const profile = page.fingerprintProfile().webgl;
    return switch (pname) {
        Extension.Type.WEBGL_debug_renderer_info.UNMASKED_VENDOR_WEBGL => profile.vendor,
        Extension.Type.WEBGL_debug_renderer_info.UNMASKED_RENDERER_WEBGL => profile.renderer,
        else => "",
    };
}

/// Enables a WebGL extension.
pub fn getExtension(_: *const WebGLRenderingContext, name: []const u8, page: *Page) !?Extension {
    const tag = Extension.find(name) orelse return null;

    return switch (tag) {
        .WEBGL_debug_renderer_info => {
            const info = try page._factory.create(Extension.Type.WEBGL_debug_renderer_info{});
            return .{ .WEBGL_debug_renderer_info = info };
        },
        .WEBGL_lose_context => {
            const ctx = try page._factory.create(Extension.Type.WEBGL_lose_context{});
            return .{ .WEBGL_lose_context = ctx };
        },
        inline else => |comptime_enum| @unionInit(Extension, @tagName(comptime_enum), {}),
    };
}

/// Returns a list of all the supported WebGL extensions.
pub fn getSupportedExtensions(_: *const WebGLRenderingContext) []const []const u8 {
    return std.meta.fieldNames(Extension.Kind);
}

/// Returns the context attributes used to create the context.
pub fn getContextAttributes(_: *const WebGLRenderingContext) WebGLContextAttributes {
    return WebGLContextAttributes{};
}

/// Returns whether the context is lost.
pub fn isContextLost(_: *const WebGLRenderingContext) bool {
    return false;
}

/// Returns shader precision format information - used by fingerprinting scripts.
pub fn getShaderPrecisionFormat(_: *const WebGLRenderingContext, _: u32, _: u32, page: *Page) !*WebGLShaderPrecisionFormat {
    return page._factory.create(WebGLShaderPrecisionFormat{});
}

/// Clears the specified buffers.
pub fn clear(_: *WebGLRenderingContext, _: u32) void {}

/// Clears the color buffer.
pub fn clearColor(_: *WebGLRenderingContext, _: f32, _: f32, _: f32, _: f32) void {}

/// Clears the depth buffer.
pub fn clearDepth(_: *WebGLRenderingContext, _: f32) void {}

/// Clears the stencil buffer.
pub fn clearStencil(_: *WebGLRenderingContext, _: i32) void {}

/// Enables a capability.
pub fn enable(_: *WebGLRenderingContext, _: u32) void {}

/// Disables a capability.
pub fn disable(_: *WebGLRenderingContext, _: u32) void {}

/// Creates a shader.
pub fn createShader(_: *WebGLRenderingContext, _: u32, page: *Page) !*WebGLShader {
    return page._factory.create(WebGLShader{});
}

/// Creates a program.
pub fn createProgram(_: *WebGLRenderingContext, page: *Page) !*WebGLProgram {
    return page._factory.create(WebGLProgram{});
}

/// Creates a buffer.
pub fn createBuffer(_: *WebGLRenderingContext, page: *Page) !*WebGLBuffer {
    return page._factory.create(WebGLBuffer{});
}

/// Creates a texture.
pub fn createTexture(_: *WebGLRenderingContext, page: *Page) !*WebGLTexture {
    return page._factory.create(WebGLTexture{});
}

/// Creates a framebuffer.
pub fn createFramebuffer(_: *WebGLRenderingContext, page: *Page) !*WebGLFramebuffer {
    return page._factory.create(WebGLFramebuffer{});
}

/// Creates a renderbuffer.
pub fn createRenderbuffer(_: *WebGLRenderingContext, page: *Page) !*WebGLRenderbuffer {
    return page._factory.create(WebGLRenderbuffer{});
}

/// Deletes a shader.
pub fn deleteShader(_: *WebGLRenderingContext, _: ?*WebGLShader) void {}

/// Deletes a program.
pub fn deleteProgram(_: *WebGLRenderingContext, _: ?*WebGLProgram) void {}

/// Deletes a buffer.
pub fn deleteBuffer(_: *WebGLRenderingContext, _: ?*WebGLBuffer) void {}

/// Deletes a texture.
pub fn deleteTexture(_: *WebGLRenderingContext, _: ?*WebGLTexture) void {}

/// Deletes a framebuffer.
pub fn deleteFramebuffer(_: *WebGLRenderingContext, _: ?*WebGLFramebuffer) void {}

/// Deletes a renderbuffer.
pub fn deleteRenderbuffer(_: *WebGLRenderingContext, _: ?*WebGLRenderbuffer) void {}

/// Attaches a shader to a program.
pub fn attachShader(_: *WebGLRenderingContext, _: ?*WebGLProgram, _: ?*WebGLShader) void {}

/// Links a program.
pub fn linkProgram(_: *WebGLRenderingContext, _: ?*WebGLProgram) void {}

/// Uses a program.
pub fn useProgram(_: *WebGLRenderingContext, _: ?*WebGLProgram) void {}

/// Sets the shader source.
pub fn shaderSource(_: *WebGLRenderingContext, _: ?*WebGLShader, _: []const u8) void {}

/// Compiles a shader.
pub fn compileShader(_: *WebGLRenderingContext, _: ?*WebGLShader) void {}

/// Gets a shader parameter.
pub fn getShaderParameter(_: *const WebGLRenderingContext, _: ?*WebGLShader, pname: u32) bool {
    // Common queries: COMPILE_STATUS (0x8B81), DELETE_STATUS (0x8B80)
    _ = pname;
    return true;
}

/// Gets a program parameter.
pub fn getProgramParameter(_: *const WebGLRenderingContext, _: ?*WebGLProgram, pname: u32) bool {
    // Common queries: LINK_STATUS (0x8B82), DELETE_STATUS (0x8B80)
    _ = pname;
    return true;
}

/// Gets shader info log.
pub fn getShaderInfoLog(_: *const WebGLRenderingContext, _: ?*WebGLShader) []const u8 {
    return "";
}

/// Gets program info log.
pub fn getProgramInfoLog(_: *const WebGLRenderingContext, _: ?*WebGLProgram) []const u8 {
    return "";
}

/// Binds a buffer.
pub fn bindBuffer(_: *WebGLRenderingContext, _: u32, _: ?*WebGLBuffer) void {}

/// Binds a texture.
pub fn bindTexture(_: *WebGLRenderingContext, _: u32, _: ?*WebGLTexture) void {}

/// Binds a framebuffer.
pub fn bindFramebuffer(_: *WebGLRenderingContext, _: u32, _: ?*WebGLFramebuffer) void {}

/// Binds a renderbuffer.
pub fn bindRenderbuffer(_: *WebGLRenderingContext, _: u32, _: ?*WebGLRenderbuffer) void {}

/// Uploads buffer data.
pub fn bufferData(_: *WebGLRenderingContext, _: u32, _: js.Object, _: u32) void {}

/// Specifies viewport dimensions.
pub fn viewport(_: *WebGLRenderingContext, _: i32, _: i32, _: i32, _: i32) void {}

/// Draw arrays.
pub fn drawArrays(_: *WebGLRenderingContext, _: u32, _: i32, _: i32) void {}

/// Draw elements.
pub fn drawElements(_: *WebGLRenderingContext, _: u32, _: i32, _: u32, _: i32) void {}

/// Reads pixels from the framebuffer.
pub fn readPixels(_: *WebGLRenderingContext, _: i32, _: i32, _: i32, _: i32, _: u32, _: u32, _: js.Object) void {}

/// Returns error code.
pub fn getError(_: *const WebGLRenderingContext) u32 {
    return 0; // NO_ERROR
}

/// Flushes pending commands.
pub fn flush(_: *WebGLRenderingContext) void {}

/// Finishes all pending commands.
pub fn finish(_: *WebGLRenderingContext) void {}

/// Gets an attribute location.
pub fn getAttribLocation(_: *const WebGLRenderingContext, _: ?*WebGLProgram, _: []const u8) i32 {
    return 0;
}

/// Gets a uniform location.
pub fn getUniformLocation(_: *const WebGLRenderingContext, _: ?*WebGLProgram, _: []const u8, page: *Page) !*WebGLUniformLocation {
    return page._factory.create(WebGLUniformLocation{});
}

/// Enables a vertex attribute array.
pub fn enableVertexAttribArray(_: *WebGLRenderingContext, _: u32) void {}

/// Disables a vertex attribute array.
pub fn disableVertexAttribArray(_: *WebGLRenderingContext, _: u32) void {}

/// Specifies the vertex attribute pointer.
pub fn vertexAttribPointer(_: *WebGLRenderingContext, _: u32, _: i32, _: u32, _: bool, _: i32, _: i32) void {}

/// Sets uniform1f.
pub fn uniform1f(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: f32) void {}

/// Sets uniform2f.
pub fn uniform2f(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: f32, _: f32) void {}

/// Sets uniform3f.
pub fn uniform3f(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: f32, _: f32, _: f32) void {}

/// Sets uniform4f.
pub fn uniform4f(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: f32, _: f32, _: f32, _: f32) void {}

/// Sets uniform1i.
pub fn uniform1i(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: i32) void {}

/// Sets uniform1fv.
pub fn uniform1fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: js.Object) void {}

/// Sets uniform2fv.
pub fn uniform2fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: js.Object) void {}

/// Sets uniform3fv.
pub fn uniform3fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: js.Object) void {}

/// Sets uniform4fv.
pub fn uniform4fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: js.Object) void {}

/// Sets uniformMatrix2fv.
pub fn uniformMatrix2fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: bool, _: js.Object) void {}

/// Sets uniformMatrix3fv.
pub fn uniformMatrix3fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: bool, _: js.Object) void {}

/// Sets uniformMatrix4fv.
pub fn uniformMatrix4fv(_: *WebGLRenderingContext, _: ?*WebGLUniformLocation, _: bool, _: js.Object) void {}

/// Sets active texture unit.
pub fn activeTexture(_: *WebGLRenderingContext, _: u32) void {}

/// Sets texture parameters.
pub fn texParameteri(_: *WebGLRenderingContext, _: u32, _: u32, _: i32) void {}

/// Sets texture parameters (float).
pub fn texParameterf(_: *WebGLRenderingContext, _: u32, _: u32, _: f32) void {}

/// Uploads texture data.
pub fn texImage2D(_: *WebGLRenderingContext, _: u32, _: i32, _: u32, _: u32, _: u32, _: i32, _: u32, _: u32, _: ?js.Object) void {}

/// Uploads subtexture data.
pub fn texSubImage2D(_: *WebGLRenderingContext, _: u32, _: i32, _: i32, _: i32, _: u32, _: u32, _: u32, _: u32, _: ?js.Object) void {}

/// Generates mipmaps.
pub fn generateMipmap(_: *WebGLRenderingContext, _: u32) void {}

/// Sets pixel store parameters.
pub fn pixelStorei(_: *WebGLRenderingContext, _: u32, _: i32) void {}

/// Sets blend function.
pub fn blendFunc(_: *WebGLRenderingContext, _: u32, _: u32) void {}

/// Sets blend function separate.
pub fn blendFuncSeparate(_: *WebGLRenderingContext, _: u32, _: u32, _: u32, _: u32) void {}

/// Sets blend equation.
pub fn blendEquation(_: *WebGLRenderingContext, _: u32) void {}

/// Sets blend color.
pub fn blendColor(_: *WebGLRenderingContext, _: f32, _: f32, _: f32, _: f32) void {}

/// Sets depth function.
pub fn depthFunc(_: *WebGLRenderingContext, _: u32) void {}

/// Sets depth mask.
pub fn depthMask(_: *WebGLRenderingContext, _: bool) void {}

/// Sets depth range.
pub fn depthRange(_: *WebGLRenderingContext, _: f32, _: f32) void {}

/// Sets color mask.
pub fn colorMask(_: *WebGLRenderingContext, _: bool, _: bool, _: bool, _: bool) void {}

/// Sets stencil function.
pub fn stencilFunc(_: *WebGLRenderingContext, _: u32, _: i32, _: u32) void {}

/// Sets stencil mask.
pub fn stencilMask(_: *WebGLRenderingContext, _: u32) void {}

/// Sets stencil op.
pub fn stencilOp(_: *WebGLRenderingContext, _: u32, _: u32, _: u32) void {}

/// Sets cull face.
pub fn cullFace(_: *WebGLRenderingContext, _: u32) void {}

/// Sets front face.
pub fn frontFace(_: *WebGLRenderingContext, _: u32) void {}

/// Sets line width.
pub fn lineWidth(_: *WebGLRenderingContext, _: f32) void {}

/// Sets polygon offset.
pub fn polygonOffset(_: *WebGLRenderingContext, _: f32, _: f32) void {}

/// Sets scissor box.
pub fn scissor(_: *WebGLRenderingContext, _: i32, _: i32, _: i32, _: i32) void {}

/// Checks framebuffer status.
pub fn checkFramebufferStatus(_: *const WebGLRenderingContext, _: u32) u32 {
    return 0x8CD5; // FRAMEBUFFER_COMPLETE
}

/// Attaches texture to framebuffer.
pub fn framebufferTexture2D(_: *WebGLRenderingContext, _: u32, _: u32, _: u32, _: ?*WebGLTexture, _: i32) void {}

/// Attaches renderbuffer to framebuffer.
pub fn framebufferRenderbuffer(_: *WebGLRenderingContext, _: u32, _: u32, _: u32, _: ?*WebGLRenderbuffer) void {}

/// Sets renderbuffer storage.
pub fn renderbufferStorage(_: *WebGLRenderingContext, _: u32, _: u32, _: i32, _: i32) void {}

/// Hint function.
pub fn hint(_: *WebGLRenderingContext, _: u32, _: u32) void {}

/// Sample coverage.
pub fn sampleCoverage(_: *WebGLRenderingContext, _: f32, _: bool) void {}

/// Gets active attrib.
pub fn getActiveAttrib(_: *const WebGLRenderingContext, _: ?*WebGLProgram, _: u32, page: *Page) !*WebGLActiveInfo {
    return page._factory.create(WebGLActiveInfo{});
}

/// Gets active uniform.
pub fn getActiveUniform(_: *const WebGLRenderingContext, _: ?*WebGLProgram, _: u32, page: *Page) !*WebGLActiveInfo {
    return page._factory.create(WebGLActiveInfo{});
}

/// Gets vertex attrib.
pub fn getVertexAttrib(_: *const WebGLRenderingContext, _: u32, _: u32) i32 {
    return 0;
}

/// Gets vertex attrib offset.
pub fn getVertexAttribOffset(_: *const WebGLRenderingContext, _: u32, _: u32) i32 {
    return 0;
}

/// Gets buffer parameter.
pub fn getBufferParameter(_: *const WebGLRenderingContext, _: u32, _: u32) i32 {
    return 0;
}

/// Gets framebuffer attachment parameter.
pub fn getFramebufferAttachmentParameter(_: *const WebGLRenderingContext, _: u32, _: u32, _: u32) i32 {
    return 0;
}

/// Gets renderbuffer parameter.
pub fn getRenderbufferParameter(_: *const WebGLRenderingContext, _: u32, _: u32) i32 {
    return 0;
}

/// Gets texture parameter.
pub fn getTexParameter(_: *const WebGLRenderingContext, _: u32, _: u32) i32 {
    return 0;
}

/// Gets uniform value.
pub fn getUniform(_: *const WebGLRenderingContext, _: ?*WebGLProgram, _: ?*WebGLUniformLocation) ?f32 {
    return null;
}

/// Is buffer.
pub fn isBuffer(_: *const WebGLRenderingContext, _: ?*WebGLBuffer) bool {
    return true;
}

/// Is enabled.
pub fn isEnabled(_: *const WebGLRenderingContext, _: u32) bool {
    return false;
}

/// Is framebuffer.
pub fn isFramebuffer(_: *const WebGLRenderingContext, _: ?*WebGLFramebuffer) bool {
    return true;
}

/// Is program.
pub fn isProgram(_: *const WebGLRenderingContext, _: ?*WebGLProgram) bool {
    return true;
}

/// Is renderbuffer.
pub fn isRenderbuffer(_: *const WebGLRenderingContext, _: ?*WebGLRenderbuffer) bool {
    return true;
}

/// Is shader.
pub fn isShader(_: *const WebGLRenderingContext, _: ?*WebGLShader) bool {
    return true;
}

/// Is texture.
pub fn isTexture(_: *const WebGLRenderingContext, _: ?*WebGLTexture) bool {
    return true;
}

/// Validates program.
pub fn validateProgram(_: *WebGLRenderingContext, _: ?*WebGLProgram) void {}

/// Vertex attrib 1f.
pub fn vertexAttrib1f(_: *WebGLRenderingContext, _: u32, _: f32) void {}

/// Vertex attrib 2f.
pub fn vertexAttrib2f(_: *WebGLRenderingContext, _: u32, _: f32, _: f32) void {}

/// Vertex attrib 3f.
pub fn vertexAttrib3f(_: *WebGLRenderingContext, _: u32, _: f32, _: f32, _: f32) void {}

/// Vertex attrib 4f.
pub fn vertexAttrib4f(_: *WebGLRenderingContext, _: u32, _: f32, _: f32, _: f32, _: f32) void {}

/// Vertex attrib 1fv.
pub fn vertexAttrib1fv(_: *WebGLRenderingContext, _: u32, _: js.Object) void {}

/// Vertex attrib 2fv.
pub fn vertexAttrib2fv(_: *WebGLRenderingContext, _: u32, _: js.Object) void {}

/// Vertex attrib 3fv.
pub fn vertexAttrib3fv(_: *WebGLRenderingContext, _: u32, _: js.Object) void {}

/// Vertex attrib 4fv.
pub fn vertexAttrib4fv(_: *WebGLRenderingContext, _: u32, _: js.Object) void {}

/// Copy tex image 2D.
pub fn copyTexImage2D(_: *WebGLRenderingContext, _: u32, _: i32, _: u32, _: i32, _: i32, _: i32, _: i32, _: i32) void {}

/// Copy tex sub image 2D.
pub fn copyTexSubImage2D(_: *WebGLRenderingContext, _: u32, _: i32, _: i32, _: i32, _: i32, _: i32, _: i32, _: i32) void {}

/// Detaches shader.
pub fn detachShader(_: *WebGLRenderingContext, _: ?*WebGLProgram, _: ?*WebGLShader) void {}

/// Gets attached shaders.
pub fn getAttachedShaders(_: *const WebGLRenderingContext, _: ?*WebGLProgram) []const *WebGLShader {
    return &.{};
}

/// Gets shader source.
pub fn getShaderSource(_: *const WebGLRenderingContext, _: ?*WebGLShader) []const u8 {
    return "";
}

/// Bind attrib location.
pub fn bindAttribLocation(_: *WebGLRenderingContext, _: ?*WebGLProgram, _: u32, _: []const u8) void {}

/// WebGL ActiveInfo for getActiveAttrib/getActiveUniform
pub const WebGLActiveInfo = struct {
    _name: []const u8 = "",
    _size: i32 = 1,
    _type: u32 = 0x1406, // FLOAT

    pub fn getName(self: *const WebGLActiveInfo) []const u8 {
        return self._name;
    }

    pub fn getSize(self: *const WebGLActiveInfo) i32 {
        return self._size;
    }

    pub fn getType(self: *const WebGLActiveInfo) u32 {
        return self._type;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLActiveInfo);

        pub const Meta = struct {
            pub const name = "WebGLActiveInfo";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"name" = bridge.accessor(WebGLActiveInfo.getName, null, .{});
        pub const size = bridge.accessor(WebGLActiveInfo.getSize, null, .{});
        pub const @"type" = bridge.accessor(WebGLActiveInfo.getType, null, .{});
    };
};

/// Sets the drawing buffer width.
pub fn getDrawingBufferWidth(_: *const WebGLRenderingContext) i32 {
    return 300;
}

/// Sets the drawing buffer height.
pub fn getDrawingBufferHeight(_: *const WebGLRenderingContext) i32 {
    return 150;
}

/// WebGL context attributes
pub const WebGLContextAttributes = struct {
    alpha: bool = true,
    depth: bool = true,
    stencil: bool = false,
    antialias: bool = true,
    premultipliedAlpha: bool = true,
    preserveDrawingBuffer: bool = false,
    failIfMajorPerformanceCaveat: bool = false,
    desynchronized: bool = false,
    powerPreference: []const u8 = "default",

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLContextAttributes);

        pub const Meta = struct {
            pub const name = "WebGLContextAttributes";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL shader precision format - used by fingerprinting scripts
pub const WebGLShaderPrecisionFormat = struct {
    _range_min: i32 = 127,
    _range_max: i32 = 127,
    _precision: i32 = 23,

    pub fn getRangeMin(self: *const WebGLShaderPrecisionFormat) i32 {
        return self._range_min;
    }

    pub fn getRangeMax(self: *const WebGLShaderPrecisionFormat) i32 {
        return self._range_max;
    }

    pub fn getPrecision(self: *const WebGLShaderPrecisionFormat) i32 {
        return self._precision;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLShaderPrecisionFormat);

        pub const Meta = struct {
            pub const name = "WebGLShaderPrecisionFormat";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const rangeMin = bridge.accessor(WebGLShaderPrecisionFormat.getRangeMin, null, .{});
        pub const rangeMax = bridge.accessor(WebGLShaderPrecisionFormat.getRangeMax, null, .{});
        pub const precision = bridge.accessor(WebGLShaderPrecisionFormat.getPrecision, null, .{});
    };
};

/// WebGL shader stub
pub const WebGLShader = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLShader);
        pub const Meta = struct {
            pub const name = "WebGLShader";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL program stub
pub const WebGLProgram = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLProgram);
        pub const Meta = struct {
            pub const name = "WebGLProgram";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL buffer stub
pub const WebGLBuffer = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLBuffer);
        pub const Meta = struct {
            pub const name = "WebGLBuffer";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL texture stub
pub const WebGLTexture = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLTexture);
        pub const Meta = struct {
            pub const name = "WebGLTexture";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL framebuffer stub
pub const WebGLFramebuffer = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLFramebuffer);
        pub const Meta = struct {
            pub const name = "WebGLFramebuffer";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL renderbuffer stub
pub const WebGLRenderbuffer = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLRenderbuffer);
        pub const Meta = struct {
            pub const name = "WebGLRenderbuffer";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

/// WebGL uniform location stub
pub const WebGLUniformLocation = struct {
    _: u8 = 0,
    pub const JsApi = struct {
        pub const bridge = js.Bridge(WebGLUniformLocation);
        pub const Meta = struct {
            pub const name = "WebGLUniformLocation";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };
    };
};

pub const JsApi = struct {
    pub const bridge = js.Bridge(WebGLRenderingContext);

    pub const Meta = struct {
        pub const name = "WebGLRenderingContext";

        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const canvas = bridge.accessor(WebGLRenderingContext.getCanvas, null, .{});

    pub const getParameter = bridge.function(WebGLRenderingContext.getParameter, .{});
    pub const getExtension = bridge.function(WebGLRenderingContext.getExtension, .{});
    pub const getSupportedExtensions = bridge.function(WebGLRenderingContext.getSupportedExtensions, .{});
    pub const getContextAttributes = bridge.function(WebGLRenderingContext.getContextAttributes, .{});
    pub const isContextLost = bridge.function(WebGLRenderingContext.isContextLost, .{});
    pub const getShaderPrecisionFormat = bridge.function(WebGLRenderingContext.getShaderPrecisionFormat, .{});
    pub const clear = bridge.function(WebGLRenderingContext.clear, .{});
    pub const clearColor = bridge.function(WebGLRenderingContext.clearColor, .{});
    pub const clearDepth = bridge.function(WebGLRenderingContext.clearDepth, .{});
    pub const clearStencil = bridge.function(WebGLRenderingContext.clearStencil, .{});
    pub const enable = bridge.function(WebGLRenderingContext.enable, .{});
    pub const disable = bridge.function(WebGLRenderingContext.disable, .{});
    pub const createShader = bridge.function(WebGLRenderingContext.createShader, .{});
    pub const createProgram = bridge.function(WebGLRenderingContext.createProgram, .{});
    pub const createBuffer = bridge.function(WebGLRenderingContext.createBuffer, .{});
    pub const createTexture = bridge.function(WebGLRenderingContext.createTexture, .{});
    pub const createFramebuffer = bridge.function(WebGLRenderingContext.createFramebuffer, .{});
    pub const createRenderbuffer = bridge.function(WebGLRenderingContext.createRenderbuffer, .{});
    pub const deleteShader = bridge.function(WebGLRenderingContext.deleteShader, .{});
    pub const deleteProgram = bridge.function(WebGLRenderingContext.deleteProgram, .{});
    pub const deleteBuffer = bridge.function(WebGLRenderingContext.deleteBuffer, .{});
    pub const deleteTexture = bridge.function(WebGLRenderingContext.deleteTexture, .{});
    pub const deleteFramebuffer = bridge.function(WebGLRenderingContext.deleteFramebuffer, .{});
    pub const deleteRenderbuffer = bridge.function(WebGLRenderingContext.deleteRenderbuffer, .{});
    pub const attachShader = bridge.function(WebGLRenderingContext.attachShader, .{});
    pub const linkProgram = bridge.function(WebGLRenderingContext.linkProgram, .{});
    pub const useProgram = bridge.function(WebGLRenderingContext.useProgram, .{});
    pub const shaderSource = bridge.function(WebGLRenderingContext.shaderSource, .{});
    pub const compileShader = bridge.function(WebGLRenderingContext.compileShader, .{});
    pub const getShaderParameter = bridge.function(WebGLRenderingContext.getShaderParameter, .{});
    pub const getProgramParameter = bridge.function(WebGLRenderingContext.getProgramParameter, .{});
    pub const getShaderInfoLog = bridge.function(WebGLRenderingContext.getShaderInfoLog, .{});
    pub const getProgramInfoLog = bridge.function(WebGLRenderingContext.getProgramInfoLog, .{});
    pub const bindBuffer = bridge.function(WebGLRenderingContext.bindBuffer, .{});
    pub const bindTexture = bridge.function(WebGLRenderingContext.bindTexture, .{});
    pub const bindFramebuffer = bridge.function(WebGLRenderingContext.bindFramebuffer, .{});
    pub const bindRenderbuffer = bridge.function(WebGLRenderingContext.bindRenderbuffer, .{});
    pub const bufferData = bridge.function(WebGLRenderingContext.bufferData, .{});
    pub const viewport = bridge.function(WebGLRenderingContext.viewport, .{});
    pub const drawArrays = bridge.function(WebGLRenderingContext.drawArrays, .{});
    pub const drawElements = bridge.function(WebGLRenderingContext.drawElements, .{});
    pub const readPixels = bridge.function(WebGLRenderingContext.readPixels, .{});
    pub const getError = bridge.function(WebGLRenderingContext.getError, .{});
    pub const flush = bridge.function(WebGLRenderingContext.flush, .{});
    pub const finish = bridge.function(WebGLRenderingContext.finish, .{});
    pub const getAttribLocation = bridge.function(WebGLRenderingContext.getAttribLocation, .{});
    pub const getUniformLocation = bridge.function(WebGLRenderingContext.getUniformLocation, .{});
    pub const enableVertexAttribArray = bridge.function(WebGLRenderingContext.enableVertexAttribArray, .{});
    pub const disableVertexAttribArray = bridge.function(WebGLRenderingContext.disableVertexAttribArray, .{});
    pub const vertexAttribPointer = bridge.function(WebGLRenderingContext.vertexAttribPointer, .{});
    pub const uniform1f = bridge.function(WebGLRenderingContext.uniform1f, .{});
    pub const uniform2f = bridge.function(WebGLRenderingContext.uniform2f, .{});
    pub const uniform3f = bridge.function(WebGLRenderingContext.uniform3f, .{});
    pub const uniform4f = bridge.function(WebGLRenderingContext.uniform4f, .{});
    pub const uniform1i = bridge.function(WebGLRenderingContext.uniform1i, .{});
    pub const uniform1fv = bridge.function(WebGLRenderingContext.uniform1fv, .{});
    pub const uniform2fv = bridge.function(WebGLRenderingContext.uniform2fv, .{});
    pub const uniform3fv = bridge.function(WebGLRenderingContext.uniform3fv, .{});
    pub const uniform4fv = bridge.function(WebGLRenderingContext.uniform4fv, .{});
    pub const uniformMatrix2fv = bridge.function(WebGLRenderingContext.uniformMatrix2fv, .{});
    pub const uniformMatrix3fv = bridge.function(WebGLRenderingContext.uniformMatrix3fv, .{});
    pub const uniformMatrix4fv = bridge.function(WebGLRenderingContext.uniformMatrix4fv, .{});
    pub const activeTexture = bridge.function(WebGLRenderingContext.activeTexture, .{});
    pub const texParameteri = bridge.function(WebGLRenderingContext.texParameteri, .{});
    pub const texParameterf = bridge.function(WebGLRenderingContext.texParameterf, .{});
    pub const texImage2D = bridge.function(WebGLRenderingContext.texImage2D, .{});
    pub const texSubImage2D = bridge.function(WebGLRenderingContext.texSubImage2D, .{});
    pub const generateMipmap = bridge.function(WebGLRenderingContext.generateMipmap, .{});
    pub const pixelStorei = bridge.function(WebGLRenderingContext.pixelStorei, .{});
    pub const blendFunc = bridge.function(WebGLRenderingContext.blendFunc, .{});
    pub const blendFuncSeparate = bridge.function(WebGLRenderingContext.blendFuncSeparate, .{});
    pub const blendEquation = bridge.function(WebGLRenderingContext.blendEquation, .{});
    pub const blendColor = bridge.function(WebGLRenderingContext.blendColor, .{});
    pub const depthFunc = bridge.function(WebGLRenderingContext.depthFunc, .{});
    pub const depthMask = bridge.function(WebGLRenderingContext.depthMask, .{});
    pub const depthRange = bridge.function(WebGLRenderingContext.depthRange, .{});
    pub const colorMask = bridge.function(WebGLRenderingContext.colorMask, .{});
    pub const stencilFunc = bridge.function(WebGLRenderingContext.stencilFunc, .{});
    pub const stencilMask = bridge.function(WebGLRenderingContext.stencilMask, .{});
    pub const stencilOp = bridge.function(WebGLRenderingContext.stencilOp, .{});
    pub const cullFace = bridge.function(WebGLRenderingContext.cullFace, .{});
    pub const frontFace = bridge.function(WebGLRenderingContext.frontFace, .{});
    pub const lineWidth = bridge.function(WebGLRenderingContext.lineWidth, .{});
    pub const polygonOffset = bridge.function(WebGLRenderingContext.polygonOffset, .{});
    pub const scissor = bridge.function(WebGLRenderingContext.scissor, .{});
    pub const checkFramebufferStatus = bridge.function(WebGLRenderingContext.checkFramebufferStatus, .{});
    pub const framebufferTexture2D = bridge.function(WebGLRenderingContext.framebufferTexture2D, .{});
    pub const framebufferRenderbuffer = bridge.function(WebGLRenderingContext.framebufferRenderbuffer, .{});
    pub const renderbufferStorage = bridge.function(WebGLRenderingContext.renderbufferStorage, .{});
    pub const hint = bridge.function(WebGLRenderingContext.hint, .{});
    pub const sampleCoverage = bridge.function(WebGLRenderingContext.sampleCoverage, .{});
    pub const getActiveAttrib = bridge.function(WebGLRenderingContext.getActiveAttrib, .{});
    pub const getActiveUniform = bridge.function(WebGLRenderingContext.getActiveUniform, .{});
    pub const getVertexAttrib = bridge.function(WebGLRenderingContext.getVertexAttrib, .{});
    pub const getVertexAttribOffset = bridge.function(WebGLRenderingContext.getVertexAttribOffset, .{});
    pub const getBufferParameter = bridge.function(WebGLRenderingContext.getBufferParameter, .{});
    pub const getFramebufferAttachmentParameter = bridge.function(WebGLRenderingContext.getFramebufferAttachmentParameter, .{});
    pub const getRenderbufferParameter = bridge.function(WebGLRenderingContext.getRenderbufferParameter, .{});
    pub const getTexParameter = bridge.function(WebGLRenderingContext.getTexParameter, .{});
    pub const getUniform = bridge.function(WebGLRenderingContext.getUniform, .{});
    pub const isBuffer = bridge.function(WebGLRenderingContext.isBuffer, .{});
    pub const isEnabled = bridge.function(WebGLRenderingContext.isEnabled, .{});
    pub const isFramebuffer = bridge.function(WebGLRenderingContext.isFramebuffer, .{});
    pub const isProgram = bridge.function(WebGLRenderingContext.isProgram, .{});
    pub const isRenderbuffer = bridge.function(WebGLRenderingContext.isRenderbuffer, .{});
    pub const isShader = bridge.function(WebGLRenderingContext.isShader, .{});
    pub const isTexture = bridge.function(WebGLRenderingContext.isTexture, .{});
    pub const validateProgram = bridge.function(WebGLRenderingContext.validateProgram, .{});
    pub const vertexAttrib1f = bridge.function(WebGLRenderingContext.vertexAttrib1f, .{});
    pub const vertexAttrib2f = bridge.function(WebGLRenderingContext.vertexAttrib2f, .{});
    pub const vertexAttrib3f = bridge.function(WebGLRenderingContext.vertexAttrib3f, .{});
    pub const vertexAttrib4f = bridge.function(WebGLRenderingContext.vertexAttrib4f, .{});
    pub const vertexAttrib1fv = bridge.function(WebGLRenderingContext.vertexAttrib1fv, .{});
    pub const vertexAttrib2fv = bridge.function(WebGLRenderingContext.vertexAttrib2fv, .{});
    pub const vertexAttrib3fv = bridge.function(WebGLRenderingContext.vertexAttrib3fv, .{});
    pub const vertexAttrib4fv = bridge.function(WebGLRenderingContext.vertexAttrib4fv, .{});
    pub const copyTexImage2D = bridge.function(WebGLRenderingContext.copyTexImage2D, .{});
    pub const copyTexSubImage2D = bridge.function(WebGLRenderingContext.copyTexSubImage2D, .{});
    pub const detachShader = bridge.function(WebGLRenderingContext.detachShader, .{});
    pub const getAttachedShaders = bridge.function(WebGLRenderingContext.getAttachedShaders, .{});
    pub const getShaderSource = bridge.function(WebGLRenderingContext.getShaderSource, .{});
    pub const bindAttribLocation = bridge.function(WebGLRenderingContext.bindAttribLocation, .{});
    pub const drawingBufferWidth = bridge.accessor(WebGLRenderingContext.getDrawingBufferWidth, null, .{});
    pub const drawingBufferHeight = bridge.accessor(WebGLRenderingContext.getDrawingBufferHeight, null, .{});

    // WebGL constants as properties
    pub const VERTEX_SHADER = bridge.accessor(WebGLRenderingContext.getVertexShader, null, .{});
    pub const FRAGMENT_SHADER = bridge.accessor(WebGLRenderingContext.getFragmentShader, null, .{});
    pub const COMPILE_STATUS = bridge.accessor(WebGLRenderingContext.getCompileStatus, null, .{});
    pub const LINK_STATUS = bridge.accessor(WebGLRenderingContext.getLinkStatus, null, .{});
    pub const ARRAY_BUFFER = bridge.accessor(WebGLRenderingContext.getArrayBuffer, null, .{});
    pub const ELEMENT_ARRAY_BUFFER = bridge.accessor(WebGLRenderingContext.getElementArrayBuffer, null, .{});
    pub const STATIC_DRAW = bridge.accessor(WebGLRenderingContext.getStaticDraw, null, .{});
    pub const DYNAMIC_DRAW = bridge.accessor(WebGLRenderingContext.getDynamicDraw, null, .{});
    pub const COLOR_BUFFER_BIT = bridge.accessor(WebGLRenderingContext.getColorBufferBit, null, .{});
    pub const DEPTH_BUFFER_BIT = bridge.accessor(WebGLRenderingContext.getDepthBufferBit, null, .{});
    pub const STENCIL_BUFFER_BIT = bridge.accessor(WebGLRenderingContext.getStencilBufferBit, null, .{});
    pub const TRIANGLES = bridge.accessor(WebGLRenderingContext.getTriangles, null, .{});
    pub const TRIANGLE_STRIP = bridge.accessor(WebGLRenderingContext.getTriangleStrip, null, .{});
    pub const TRIANGLE_FAN = bridge.accessor(WebGLRenderingContext.getTriangleFan, null, .{});
    pub const POINTS = bridge.accessor(WebGLRenderingContext.getPoints, null, .{});
    pub const LINES = bridge.accessor(WebGLRenderingContext.getLines, null, .{});
    pub const LINE_STRIP = bridge.accessor(WebGLRenderingContext.getLineStrip, null, .{});
    pub const LINE_LOOP = bridge.accessor(WebGLRenderingContext.getLineLoop, null, .{});
    pub const FLOAT = bridge.accessor(WebGLRenderingContext.getFloat, null, .{});
    pub const UNSIGNED_BYTE = bridge.accessor(WebGLRenderingContext.getUnsignedByte, null, .{});
    pub const UNSIGNED_SHORT = bridge.accessor(WebGLRenderingContext.getUnsignedShort, null, .{});
    pub const UNSIGNED_INT = bridge.accessor(WebGLRenderingContext.getUnsignedInt, null, .{});
    pub const TEXTURE_2D = bridge.accessor(WebGLRenderingContext.getTexture2d, null, .{});
    pub const TEXTURE0 = bridge.accessor(WebGLRenderingContext.getTexture0, null, .{});
    pub const RGBA = bridge.accessor(WebGLRenderingContext.getRgba, null, .{});
    pub const RGB = bridge.accessor(WebGLRenderingContext.getRgb, null, .{});
    pub const NEAREST = bridge.accessor(WebGLRenderingContext.getNearest, null, .{});
    pub const LINEAR = bridge.accessor(WebGLRenderingContext.getLinear, null, .{});
    pub const TEXTURE_MIN_FILTER = bridge.accessor(WebGLRenderingContext.getTextureMinFilter, null, .{});
    pub const TEXTURE_MAG_FILTER = bridge.accessor(WebGLRenderingContext.getTextureMagFilter, null, .{});
    pub const TEXTURE_WRAP_S = bridge.accessor(WebGLRenderingContext.getTextureWrapS, null, .{});
    pub const TEXTURE_WRAP_T = bridge.accessor(WebGLRenderingContext.getTextureWrapT, null, .{});
    pub const CLAMP_TO_EDGE = bridge.accessor(WebGLRenderingContext.getClampToEdge, null, .{});
    pub const REPEAT = bridge.accessor(WebGLRenderingContext.getRepeat, null, .{});
    pub const FRAMEBUFFER = bridge.accessor(WebGLRenderingContext.getFramebuffer, null, .{});
    pub const RENDERBUFFER = bridge.accessor(WebGLRenderingContext.getRenderbuffer, null, .{});
    pub const COLOR_ATTACHMENT0 = bridge.accessor(WebGLRenderingContext.getColorAttachment0, null, .{});
    pub const DEPTH_ATTACHMENT = bridge.accessor(WebGLRenderingContext.getDepthAttachment, null, .{});
    pub const DEPTH_COMPONENT16 = bridge.accessor(WebGLRenderingContext.getDepthComponent16, null, .{});
    pub const FRAMEBUFFER_COMPLETE = bridge.accessor(WebGLRenderingContext.getFramebufferComplete, null, .{});
    pub const DEPTH_TEST = bridge.accessor(WebGLRenderingContext.getDepthTest, null, .{});
    pub const BLEND = bridge.accessor(WebGLRenderingContext.getBlend, null, .{});
    pub const CULL_FACE = bridge.accessor(WebGLRenderingContext.getCullFace, null, .{});
    pub const SRC_ALPHA = bridge.accessor(WebGLRenderingContext.getSrcAlpha, null, .{});
    pub const ONE_MINUS_SRC_ALPHA = bridge.accessor(WebGLRenderingContext.getOneMinusSrcAlpha, null, .{});
    pub const FUNC_ADD = bridge.accessor(WebGLRenderingContext.getFuncAdd, null, .{});
    pub const NO_ERROR = bridge.accessor(WebGLRenderingContext.getNoError, null, .{});
    pub const HIGH_FLOAT = bridge.accessor(WebGLRenderingContext.getHighFloat, null, .{});
    pub const MEDIUM_FLOAT = bridge.accessor(WebGLRenderingContext.getMediumFloat, null, .{});
    pub const LOW_FLOAT = bridge.accessor(WebGLRenderingContext.getLowFloat, null, .{});
    pub const HIGH_INT = bridge.accessor(WebGLRenderingContext.getHighInt, null, .{});
    pub const MEDIUM_INT = bridge.accessor(WebGLRenderingContext.getMediumInt, null, .{});
    pub const LOW_INT = bridge.accessor(WebGLRenderingContext.getLowInt, null, .{});
};

const testing = @import("../../../testing.zig");
test "WebApi: WebGLRenderingContext" {
    try testing.htmlRunner("canvas/webgl_rendering_context.html", .{});
}
