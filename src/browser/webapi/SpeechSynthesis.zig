// Copyright (C) 2023-2025  Lightpanda (Selecy SAS)
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.

const js = @import("../js/js.zig");
const Page = @import("../Page.zig");

pub fn registerTypes() []const type {
    return &.{
        SpeechSynthesis,
        SpeechSynthesisVoice,
        SpeechSynthesisUtterance,
    };
}

/// SpeechSynthesis interface for the Web Speech API
/// https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesis
pub const SpeechSynthesis = struct {
    _: u8 = 0, // Placeholder field
    _on_voiceschanged: ?js.Function.Global = null,

    pub const init = SpeechSynthesis{};

    /// Returns whether speech is currently being spoken
    pub fn getSpeaking(_: *const SpeechSynthesis) bool {
        return false;
    }

    /// Returns whether speech is pending
    pub fn getPending(_: *const SpeechSynthesis) bool {
        return false;
    }

    /// Returns whether speech is paused
    pub fn getPaused(_: *const SpeechSynthesis) bool {
        return false;
    }

    /// Returns the list of available voices
    pub fn getVoices(_: *const SpeechSynthesis, page: *Page) ![]*SpeechSynthesisVoice {
        // Return a list of common voices that Chrome would return
        const voices = try page.call_arena.alloc(*SpeechSynthesisVoice, 5);

        // Chrome on Windows typically has Microsoft voices as local services
        // We need at least one localService=true voice for CreepJS to pass
        voices[0] = try page._factory.create(SpeechSynthesisVoice{
            ._name = "Microsoft David - English (United States)",
            ._lang = "en-US",
            ._voice_uri = "Microsoft David - English (United States)",
            ._local_service = true, // Local service voice
            ._default = true,
        });
        voices[1] = try page._factory.create(SpeechSynthesisVoice{
            ._name = "Microsoft Zira - English (United States)",
            ._lang = "en-US",
            ._voice_uri = "Microsoft Zira - English (United States)",
            ._local_service = true, // Local service voice
            ._default = false,
        });
        voices[2] = try page._factory.create(SpeechSynthesisVoice{
            ._name = "Google US English",
            ._lang = "en-US",
            ._voice_uri = "Google US English",
            ._local_service = false, // Remote Google voice
            ._default = false,
        });
        voices[3] = try page._factory.create(SpeechSynthesisVoice{
            ._name = "Google UK English Female",
            ._lang = "en-GB",
            ._voice_uri = "Google UK English Female",
            ._local_service = false,
            ._default = false,
        });
        voices[4] = try page._factory.create(SpeechSynthesisVoice{
            ._name = "Google 日本語",
            ._lang = "ja-JP",
            ._voice_uri = "Google 日本語",
            ._local_service = false,
            ._default = false,
        });

        return voices;
    }

    /// Speaks an utterance (no-op stub)
    pub fn speak(_: *SpeechSynthesis, _: ?*SpeechSynthesisUtterance) void {}

    /// Cancels speech (no-op stub)
    pub fn cancel(_: *SpeechSynthesis) void {}

    /// Pauses speech (no-op stub)
    pub fn pause(_: *SpeechSynthesis) void {}

    /// Resumes speech (no-op stub)
    pub fn @"resume"(_: *SpeechSynthesis) void {}

    /// Gets the onvoiceschanged handler
    pub fn getOnVoicesChanged(self: *const SpeechSynthesis) ?js.Function.Global {
        return self._on_voiceschanged;
    }

    /// Sets the onvoiceschanged handler
    pub fn setOnVoicesChanged(self: *SpeechSynthesis, handler: ?js.Function.Global) void {
        self._on_voiceschanged = handler;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SpeechSynthesis);

        pub const Meta = struct {
            pub const name = "SpeechSynthesis";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const speaking = bridge.accessor(SpeechSynthesis.getSpeaking, null, .{});
        pub const pending = bridge.accessor(SpeechSynthesis.getPending, null, .{});
        pub const paused = bridge.accessor(SpeechSynthesis.getPaused, null, .{});
        pub const onvoiceschanged = bridge.accessor(SpeechSynthesis.getOnVoicesChanged, SpeechSynthesis.setOnVoicesChanged, .{});
        pub const getVoices = bridge.function(SpeechSynthesis.getVoices, .{});
        pub const speak = bridge.function(SpeechSynthesis.speak, .{});
        pub const cancel = bridge.function(SpeechSynthesis.cancel, .{});
        pub const pause = bridge.function(SpeechSynthesis.pause, .{});
        pub const @"resume" = bridge.function(SpeechSynthesis.@"resume", .{});
    };
};

