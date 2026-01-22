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
const js = @import("js.zig");
const v8 = js.v8;

const Isolate = @This();

/// Maximum string length that V8 can handle (V8's actual limit is ~512MB, use 256MB to be safe)
const MAX_STRING_LENGTH: usize = 256 * 1024 * 1024;

/// Check if a pointer looks valid (not NULL, not poison patterns)
/// Returns true if pointer appears valid, false otherwise
fn isValidPointer(ptr: [*]const u8) bool {
    const addr = @intFromPtr(ptr);
    // Check for NULL
    if (addr == 0) return false;
    // Check for common poison/debug patterns that indicate use-after-free or uninitialized memory
    // 0xaaaaaaaaaaaaaaaa - common poison pattern
    // 0xcdcdcdcdcdcdcdcd - MSVC uninitialized heap
    // 0xdddddddddddddddd - MSVC freed memory
    // 0xfeeefeeefeeefeee - MSVC freed memory
    // 0xdeadbeefdeadbeef - common debug marker
    if (addr == 0xaaaaaaaaaaaaaaaa or
        addr == 0xcdcdcdcdcdcdcdcd or
        addr == 0xdddddddddddddddd or
        addr == 0xfeeefeeefeeefeee or
        addr == 0xdeadbeefdeadbeef)
    {
        return false;
    }
    // Check for very low addresses (likely invalid on modern systems)
    if (addr < 0x1000) return false;
    return true;
}

handle: *v8.Isolate,

pub fn init(params: *v8.CreateParams) Isolate {
    return .{
        .handle = v8.v8__Isolate__New(params).?,
    };
}

pub fn deinit(self: Isolate) void {
    v8.v8__Isolate__Dispose(self.handle);
}

pub fn enter(self: Isolate) void {
    v8.v8__Isolate__Enter(self.handle);
}

pub fn exit(self: Isolate) void {
    v8.v8__Isolate__Exit(self.handle);
}

pub fn performMicrotasksCheckpoint(self: Isolate) void {
    v8.v8__Isolate__PerformMicrotaskCheckpoint(self.handle);
}

pub fn enqueueMicrotask(self: Isolate, callback: anytype, data: anytype) void {
    v8.v8__Isolate__EnqueueMicrotask(self.handle, callback, data);
}

pub fn enqueueMicrotaskFunc(self: Isolate, function: js.Function) void {
    v8.v8__Isolate__EnqueueMicrotaskFunc(self.handle, function.handle);
}

pub fn lowMemoryNotification(self: Isolate) void {
    v8.v8__Isolate__LowMemoryNotification(self.handle);
}

pub fn notifyContextDisposed(self: Isolate) void {
    _ = v8.v8__Isolate__ContextDisposedNotification(self.handle);
}

pub fn getHeapStatistics(self: Isolate) v8.HeapStatistics {
    var res: v8.HeapStatistics = undefined;
    v8.v8__Isolate__GetHeapStatistics(self.handle, &res);
    return res;
}

pub fn throwException(self: Isolate, value: *const v8.Value) *const v8.Value {
    return v8.v8__Isolate__ThrowException(self.handle, value).?;
}

pub fn initStringHandle(self: Isolate, str: []const u8) *const v8.String {
    // Handle empty strings
    if (str.len == 0) {
        return v8.v8__String__NewFromUtf8(self.handle, "", v8.kNormal, 0).?;
    }
    // Validate pointer to prevent crashes from use-after-free or uninitialized memory
    if (!isValidPointer(str.ptr)) {
        std.log.err("initStringHandle: invalid pointer 0x{x}, returning empty string", .{@intFromPtr(str.ptr)});
        return v8.v8__String__NewFromUtf8(self.handle, "", v8.kNormal, 0).?;
    }
    // Truncate string if it exceeds V8's maximum length
    const safe_len = @min(str.len, MAX_STRING_LENGTH);
    // Try to create the string, fall back to empty string if V8 fails
    return v8.v8__String__NewFromUtf8(self.handle, str.ptr, v8.kNormal, @as(c_int, @intCast(safe_len))) orelse
        v8.v8__String__NewFromUtf8(self.handle, "", v8.kNormal, 0).?;
}

pub fn createError(self: Isolate, msg: []const u8) *const v8.Value {
    const message = self.initStringHandle(msg);
    return v8.v8__Exception__Error(message).?;
}

pub fn createTypeError(self: Isolate, msg: []const u8) *const v8.Value {
    const message = self.initStringHandle(msg);
    return v8.v8__Exception__TypeError(message).?;
}

pub fn initNull(self: Isolate) *const v8.Value {
    return v8.v8__Null(self.handle).?;
}

pub fn initUndefined(self: Isolate) *const v8.Value {
    return v8.v8__Undefined(self.handle).?;
}

pub fn initFalse(self: Isolate) *const v8.Value {
    return v8.v8__False(self.handle).?;
}

pub fn initTrue(self: Isolate) *const v8.Value {
    return v8.v8__True(self.handle).?;
}

pub fn initInteger(self: Isolate, val: anytype) js.Integer {
    return js.Integer.init(self.handle, val);
}

pub fn initBigInt(self: Isolate, val: anytype) js.BigInt {
    return js.BigInt.init(self.handle, val);
}

pub fn initNumber(self: Isolate, val: anytype) js.Number {
    return js.Number.init(self.handle, val);
}

pub fn createExternal(self: Isolate, val: *anyopaque) *const v8.External {
    return v8.v8__External__New(self.handle, val).?;
}
