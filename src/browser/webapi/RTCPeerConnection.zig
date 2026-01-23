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

//! WebRTC stub implementation for anti-fingerprinting.
//!
//! This module provides stub implementations of WebRTC APIs that exist
//! for detection purposes but prevent actual IP leakage by returning
//! rejected promises for connection-related methods.

const std = @import("std");
const js = @import("../js/js.zig");
const Page = @import("../Page.zig");
const EventTarget = @import("EventTarget.zig");

pub fn registerTypes() []const type {
    return &.{
        RTCPeerConnection,
        RTCSessionDescription,
        RTCIceCandidate,
        RTCDataChannel,
        RTCError,
    };
}

/// RTCPeerConnection stub - exists for detection but prevents IP leakage
/// All connection-related methods return rejected promises
pub const RTCPeerConnection = struct {
    _proto: *EventTarget,
    _page: *Page,
    _on_icecandidate: ?js.Function.Global = null,
    _on_iceconnectionstatechange: ?js.Function.Global = null,
    _on_icegatheringstatechange: ?js.Function.Global = null,
    _on_connectionstatechange: ?js.Function.Global = null,
    _on_negotiationneeded: ?js.Function.Global = null,
    _on_datachannel: ?js.Function.Global = null,
    _on_track: ?js.Function.Global = null,
    _on_signalingstatechange: ?js.Function.Global = null,

    const Configuration = struct {
        iceServers: ?[]const js.Object = null,
        iceTransportPolicy: ?[]const u8 = null,
        bundlePolicy: ?[]const u8 = null,
        rtcpMuxPolicy: ?[]const u8 = null,
    };

    pub fn constructor(_: ?Configuration, page: *Page) !*RTCPeerConnection {
        return page._factory.eventTarget(RTCPeerConnection{
            ._proto = undefined,
            ._page = page,
        });
    }

    pub fn asEventTarget(self: *RTCPeerConnection) *EventTarget {
        return self._proto;
    }

    // Connection state properties - always return "closed" state
    pub fn getConnectionState(_: *const RTCPeerConnection) []const u8 {
        return "closed";
    }

    pub fn getIceConnectionState(_: *const RTCPeerConnection) []const u8 {
        return "closed";
    }

    pub fn getIceGatheringState(_: *const RTCPeerConnection) []const u8 {
        return "complete";
    }

    pub fn getSignalingState(_: *const RTCPeerConnection) []const u8 {
        return "closed";
    }

    pub fn getLocalDescription(_: *const RTCPeerConnection) ?*RTCSessionDescription {
        return null;
    }

    pub fn getRemoteDescription(_: *const RTCPeerConnection) ?*RTCSessionDescription {
        return null;
    }

    pub fn getCurrentLocalDescription(_: *const RTCPeerConnection) ?*RTCSessionDescription {
        return null;
    }

    pub fn getCurrentRemoteDescription(_: *const RTCPeerConnection) ?*RTCSessionDescription {
        return null;
    }

    pub fn getPendingLocalDescription(_: *const RTCPeerConnection) ?*RTCSessionDescription {
        return null;
    }

    pub fn getPendingRemoteDescription(_: *const RTCPeerConnection) ?*RTCSessionDescription {
        return null;
    }

    pub fn getCanTrickleIceCandidates(_: *const RTCPeerConnection) ?bool {
        return null;
    }

    // Connection methods - all return rejected promises to prevent IP leakage
    pub fn createOffer(self: *RTCPeerConnection, _: ?js.Object) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.reject("RTCPeerConnection.createOffer", "NotSupportedError: WebRTC is disabled");
        return resolver.promise();
    }

    pub fn createAnswer(self: *RTCPeerConnection, _: ?js.Object) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.reject("RTCPeerConnection.createAnswer", "NotSupportedError: WebRTC is disabled");
        return resolver.promise();
    }

    pub fn setLocalDescription(self: *RTCPeerConnection, _: ?js.Object) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.reject("RTCPeerConnection.setLocalDescription", "InvalidStateError: Connection is closed");
        return resolver.promise();
    }

    pub fn setRemoteDescription(self: *RTCPeerConnection, _: ?js.Object) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.reject("RTCPeerConnection.setRemoteDescription", "InvalidStateError: Connection is closed");
        return resolver.promise();
    }

    pub fn addIceCandidate(self: *RTCPeerConnection, _: ?js.Object) !js.Promise {
        // This one resolves (no-op) since it doesn't leak information
        const resolver = self._page.js.createPromiseResolver();
        resolver.resolve("RTCPeerConnection.addIceCandidate", {});
        return resolver.promise();
    }

    pub fn getStats(self: *RTCPeerConnection, _: ?js.Object) !js.Promise {
        const resolver = self._page.js.createPromiseResolver();
        resolver.reject("RTCPeerConnection.getStats", "NotSupportedError: WebRTC is disabled");
        return resolver.promise();
    }

    // Data channel - returns stub that doesn't work
    pub fn createDataChannel(self: *RTCPeerConnection, label: []const u8, _: ?js.Object) !*RTCDataChannel {
        return self._page._factory.create(RTCDataChannel{
            ._label = label,
        });
    }

    // Track methods - no-op
    pub fn addTrack(_: *RTCPeerConnection, _: js.Object, _: ?[]const js.Object) void {}

    pub fn removeTrack(_: *RTCPeerConnection, _: js.Object) void {}

    pub fn addTransceiver(_: *RTCPeerConnection, _: js.Object, _: ?js.Object) void {}

    pub fn getTransceivers(_: *RTCPeerConnection) []const js.Object {
        return &.{};
    }

    pub fn getSenders(_: *RTCPeerConnection) []const js.Object {
        return &.{};
    }

    pub fn getReceivers(_: *RTCPeerConnection) []const js.Object {
        return &.{};
    }

    // Control methods
    pub fn close(_: *RTCPeerConnection) void {}

    pub fn restartIce(_: *RTCPeerConnection) void {}

    // Event handlers
    pub fn getOnIceCandidate(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_icecandidate;
    }

    pub fn setOnIceCandidate(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_icecandidate = handler;
    }

    pub fn getOnIceConnectionStateChange(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_iceconnectionstatechange;
    }

    pub fn setOnIceConnectionStateChange(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_iceconnectionstatechange = handler;
    }

    pub fn getOnIceGatheringStateChange(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_icegatheringstatechange;
    }

    pub fn setOnIceGatheringStateChange(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_icegatheringstatechange = handler;
    }

    pub fn getOnConnectionStateChange(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_connectionstatechange;
    }

    pub fn setOnConnectionStateChange(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_connectionstatechange = handler;
    }

    pub fn getOnNegotiationNeeded(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_negotiationneeded;
    }

    pub fn setOnNegotiationNeeded(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_negotiationneeded = handler;
    }

    pub fn getOnDataChannel(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_datachannel;
    }

    pub fn setOnDataChannel(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_datachannel = handler;
    }

    pub fn getOnTrack(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_track;
    }

    pub fn setOnTrack(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_track = handler;
    }

    pub fn getOnSignalingStateChange(self: *const RTCPeerConnection) ?js.Function.Global {
        return self._on_signalingstatechange;
    }

    pub fn setOnSignalingStateChange(self: *RTCPeerConnection, handler: ?js.Function.Global) void {
        self._on_signalingstatechange = handler;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(RTCPeerConnection);

        pub const Meta = struct {
            pub const name = "RTCPeerConnection";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(RTCPeerConnection.constructor, .{});

        // Properties
        pub const connectionState = bridge.accessor(RTCPeerConnection.getConnectionState, null, .{});
        pub const iceConnectionState = bridge.accessor(RTCPeerConnection.getIceConnectionState, null, .{});
        pub const iceGatheringState = bridge.accessor(RTCPeerConnection.getIceGatheringState, null, .{});
        pub const signalingState = bridge.accessor(RTCPeerConnection.getSignalingState, null, .{});
        pub const localDescription = bridge.accessor(RTCPeerConnection.getLocalDescription, null, .{});
        pub const remoteDescription = bridge.accessor(RTCPeerConnection.getRemoteDescription, null, .{});
        pub const currentLocalDescription = bridge.accessor(RTCPeerConnection.getCurrentLocalDescription, null, .{});
        pub const currentRemoteDescription = bridge.accessor(RTCPeerConnection.getCurrentRemoteDescription, null, .{});
        pub const pendingLocalDescription = bridge.accessor(RTCPeerConnection.getPendingLocalDescription, null, .{});
        pub const pendingRemoteDescription = bridge.accessor(RTCPeerConnection.getPendingRemoteDescription, null, .{});
        pub const canTrickleIceCandidates = bridge.accessor(RTCPeerConnection.getCanTrickleIceCandidates, null, .{});

        // Methods
        pub const createOffer = bridge.function(RTCPeerConnection.createOffer, .{});
        pub const createAnswer = bridge.function(RTCPeerConnection.createAnswer, .{});
        pub const setLocalDescription = bridge.function(RTCPeerConnection.setLocalDescription, .{});
        pub const setRemoteDescription = bridge.function(RTCPeerConnection.setRemoteDescription, .{});
        pub const addIceCandidate = bridge.function(RTCPeerConnection.addIceCandidate, .{});
        pub const getStats = bridge.function(RTCPeerConnection.getStats, .{});
        pub const createDataChannel = bridge.function(RTCPeerConnection.createDataChannel, .{});
        pub const addTrack = bridge.function(RTCPeerConnection.addTrack, .{});
        pub const removeTrack = bridge.function(RTCPeerConnection.removeTrack, .{});
        pub const addTransceiver = bridge.function(RTCPeerConnection.addTransceiver, .{});
        pub const getTransceivers = bridge.function(RTCPeerConnection.getTransceivers, .{});
        pub const getSenders = bridge.function(RTCPeerConnection.getSenders, .{});
        pub const getReceivers = bridge.function(RTCPeerConnection.getReceivers, .{});
        pub const close = bridge.function(RTCPeerConnection.close, .{});
        pub const restartIce = bridge.function(RTCPeerConnection.restartIce, .{});

        // Event handlers
        pub const onicecandidate = bridge.accessor(RTCPeerConnection.getOnIceCandidate, RTCPeerConnection.setOnIceCandidate, .{});
        pub const oniceconnectionstatechange = bridge.accessor(RTCPeerConnection.getOnIceConnectionStateChange, RTCPeerConnection.setOnIceConnectionStateChange, .{});
        pub const onicegatheringstatechange = bridge.accessor(RTCPeerConnection.getOnIceGatheringStateChange, RTCPeerConnection.setOnIceGatheringStateChange, .{});
        pub const onconnectionstatechange = bridge.accessor(RTCPeerConnection.getOnConnectionStateChange, RTCPeerConnection.setOnConnectionStateChange, .{});
        pub const onnegotiationneeded = bridge.accessor(RTCPeerConnection.getOnNegotiationNeeded, RTCPeerConnection.setOnNegotiationNeeded, .{});
        pub const ondatachannel = bridge.accessor(RTCPeerConnection.getOnDataChannel, RTCPeerConnection.setOnDataChannel, .{});
        pub const ontrack = bridge.accessor(RTCPeerConnection.getOnTrack, RTCPeerConnection.setOnTrack, .{});
        pub const onsignalingstatechange = bridge.accessor(RTCPeerConnection.getOnSignalingStateChange, RTCPeerConnection.setOnSignalingStateChange, .{});
    };
};

