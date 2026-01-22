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
const js = @import("../js/js.zig");
const Page = @import("../Page.zig");
const EventTarget = @import("EventTarget.zig");

pub fn registerTypes() []const type {
    return &.{
        BaseAudioContext,
        AudioContext,
        OfflineAudioContext,
        AudioBuffer,
        OscillatorNode,
        GainNode,
        AnalyserNode,
        DynamicsCompressorNode,
        AudioDestinationNode,
    };
}

/// Base class for all audio contexts
pub const BaseAudioContext = struct {
    _proto: *EventTarget,
    _sample_rate: f32,
    _page: *Page,

    pub fn asEventTarget(self: *BaseAudioContext) *EventTarget {
        return self._proto;
    }

    pub fn getSampleRate(self: *const BaseAudioContext) f32 {
        return self._sample_rate;
    }

    pub fn getCurrentTime(_: *const BaseAudioContext) f64 {
        return 0.0;
    }

    pub fn getState(_: *const BaseAudioContext) []const u8 {
        return "running";
    }

    pub fn createOscillator(self: *BaseAudioContext) !*OscillatorNode {
        return self._page._factory.create(OscillatorNode{ ._context = self });
    }

    pub fn createGain(self: *BaseAudioContext) !*GainNode {
        return self._page._factory.create(GainNode{ ._context = self });
    }

    pub fn createAnalyser(self: *BaseAudioContext) !*AnalyserNode {
        return self._page._factory.create(AnalyserNode{ ._context = self });
    }

    pub fn createDynamicsCompressor(self: *BaseAudioContext) !*DynamicsCompressorNode {
        return self._page._factory.create(DynamicsCompressorNode{ ._context = self });
    }

    pub fn getDestination(self: *BaseAudioContext) !*AudioDestinationNode {
        return self._page._factory.create(AudioDestinationNode{ ._context = self });
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(BaseAudioContext);

        pub const Meta = struct {
            pub const name = "BaseAudioContext";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const sampleRate = bridge.accessor(BaseAudioContext.getSampleRate, null, .{});
        pub const currentTime = bridge.accessor(BaseAudioContext.getCurrentTime, null, .{});
        pub const state = bridge.accessor(BaseAudioContext.getState, null, .{});
        pub const destination = bridge.accessor(BaseAudioContext.getDestination, null, .{});
        pub const createOscillator = bridge.function(BaseAudioContext.createOscillator, .{});
        pub const createGain = bridge.function(BaseAudioContext.createGain, .{});
        pub const createAnalyser = bridge.function(BaseAudioContext.createAnalyser, .{});
        pub const createDynamicsCompressor = bridge.function(BaseAudioContext.createDynamicsCompressor, .{});
    };
};

/// AudioContext for real-time audio
pub const AudioContext = struct {
    _proto: *EventTarget,
    _sample_rate: f32,
    _page: *Page,

    const Options = struct {
        sampleRate: ?f32 = null,
        latencyHint: ?[]const u8 = null,
    };

    pub fn constructor(options: ?Options, page: *Page) !*AudioContext {
        const sample_rate = if (options) |o| o.sampleRate orelse 44100.0 else 44100.0;
        return page._factory.eventTarget(AudioContext{
            ._proto = undefined,
            ._sample_rate = sample_rate,
            ._page = page,
        });
    }

    pub fn asEventTarget(self: *AudioContext) *EventTarget {
        return self._proto;
    }

    pub fn getSampleRate(self: *const AudioContext) f32 {
        return self._sample_rate;
    }

    pub fn getCurrentTime(_: *const AudioContext) f64 {
        return 0.0;
    }

    pub fn getState(_: *const AudioContext) []const u8 {
        return "running";
    }

    pub fn getBaseLatency(_: *const AudioContext) f64 {
        return 0.01; // 10ms typical
    }

    pub fn getOutputLatency(_: *const AudioContext) f64 {
        return 0.02; // 20ms typical
    }

    pub fn createOscillator(self: *AudioContext) !*OscillatorNode {
        return self._page._factory.create(OscillatorNode{ ._context = @ptrCast(self) });
    }

    pub fn createGain(self: *AudioContext) !*GainNode {
        return self._page._factory.create(GainNode{ ._context = @ptrCast(self) });
    }

    pub fn createAnalyser(self: *AudioContext) !*AnalyserNode {
        return self._page._factory.create(AnalyserNode{ ._context = @ptrCast(self) });
    }

    pub fn createDynamicsCompressor(self: *AudioContext) !*DynamicsCompressorNode {
        return self._page._factory.create(DynamicsCompressorNode{ ._context = @ptrCast(self) });
    }

    pub fn getDestination(self: *AudioContext) !*AudioDestinationNode {
        return self._page._factory.create(AudioDestinationNode{ ._context = @ptrCast(self) });
    }

    pub fn resume_(self: *AudioContext) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("AudioContext.resume", {});
        return resolver.promise();
    }

    pub fn suspend_(self: *AudioContext) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("AudioContext.suspend", {});
        return resolver.promise();
    }

    pub fn close(self: *AudioContext) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("AudioContext.close", {});
        return resolver.promise();
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AudioContext);

        pub const Meta = struct {
            pub const name = "AudioContext";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(AudioContext.constructor, .{});
        pub const sampleRate = bridge.accessor(AudioContext.getSampleRate, null, .{});
        pub const currentTime = bridge.accessor(AudioContext.getCurrentTime, null, .{});
        pub const state = bridge.accessor(AudioContext.getState, null, .{});
        pub const baseLatency = bridge.accessor(AudioContext.getBaseLatency, null, .{});
        pub const outputLatency = bridge.accessor(AudioContext.getOutputLatency, null, .{});
        pub const destination = bridge.accessor(AudioContext.getDestination, null, .{});
        pub const createOscillator = bridge.function(AudioContext.createOscillator, .{});
        pub const createGain = bridge.function(AudioContext.createGain, .{});
        pub const createAnalyser = bridge.function(AudioContext.createAnalyser, .{});
        pub const createDynamicsCompressor = bridge.function(AudioContext.createDynamicsCompressor, .{});
        pub const @"resume" = bridge.function(AudioContext.resume_, .{});
        pub const @"suspend" = bridge.function(AudioContext.suspend_, .{});
        pub const close = bridge.function(AudioContext.close, .{});
    };
};