/// SpeechSynthesisVoice represents a voice
/// https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisVoice
pub const SpeechSynthesisVoice = struct {
    _name: []const u8,
    _lang: []const u8,
    _voice_uri: []const u8,
    _local_service: bool,
    _default: bool,

    pub fn getName(self: *const SpeechSynthesisVoice) []const u8 {
        return self._name;
    }

    pub fn getLang(self: *const SpeechSynthesisVoice) []const u8 {
        return self._lang;
    }

    pub fn getVoiceURI(self: *const SpeechSynthesisVoice) []const u8 {
        return self._voice_uri;
    }

    pub fn getLocalService(self: *const SpeechSynthesisVoice) bool {
        return self._local_service;
    }

    pub fn getDefault(self: *const SpeechSynthesisVoice) bool {
        return self._default;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SpeechSynthesisVoice);

        pub const Meta = struct {
            pub const name = "SpeechSynthesisVoice";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const @"name" = bridge.accessor(SpeechSynthesisVoice.getName, null, .{});
        pub const lang = bridge.accessor(SpeechSynthesisVoice.getLang, null, .{});
        pub const voiceURI = bridge.accessor(SpeechSynthesisVoice.getVoiceURI, null, .{});
        pub const localService = bridge.accessor(SpeechSynthesisVoice.getLocalService, null, .{});
        pub const default = bridge.accessor(SpeechSynthesisVoice.getDefault, null, .{});
    };
};

/// SpeechSynthesisUtterance represents an utterance
/// https://developer.mozilla.org/en-US/docs/Web/API/SpeechSynthesisUtterance
pub const SpeechSynthesisUtterance = struct {
    _text: []const u8 = "",
    _lang: []const u8 = "",
    _voice: ?*SpeechSynthesisVoice = null,
    _volume: f64 = 1.0,
    _rate: f64 = 1.0,
    _pitch: f64 = 1.0,

    pub fn constructor(text: ?[]const u8, page: *Page) !*SpeechSynthesisUtterance {
        _ = page;
        return @constCast(&SpeechSynthesisUtterance{
            ._text = text orelse "",
        });
    }

    pub fn getText(self: *const SpeechSynthesisUtterance) []const u8 {
        return self._text;
    }

    pub fn setText(self: *SpeechSynthesisUtterance, text: []const u8) void {
        self._text = text;
    }

    pub fn getLang(self: *const SpeechSynthesisUtterance) []const u8 {
        return self._lang;
    }

    pub fn setLang(self: *SpeechSynthesisUtterance, lang: []const u8) void {
        self._lang = lang;
    }

    pub fn getVoice(self: *const SpeechSynthesisUtterance) ?*SpeechSynthesisVoice {
        return self._voice;
    }

    pub fn setVoice(self: *SpeechSynthesisUtterance, voice: ?*SpeechSynthesisVoice) void {
        self._voice = voice;
    }

    pub fn getVolume(self: *const SpeechSynthesisUtterance) f64 {
        return self._volume;
    }

    pub fn setVolume(self: *SpeechSynthesisUtterance, volume: f64) void {
        self._volume = volume;
    }

    pub fn getRate(self: *const SpeechSynthesisUtterance) f64 {
        return self._rate;
    }

    pub fn setRate(self: *SpeechSynthesisUtterance, rate: f64) void {
        self._rate = rate;
    }

    pub fn getPitch(self: *const SpeechSynthesisUtterance) f64 {
        return self._pitch;
    }

    pub fn setPitch(self: *SpeechSynthesisUtterance, pitch: f64) void {
        self._pitch = pitch;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(SpeechSynthesisUtterance);

        pub const Meta = struct {
            pub const name = "SpeechSynthesisUtterance";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(SpeechSynthesisUtterance.constructor, .{});
        pub const text = bridge.accessor(SpeechSynthesisUtterance.getText, SpeechSynthesisUtterance.setText, .{});
        pub const lang = bridge.accessor(SpeechSynthesisUtterance.getLang, SpeechSynthesisUtterance.setLang, .{});
        pub const voice = bridge.accessor(SpeechSynthesisUtterance.getVoice, SpeechSynthesisUtterance.setVoice, .{});
        pub const volume = bridge.accessor(SpeechSynthesisUtterance.getVolume, SpeechSynthesisUtterance.setVolume, .{});
        pub const rate = bridge.accessor(SpeechSynthesisUtterance.getRate, SpeechSynthesisUtterance.setRate, .{});
        pub const pitch = bridge.accessor(SpeechSynthesisUtterance.getPitch, SpeechSynthesisUtterance.setPitch, .{});
    };
};