/// RTCSessionDescription - represents a session description
pub const RTCSessionDescription = struct {
    _type: []const u8,
    _sdp: []const u8,

    const Init = struct {
        type: []const u8,
        sdp: ?[]const u8 = null,
    };

    pub fn constructor(init: ?Init, page: *Page) !*RTCSessionDescription {
        const type_val = if (init) |i| i.type else "offer";
        const sdp_val = if (init) |i| i.sdp orelse "" else "";
        return page._factory.create(RTCSessionDescription{
            ._type = type_val,
            ._sdp = sdp_val,
        });
    }

    pub fn getType(self: *const RTCSessionDescription) []const u8 {
        return self._type;
    }

    pub fn getSdp(self: *const RTCSessionDescription) []const u8 {
        return self._sdp;
    }

    pub fn toJSON(self: *const RTCSessionDescription) []const u8 {
        _ = self;
        return "{}";
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(RTCSessionDescription);

        pub const Meta = struct {
            pub const name = "RTCSessionDescription";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(RTCSessionDescription.constructor, .{});
        pub const @"type" = bridge.accessor(RTCSessionDescription.getType, null, .{});
        pub const sdp = bridge.accessor(RTCSessionDescription.getSdp, null, .{});
        pub const toJSON = bridge.function(RTCSessionDescription.toJSON, .{});
    };
};

/// RTCIceCandidate - represents an ICE candidate
pub const RTCIceCandidate = struct {
    _candidate: []const u8,
    _sdp_mid: ?[]const u8,
    _sdp_m_line_index: ?u32,
    _username_fragment: ?[]const u8,

    const Init = struct {
        candidate: ?[]const u8 = null,
        sdpMid: ?[]const u8 = null,
        sdpMLineIndex: ?u32 = null,
        usernameFragment: ?[]const u8 = null,
    };

    pub fn constructor(init: ?Init, page: *Page) !*RTCIceCandidate {
        const i = init orelse Init{};
        return page._factory.create(RTCIceCandidate{
            ._candidate = i.candidate orelse "",
            ._sdp_mid = i.sdpMid,
            ._sdp_m_line_index = i.sdpMLineIndex,
            ._username_fragment = i.usernameFragment,
        });
    }

    pub fn getCandidate(self: *const RTCIceCandidate) []const u8 {
        return self._candidate;
    }

    pub fn getSdpMid(self: *const RTCIceCandidate) ?[]const u8 {
        return self._sdp_mid;
    }

    pub fn getSdpMLineIndex(self: *const RTCIceCandidate) ?u32 {
        return self._sdp_m_line_index;
    }

    pub fn getUsernameFragment(self: *const RTCIceCandidate) ?[]const u8 {
        return self._username_fragment;
    }

    pub fn getFoundation(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getComponent(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getPriority(_: *const RTCIceCandidate) ?u32 {
        return null;
    }

    pub fn getAddress(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getProtocol(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getPort(_: *const RTCIceCandidate) ?u16 {
        return null;
    }

    pub fn getTypeField(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getTcpType(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getRelatedAddress(_: *const RTCIceCandidate) ?[]const u8 {
        return null;
    }

    pub fn getRelatedPort(_: *const RTCIceCandidate) ?u16 {
        return null;
    }

    pub fn toJSON(self: *const RTCIceCandidate) []const u8 {
        _ = self;
        return "{}";
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(RTCIceCandidate);

        pub const Meta = struct {
            pub const name = "RTCIceCandidate";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const constructor = bridge.constructor(RTCIceCandidate.constructor, .{});
        pub const candidate = bridge.accessor(RTCIceCandidate.getCandidate, null, .{});
        pub const sdpMid = bridge.accessor(RTCIceCandidate.getSdpMid, null, .{});
        pub const sdpMLineIndex = bridge.accessor(RTCIceCandidate.getSdpMLineIndex, null, .{});
        pub const usernameFragment = bridge.accessor(RTCIceCandidate.getUsernameFragment, null, .{});
        pub const foundation = bridge.accessor(RTCIceCandidate.getFoundation, null, .{});
        pub const component = bridge.accessor(RTCIceCandidate.getComponent, null, .{});
        pub const priority = bridge.accessor(RTCIceCandidate.getPriority, null, .{});
        pub const address = bridge.accessor(RTCIceCandidate.getAddress, null, .{});
        pub const protocol = bridge.accessor(RTCIceCandidate.getProtocol, null, .{});
        pub const port = bridge.accessor(RTCIceCandidate.getPort, null, .{});
        pub const @"type" = bridge.accessor(RTCIceCandidate.getTypeField, null, .{});
        pub const tcpType = bridge.accessor(RTCIceCandidate.getTcpType, null, .{});
        pub const relatedAddress = bridge.accessor(RTCIceCandidate.getRelatedAddress, null, .{});
        pub const relatedPort = bridge.accessor(RTCIceCandidate.getRelatedPort, null, .{});
        pub const toJSON = bridge.function(RTCIceCandidate.toJSON, .{});
    };
};

/// RTCDataChannel - stub data channel that's always closed
pub const RTCDataChannel = struct {
    _label: []const u8,

    pub fn getLabel(self: *const RTCDataChannel) []const u8 {
        return self._label;
    }

    pub fn getOrdered(_: *const RTCDataChannel) bool {
        return true;
    }

    pub fn getMaxPacketLifeTime(_: *const RTCDataChannel) ?u16 {
        return null;
    }

    pub fn getMaxRetransmits(_: *const RTCDataChannel) ?u16 {
        return null;
    }

    pub fn getProtocol(_: *const RTCDataChannel) []const u8 {
        return "";
    }

    pub fn getNegotiated(_: *const RTCDataChannel) bool {
        return false;
    }

    pub fn getId(_: *const RTCDataChannel) ?u16 {
        return null;
    }

    pub fn getReadyState(_: *const RTCDataChannel) []const u8 {
        return "closed";
    }

    pub fn getBufferedAmount(_: *const RTCDataChannel) u32 {
        return 0;
    }

    pub fn getBufferedAmountLowThreshold(_: *const RTCDataChannel) u32 {
        return 0;
    }

    pub fn setBufferedAmountLowThreshold(_: *RTCDataChannel, _: u32) void {}

    pub fn getBinaryType(_: *const RTCDataChannel) []const u8 {
        return "arraybuffer";
    }

    pub fn setBinaryType(_: *RTCDataChannel, _: []const u8) void {}

    pub fn send(_: *RTCDataChannel, _: js.Object) void {}

    pub fn close(_: *RTCDataChannel) void {}

    pub const JsApi = struct {
        pub const bridge = js.Bridge(RTCDataChannel);

        pub const Meta = struct {
            pub const name = "RTCDataChannel";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const label = bridge.accessor(RTCDataChannel.getLabel, null, .{});
        pub const ordered = bridge.accessor(RTCDataChannel.getOrdered, null, .{});
        pub const maxPacketLifeTime = bridge.accessor(RTCDataChannel.getMaxPacketLifeTime, null, .{});
        pub const maxRetransmits = bridge.accessor(RTCDataChannel.getMaxRetransmits, null, .{});
        pub const protocol = bridge.accessor(RTCDataChannel.getProtocol, null, .{});
        pub const negotiated = bridge.accessor(RTCDataChannel.getNegotiated, null, .{});
        pub const id = bridge.accessor(RTCDataChannel.getId, null, .{});
        pub const readyState = bridge.accessor(RTCDataChannel.getReadyState, null, .{});
        pub const bufferedAmount = bridge.accessor(RTCDataChannel.getBufferedAmount, null, .{});
        pub const bufferedAmountLowThreshold = bridge.accessor(RTCDataChannel.getBufferedAmountLowThreshold, RTCDataChannel.setBufferedAmountLowThreshold, .{});
        pub const binaryType = bridge.accessor(RTCDataChannel.getBinaryType, RTCDataChannel.setBinaryType, .{});
        pub const send = bridge.function(RTCDataChannel.send, .{});
        pub const close = bridge.function(RTCDataChannel.close, .{});
    };
};

/// RTCError - error type for WebRTC operations
pub const RTCError = struct {
    _error_detail: []const u8,
    _sdp_line_number: ?i32,
    _http_request_status_code: ?i32,
    _sctp_cause_code: ?i32,
    _received_alert: ?u32,
    _sent_alert: ?u32,

    pub fn getErrorDetail(self: *const RTCError) []const u8 {
        return self._error_detail;
    }

    pub fn getSdpLineNumber(self: *const RTCError) ?i32 {
        return self._sdp_line_number;
    }

    pub fn getHttpRequestStatusCode(self: *const RTCError) ?i32 {
        return self._http_request_status_code;
    }

    pub fn getSctpCauseCode(self: *const RTCError) ?i32 {
        return self._sctp_cause_code;
    }

    pub fn getReceivedAlert(self: *const RTCError) ?u32 {
        return self._received_alert;
    }

    pub fn getSentAlert(self: *const RTCError) ?u32 {
        return self._sent_alert;
    }

    pub const JsApi = struct {
        pub const bridge = js.Bridge(RTCError);

        pub const Meta = struct {
            pub const name = "RTCError";
            pub const prototype_chain = bridge.prototypeChain();
            pub var class_id: bridge.ClassId = undefined;
        };

        pub const errorDetail = bridge.accessor(RTCError.getErrorDetail, null, .{});
        pub const sdpLineNumber = bridge.accessor(RTCError.getSdpLineNumber, null, .{});
        pub const httpRequestStatusCode = bridge.accessor(RTCError.getHttpRequestStatusCode, null, .{});
        pub const sctpCauseCode = bridge.accessor(RTCError.getSctpCauseCode, null, .{});
        pub const receivedAlert = bridge.accessor(RTCError.getReceivedAlert, null, .{});
        pub const sentAlert = bridge.accessor(RTCError.getSentAlert, null, .{});
    };
};