/// OfflineAudioContext for rendering audio offline - used for audio fingerprinting
pub const OfflineAudioContext = struct {
    _proto: *EventTarget,
    _sample_rate: f32,
    _length: u32,
    _number_of_channels: u32,
    _page: *Page,

    const Options = struct {
        numberOfChannels: ?u32 = null,
        length: u32,
        sampleRate: f32,
    };

    pub fn constructor(options: Options, page: *Page) !*OfflineAudioContext {
        return page._factory.eventTarget(OfflineAudioContext{
            ._proto = undefined,
            ._sample_rate = options.sampleRate,
            ._length = options.length,
            ._number_of_channels = options.numberOfChannels orelse 2,
            ._page = page,
        });
    }

    pub fn asEventTarget(self: *OfflineAudioContext) *EventTarget {
        return self._proto;
    }

    pub fn getSampleRate(self: *const OfflineAudioContext) f32 {
        return self._sample_rate;
    }

    pub fn getCurrentTime(_: *const OfflineAudioContext) f64 {
        return 0.0;
    }

    pub fn getState(_: *const OfflineAudioContext) []const u8 {
        return "suspended";
    }

    pub fn getLength(self: *const OfflineAudioContext) u32 {
        return self._length;
    }

    pub fn createOscillator(self: *OfflineAudioContext) !*OscillatorNode {
        return self._page._factory.create(OscillatorNode{ ._context = @ptrCast(self) });
    }

    pub fn createGain(self: *OfflineAudioContext) !*GainNode {
        return self._page._factory.create(GainNode{ ._context = @ptrCast(self) });
    }

    pub fn createAnalyser(self: *OfflineAudioContext) !*AnalyserNode {
        return self._page._factory.create(AnalyserNode{ ._context = @ptrCast(self) });
    }

    pub fn createDynamicsCompressor(self: *OfflineAudioContext) !*DynamicsCompressorNode {
        return self._page._factory.create(DynamicsCompressorNode{ ._context = @ptrCast(self) });
    }

    pub fn getDestination(self: *OfflineAudioContext) !*AudioDestinationNode {
        return self._page._factory.create(AudioDestinationNode{ ._context = @ptrCast(self) });
    }

    /// Starts rendering audio. Returns a promise that resolves with the rendered AudioBuffer.
    /// The audio fingerprint is deterministic based on the profile seed.
    pub fn startRendering(self: *OfflineAudioContext) !js.Promise {
        // Generate deterministic audio buffer based on fingerprint profile
        const profile = self._page.fingerprintProfile();
        const seed = profile.audio.seed;

        // Create a stable AudioBuffer with profile-based fingerprint
        const buffer = try self._page._factory.create(AudioBuffer{
            ._sample_rate = self._sample_rate,
            ._length = self._length,
            ._number_of_channels = self._number_of_channels,
            ._fingerprint_seed = seed,
        });

        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("OfflineAudioContext.startRendering", buffer);
        return resolver.promise();
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(OfflineAudioContext);

        pub const Meta = struct {
            pub const name = "OfflineAudioContext";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(OfflineAudioContext.constructor, .{});
        pub const sampleRate = bridge.accessor(OfflineAudioContext.getSampleRate, null, .{});
        pub const currentTime = bridge.accessor(OfflineAudioContext.getCurrentTime, null, .{});
        pub const state = bridge.accessor(OfflineAudioContext.getState, null, .{});
        pub const length = bridge.accessor(OfflineAudioContext.getLength, null, .{});
        pub const destination = bridge.accessor(OfflineAudioContext.getDestination, null, .{});
        pub const createOscillator = bridge.function(OfflineAudioContext.createOscillator, .{});
        pub const createGain = bridge.function(OfflineAudioContext.createGain, .{});
        pub const createAnalyser = bridge.function(OfflineAudioContext.createAnalyser, .{});
        pub const createDynamicsCompressor = bridge.function(OfflineAudioContext.createDynamicsCompressor, .{});
        pub const startRendering = bridge.function(OfflineAudioContext.startRendering, .{});
    };
};

/// AudioBuffer holds decoded audio data
pub const AudioBuffer = struct {
    _sample_rate: f32,
    _length: u32,
    _number_of_channels: u32,
    _fingerprint_seed: []const u8,

    pub fn getSampleRate(self: *const AudioBuffer) f32 {
        return self._sample_rate;
    }

    pub fn getLength(self: *const AudioBuffer) u32 {
        return self._length;
    }

    pub fn getNumberOfChannels(self: *const AudioBuffer) u32 {
        return self._number_of_channels;
    }

    pub fn getDuration(self: *const AudioBuffer) f64 {
        return @as(f64, @floatFromInt(self._length)) / @as(f64, self._sample_rate);
    }

    /// Returns channel data as Float32Array. The values are deterministic based on fingerprint seed.
    pub fn getChannelData(self: *const AudioBuffer, channel: u32, page: *Page) ![]const f32 {
        if (channel >= self._number_of_channels) {
            return error.IndexSizeError;
        }

        // Generate deterministic audio samples based on seed
        var hasher = std.hash.Fnv1a_64.init();
        hasher.update(self._fingerprint_seed);
        hasher.update(std.mem.asBytes(&channel));
        hasher.update(std.mem.asBytes(&self._sample_rate));
        hasher.update(std.mem.asBytes(&self._length));
        const base_hash = hasher.final();

        // Allocate and fill with deterministic pseudo-random values
        const len = @min(self._length, 4096); // Limit to prevent huge allocations
        const data = try page.call_arena.alloc(f32, len);

        var prng = std.Random.DefaultPrng.init(base_hash);
        const random = prng.random();

        for (data, 0..) |*sample, i| {
            // Generate values in typical audio range (-1.0 to 1.0)
            // with slight deterministic variations based on position
            const pos_factor = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(len));
            const rand_val = random.float(f32) * 2.0 - 1.0;
            sample.* = rand_val * 0.00001 + pos_factor * 0.00001; // Very small values typical of silence
        }

        return data;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AudioBuffer);

        pub const Meta = struct {
            pub const name = "AudioBuffer";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const sampleRate = bridge.accessor(AudioBuffer.getSampleRate, null, .{});
        pub const length = bridge.accessor(AudioBuffer.getLength, null, .{});
        pub const numberOfChannels = bridge.accessor(AudioBuffer.getNumberOfChannels, null, .{});
        pub const duration = bridge.accessor(AudioBuffer.getDuration, null, .{});
        pub const getChannelData = bridge.function(AudioBuffer.getChannelData, .{});
    };
};

