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
        AnalyserNodeContext,
        DynamicsCompressorNode,
        AudioDestinationNode,
        BiquadFilterNode,
        AudioParam,
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
        return self._page._factory.create(AnalyserNode{ ._context = self, ._sample_rate = self._sample_rate });
    }

    pub fn createDynamicsCompressor(self: *BaseAudioContext) !*DynamicsCompressorNode {
        return self._page._factory.create(DynamicsCompressorNode{ ._context = self });
    }

    pub fn createBiquadFilter(self: *BaseAudioContext) !*BiquadFilterNode {
        return self._page._factory.create(BiquadFilterNode{ ._context = self });
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
        pub const createBiquadFilter = bridge.function(BaseAudioContext.createBiquadFilter, .{});
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
        return self._page._factory.create(AnalyserNode{ ._context = @ptrCast(self), ._sample_rate = self._sample_rate });
    }

    pub fn createDynamicsCompressor(self: *AudioContext) !*DynamicsCompressorNode {
        return self._page._factory.create(DynamicsCompressorNode{ ._context = @ptrCast(self) });
    }

    pub fn createBiquadFilter(self: *AudioContext) !*BiquadFilterNode {
        return self._page._factory.create(BiquadFilterNode{ ._context = @ptrCast(self) });
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
        pub const createBiquadFilter = bridge.function(AudioContext.createBiquadFilter, .{});
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

    /// Constructor accepts positional arguments (numberOfChannels, length, sampleRate)
    /// as commonly used in fingerprinting scripts
    pub fn constructor(numberOfChannels: u32, length: u32, sampleRate: f32, page: *Page) !*OfflineAudioContext {
        return page._factory.eventTarget(OfflineAudioContext{
            ._proto = undefined,
            ._sample_rate = sampleRate,
            ._length = length,
            ._number_of_channels = numberOfChannels,
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
        return self._page._factory.create(AnalyserNode{ ._context = @ptrCast(self), ._sample_rate = self._sample_rate });
    }

    pub fn createDynamicsCompressor(self: *OfflineAudioContext) !*DynamicsCompressorNode {
        return self._page._factory.create(DynamicsCompressorNode{ ._context = @ptrCast(self) });
    }

    pub fn createBiquadFilter(self: *OfflineAudioContext) !*BiquadFilterNode {
        return self._page._factory.create(BiquadFilterNode{ ._context = @ptrCast(self) });
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
        pub const createBiquadFilter = bridge.function(OfflineAudioContext.createBiquadFilter, .{});
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
    pub fn getChannelData(self: *const AudioBuffer, channel: ?f64, page: *Page) ![]const f32 {
        const ch: u32 = if (channel) |c| @intFromFloat(c) else 0;
        if (ch >= self._number_of_channels) {
            return error.IndexSizeError;
        }

        // Generate deterministic audio samples based on seed
        var hasher = std.hash.Fnv1a_64.init();
        hasher.update(self._fingerprint_seed);
        hasher.update(std.mem.asBytes(&ch));
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
    _frequency: ?*AudioParam = null,
    _detune: ?*AudioParam = null,
    _type: []const u8 = "sine",

    pub fn connect(_: *OscillatorNode, _: ?js.Object) void {}
    pub fn disconnect(_: *OscillatorNode, _: ?js.Object) void {}
    pub fn start(_: *OscillatorNode, _: ?f64) void {}
    pub fn stop(_: *OscillatorNode, _: ?f64) void {}

    pub fn getFrequency(self: *OscillatorNode, page: *Page) !*AudioParam {
        if (self._frequency) |f| return f;
        self._frequency = try page._factory.create(AudioParam{
            ._value = 440.0,
            ._default_value = 440.0,
            ._min_value = -22050.0,
            ._max_value = 22050.0,
        });
        return self._frequency.?;
    }

    pub fn getDetune(self: *OscillatorNode, page: *Page) !*AudioParam {
        if (self._detune) |d| return d;
        self._detune = try page._factory.create(AudioParam{
            ._value = 0.0,
            ._default_value = 0.0,
            ._min_value = -153600.0,
            ._max_value = 153600.0,
        });
        return self._detune.?;
    }

    pub fn getType(self: *const OscillatorNode) []const u8 {
        return self._type;
    }

    pub fn setType(self: *OscillatorNode, value: []const u8) void {
        self._type = value;
    }

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
        pub const frequency = bridge.accessor(OscillatorNode.getFrequency, null, .{});
        pub const detune = bridge.accessor(OscillatorNode.getDetune, null, .{});
        pub const @"type" = bridge.accessor(OscillatorNode.getType, OscillatorNode.setType, .{});
    };
};

pub const GainNode = struct {
    _context: *anyopaque,
    _gain: ?*AudioParam = null,

    pub fn connect(_: *GainNode, _: ?js.Object) void {}
    pub fn disconnect(_: *GainNode, _: ?js.Object) void {}

    pub fn getGain(self: *GainNode, page: *Page) !*AudioParam {
        if (self._gain) |g| return g;
        self._gain = try page._factory.create(AudioParam{
            ._value = 1.0,
            ._default_value = 1.0,
            ._min_value = -3.4028235e+38,
            ._max_value = 3.4028235e+38,
        });
        return self._gain.?;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(GainNode);

        pub const Meta = struct {
            pub const name = "GainNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(GainNode.connect, .{});
        pub const disconnect = bridge.function(GainNode.disconnect, .{});
        pub const gain = bridge.accessor(GainNode.getGain, null, .{});
    };
};

pub const AnalyserNode = struct {
    _context: *anyopaque,
    _sample_rate: f32 = 44100.0,
    _fft_size: u32 = 2048,
    _min_decibels: f64 = -100.0,
    _max_decibels: f64 = -30.0,
    _smoothing_time_constant: f64 = 0.8,

    pub fn connect(_: *AnalyserNode, _: ?js.Object) void {}
    pub fn disconnect(_: *AnalyserNode, _: ?js.Object) void {}

    // Context accessor - returns a simple object with sampleRate
    pub fn getContext(self: *AnalyserNode, page: *Page) !*AnalyserNodeContext {
        return page._factory.create(AnalyserNodeContext{ ._sample_rate = self._sample_rate });
    }

    // AudioNode properties
    pub fn getNumberOfInputs(_: *const AnalyserNode) u32 {
        return 1;
    }

    pub fn getNumberOfOutputs(_: *const AnalyserNode) u32 {
        return 1;
    }

    pub fn getChannelCount(_: *const AnalyserNode) u32 {
        return 2;
    }

    pub fn getChannelCountMode(_: *const AnalyserNode) []const u8 {
        return "max";
    }

    pub fn getChannelInterpretation(_: *const AnalyserNode) []const u8 {
        return "speakers";
    }

    // AnalyserNode properties
    pub fn getFftSize(self: *const AnalyserNode) u32 {
        return self._fft_size;
    }

    pub fn setFftSize(self: *AnalyserNode, value: u32) void {
        // Must be power of 2 between 32 and 32768
        if (value >= 32 and value <= 32768 and (value & (value - 1)) == 0) {
            self._fft_size = value;
        }
    }

    pub fn getFrequencyBinCount(self: *const AnalyserNode) u32 {
        return self._fft_size / 2;
    }

    pub fn getMinDecibels(self: *const AnalyserNode) f64 {
        return self._min_decibels;
    }

    pub fn setMinDecibels(self: *AnalyserNode, value: f64) void {
        self._min_decibels = value;
    }

    pub fn getMaxDecibels(self: *const AnalyserNode) f64 {
        return self._max_decibels;
    }

    pub fn setMaxDecibels(self: *AnalyserNode, value: f64) void {
        self._max_decibels = value;
    }

    pub fn getSmoothingTimeConstant(self: *const AnalyserNode) f64 {
        return self._smoothing_time_constant;
    }

    pub fn setSmoothingTimeConstant(self: *AnalyserNode, value: f64) void {
        if (value >= 0.0 and value <= 1.0) {
            self._smoothing_time_constant = value;
        }
    }

    // Data retrieval methods - return deterministic data for fingerprint consistency
    pub fn getByteFrequencyData(_: *AnalyserNode, array: js.Object) void {
        // Fill array with silence values (0)
        // In a real implementation, this would copy frequency data to the Uint8Array
        _ = array;
    }

    pub fn getFloatFrequencyData(_: *AnalyserNode, array: js.Object) void {
        // Fill array with silence values (-Infinity in dB)
        _ = array;
    }

    pub fn getByteTimeDomainData(_: *AnalyserNode, array: js.Object) void {
        // Fill array with 128 (silence for unsigned byte representation)
        _ = array;
    }

    pub fn getFloatTimeDomainData(_: *AnalyserNode, array: js.Object) void {
        // Fill array with 0.0 (silence)
        _ = array;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AnalyserNode);

        pub const Meta = struct {
            pub const name = "AnalyserNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(AnalyserNode.connect, .{});
        pub const disconnect = bridge.function(AnalyserNode.disconnect, .{});

        // AudioNode properties
        pub const context = bridge.accessor(AnalyserNode.getContext, null, .{});
        pub const numberOfInputs = bridge.accessor(AnalyserNode.getNumberOfInputs, null, .{});
        pub const numberOfOutputs = bridge.accessor(AnalyserNode.getNumberOfOutputs, null, .{});
        pub const channelCount = bridge.accessor(AnalyserNode.getChannelCount, null, .{});
        pub const channelCountMode = bridge.accessor(AnalyserNode.getChannelCountMode, null, .{});
        pub const channelInterpretation = bridge.accessor(AnalyserNode.getChannelInterpretation, null, .{});

        // AnalyserNode properties
        pub const fftSize = bridge.accessor(AnalyserNode.getFftSize, AnalyserNode.setFftSize, .{});
        pub const frequencyBinCount = bridge.accessor(AnalyserNode.getFrequencyBinCount, null, .{});
        pub const minDecibels = bridge.accessor(AnalyserNode.getMinDecibels, AnalyserNode.setMinDecibels, .{});
        pub const maxDecibels = bridge.accessor(AnalyserNode.getMaxDecibels, AnalyserNode.setMaxDecibels, .{});
        pub const smoothingTimeConstant = bridge.accessor(AnalyserNode.getSmoothingTimeConstant, AnalyserNode.setSmoothingTimeConstant, .{});

        // Data methods
        pub const getByteFrequencyData = bridge.function(AnalyserNode.getByteFrequencyData, .{});
        pub const getFloatFrequencyData = bridge.function(AnalyserNode.getFloatFrequencyData, .{});
        pub const getByteTimeDomainData = bridge.function(AnalyserNode.getByteTimeDomainData, .{});
        pub const getFloatTimeDomainData = bridge.function(AnalyserNode.getFloatTimeDomainData, .{});
    };
};

pub const DynamicsCompressorNode = struct {
    _context: *anyopaque,
    _threshold: ?*AudioParam = null,
    _knee: ?*AudioParam = null,
    _ratio: ?*AudioParam = null,
    _attack: ?*AudioParam = null,
    _release: ?*AudioParam = null,
    _reduction: f64 = 0.0,

    pub fn connect(_: *DynamicsCompressorNode, _: ?js.Object) void {}
    pub fn disconnect(_: *DynamicsCompressorNode, _: ?js.Object) void {}

    pub fn getThreshold(self: *DynamicsCompressorNode, page: *Page) !*AudioParam {
        if (self._threshold) |t| return t;
        self._threshold = try page._factory.create(AudioParam{
            ._value = -24.0,
            ._default_value = -24.0,
            ._min_value = -100.0,
            ._max_value = 0.0,
        });
        return self._threshold.?;
    }

    pub fn getKnee(self: *DynamicsCompressorNode, page: *Page) !*AudioParam {
        if (self._knee) |k| return k;
        self._knee = try page._factory.create(AudioParam{
            ._value = 30.0,
            ._default_value = 30.0,
            ._min_value = 0.0,
            ._max_value = 40.0,
        });
        return self._knee.?;
    }

    pub fn getRatio(self: *DynamicsCompressorNode, page: *Page) !*AudioParam {
        if (self._ratio) |r| return r;
        self._ratio = try page._factory.create(AudioParam{
            ._value = 12.0,
            ._default_value = 12.0,
            ._min_value = 1.0,
            ._max_value = 20.0,
        });
        return self._ratio.?;
    }

    pub fn getAttack(self: *DynamicsCompressorNode, page: *Page) !*AudioParam {
        if (self._attack) |a| return a;
        self._attack = try page._factory.create(AudioParam{
            ._value = 0.003,
            ._default_value = 0.003,
            ._min_value = 0.0,
            ._max_value = 1.0,
        });
        return self._attack.?;
    }

    pub fn getRelease(self: *DynamicsCompressorNode, page: *Page) !*AudioParam {
        if (self._release) |r| return r;
        self._release = try page._factory.create(AudioParam{
            ._value = 0.25,
            ._default_value = 0.25,
            ._min_value = 0.0,
            ._max_value = 1.0,
        });
        return self._release.?;
    }

    pub fn getReduction(self: *const DynamicsCompressorNode) f64 {
        return self._reduction;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(DynamicsCompressorNode);

        pub const Meta = struct {
            pub const name = "DynamicsCompressorNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(DynamicsCompressorNode.connect, .{});
        pub const disconnect = bridge.function(DynamicsCompressorNode.disconnect, .{});
        pub const threshold = bridge.accessor(DynamicsCompressorNode.getThreshold, null, .{});
        pub const knee = bridge.accessor(DynamicsCompressorNode.getKnee, null, .{});
        pub const ratio = bridge.accessor(DynamicsCompressorNode.getRatio, null, .{});
        pub const attack = bridge.accessor(DynamicsCompressorNode.getAttack, null, .{});
        pub const release = bridge.accessor(DynamicsCompressorNode.getRelease, null, .{});
        pub const reduction = bridge.accessor(DynamicsCompressorNode.getReduction, null, .{});
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

pub const BiquadFilterNode = struct {
    _context: *anyopaque,
    _type: []const u8 = "lowpass",
    _frequency: *AudioParam = undefined,
    _detune: *AudioParam = undefined,
    _q: *AudioParam = undefined,
    _gain: *AudioParam = undefined,
    _page: *Page = undefined,
    _initialized: bool = false,

    pub fn initParams(self: *BiquadFilterNode, page: *Page) !void {
        if (self._initialized) return;
        self._page = page;
        self._frequency = try page._factory.create(AudioParam{
            ._value = 350.0,
            ._default_value = 350.0,
            ._min_value = 0.0,
            ._max_value = 24000.0,
        });
        self._detune = try page._factory.create(AudioParam{
            ._value = 0.0,
            ._default_value = 0.0,
            ._min_value = -153600.0,
            ._max_value = 153600.0,
        });
        self._q = try page._factory.create(AudioParam{
            ._value = 1.0,
            ._default_value = 1.0,
            ._min_value = -3.4028235e+38,
            ._max_value = 3.4028235e+38,
        });
        self._gain = try page._factory.create(AudioParam{
            ._value = 0.0,
            ._default_value = 0.0,
            ._min_value = -3.4028235e+38,
            ._max_value = 1541.0,
        });
        self._initialized = true;
    }

    pub fn connect(_: *BiquadFilterNode, _: ?js.Object) void {}
    pub fn disconnect(_: *BiquadFilterNode, _: ?js.Object) void {}

    pub fn getType(self: *const BiquadFilterNode) []const u8 {
        return self._type;
    }

    pub fn setType(self: *BiquadFilterNode, value: []const u8) void {
        self._type = value;
    }

    pub fn getFrequency(self: *BiquadFilterNode, page: *Page) !*AudioParam {
        try self.initParams(page);
        return self._frequency;
    }

    pub fn getDetune(self: *BiquadFilterNode, page: *Page) !*AudioParam {
        try self.initParams(page);
        return self._detune;
    }

    pub fn getQ(self: *BiquadFilterNode, page: *Page) !*AudioParam {
        try self.initParams(page);
        return self._q;
    }

    pub fn getGain(self: *BiquadFilterNode, page: *Page) !*AudioParam {
        try self.initParams(page);
        return self._gain;
    }

    /// Returns frequency response at specified frequencies
    pub fn getFrequencyResponse(_: *BiquadFilterNode, _: js.Object, _: js.Object, _: js.Object) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(BiquadFilterNode);

        pub const Meta = struct {
            pub const name = "BiquadFilterNode";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const connect = bridge.function(BiquadFilterNode.connect, .{});
        pub const disconnect = bridge.function(BiquadFilterNode.disconnect, .{});
        pub const @"type" = bridge.accessor(BiquadFilterNode.getType, BiquadFilterNode.setType, .{});
        pub const frequency = bridge.accessor(BiquadFilterNode.getFrequency, null, .{});
        pub const detune = bridge.accessor(BiquadFilterNode.getDetune, null, .{});
        pub const Q = bridge.accessor(BiquadFilterNode.getQ, null, .{});
        pub const gain = bridge.accessor(BiquadFilterNode.getGain, null, .{});
        pub const getFrequencyResponse = bridge.function(BiquadFilterNode.getFrequencyResponse, .{});
    };
};

/// AudioParam represents an audio-related parameter
pub const AudioParam = struct {
    _value: f64,
    _default_value: f64,
    _min_value: f64,
    _max_value: f64,

    pub fn getValue(self: *const AudioParam) f64 {
        return self._value;
    }

    pub fn setValue(self: *AudioParam, value: f64) void {
        self._value = value;
    }

    pub fn getDefaultValue(self: *const AudioParam) f64 {
        return self._default_value;
    }

    pub fn getMinValue(self: *const AudioParam) f64 {
        return self._min_value;
    }

    pub fn getMaxValue(self: *const AudioParam) f64 {
        return self._max_value;
    }

    pub fn setValueAtTime(self: *AudioParam, _: f64, _: f64) *AudioParam {
        return self;
    }

    pub fn linearRampToValueAtTime(self: *AudioParam, _: f64, _: f64) *AudioParam {
        return self;
    }

    pub fn exponentialRampToValueAtTime(self: *AudioParam, _: f64, _: f64) *AudioParam {
        return self;
    }

    pub fn setTargetAtTime(self: *AudioParam, _: f64, _: f64, _: f64) *AudioParam {
        return self;
    }

    pub fn cancelScheduledValues(self: *AudioParam, _: f64) *AudioParam {
        return self;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AudioParam);

        pub const Meta = struct {
            pub const name = "AudioParam";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const value = bridge.accessor(AudioParam.getValue, AudioParam.setValue, .{});
        pub const defaultValue = bridge.accessor(AudioParam.getDefaultValue, null, .{});
        pub const minValue = bridge.accessor(AudioParam.getMinValue, null, .{});
        pub const maxValue = bridge.accessor(AudioParam.getMaxValue, null, .{});
        pub const setValueAtTime = bridge.function(AudioParam.setValueAtTime, .{});
        pub const linearRampToValueAtTime = bridge.function(AudioParam.linearRampToValueAtTime, .{});
        pub const exponentialRampToValueAtTime = bridge.function(AudioParam.exponentialRampToValueAtTime, .{});
        pub const setTargetAtTime = bridge.function(AudioParam.setTargetAtTime, .{});
        pub const cancelScheduledValues = bridge.function(AudioParam.cancelScheduledValues, .{});
    };
};

/// Simple context object returned by AnalyserNode.context for fingerprinting compatibility
pub const AnalyserNodeContext = struct {
    _sample_rate: f32,

    pub fn getSampleRate(self: *const AnalyserNodeContext) f32 {
        return self._sample_rate;
    }

    pub fn getCurrentTime(_: *const AnalyserNodeContext) f64 {
        return 0.0;
    }

    pub fn getState(_: *const AnalyserNodeContext) []const u8 {
        return "running";
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(AnalyserNodeContext);

        pub const Meta = struct {
            pub const name = "AudioContext";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const sampleRate = bridge.accessor(AnalyserNodeContext.getSampleRate, null, .{});
        pub const currentTime = bridge.accessor(AnalyserNodeContext.getCurrentTime, null, .{});
        pub const state = bridge.accessor(AnalyserNodeContext.getState, null, .{});
    };
};