/// AudioNode base - stub for various audio nodes
pub const OscillatorNode = struct {
    _context: *anyopaque,

    pub fn connect(_: *OscillatorNode, _: js.Object) void {}
    pub fn disconnect(_: *OscillatorNode) void {}
    pub fn start(_: *OscillatorNode, _: ?f64) void {}
    pub fn stop(_: *OscillatorNode, _: ?f64) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(OscillatorNode);

        pub const Meta = struct {
            pub const name = "OscillatorNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(OscillatorNode.connect, .{});
        pub const disconnect = bridge.function(OscillatorNode.disconnect, .{});
        pub const start = bridge.function(OscillatorNode.start, .{});
        pub const stop = bridge.function(OscillatorNode.stop, .{});
    };
};

pub const GainNode = struct {
    _context: *anyopaque,

    pub fn connect(_: *GainNode, _: js.Object) void {}
    pub fn disconnect(_: *GainNode) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(GainNode);

        pub const Meta = struct {
            pub const name = "GainNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(GainNode.connect, .{});
        pub const disconnect = bridge.function(GainNode.disconnect, .{});
    };
};

pub const AnalyserNode = struct {
    _context: *anyopaque,

    pub fn connect(_: *AnalyserNode, _: js.Object) void {}
    pub fn disconnect(_: *AnalyserNode) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AnalyserNode);

        pub const Meta = struct {
            pub const name = "AnalyserNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(AnalyserNode.connect, .{});
        pub const disconnect = bridge.function(AnalyserNode.disconnect, .{});
    };
};

pub const DynamicsCompressorNode = struct {
    _context: *anyopaque,

    pub fn connect(_: *DynamicsCompressorNode, _: js.Object) void {}
    pub fn disconnect(_: *DynamicsCompressorNode) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(DynamicsCompressorNode);

        pub const Meta = struct {
            pub const name = "DynamicsCompressorNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(DynamicsCompressorNode.connect, .{});
        pub const disconnect = bridge.function(DynamicsCompressorNode.disconnect, .{});
    };
};

pub const AudioDestinationNode = struct {
    _context: *anyopaque,

    pub fn getMaxChannelCount(_: *const AudioDestinationNode) u32 {
        return 2;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AudioDestinationNode);

        pub const Meta = struct {
            pub const name = "AudioDestinationNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const maxChannelCount = bridge.accessor(AudioDestinationNode.getMaxChannelCount, null, .{});
    };
};
