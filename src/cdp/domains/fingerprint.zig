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
const lp = @import("lightpanda");

pub fn processMessage(cmd: anytype) !void {
    const action = std.meta.stringToEnum(enum {
        setProfile,
        setProfileForPage,
        clearProfileForPage,
    }, cmd.input.action) orelse return error.UnknownMethod;

    switch (action) {
        .setProfile => return setProfile(cmd),
        .setProfileForPage => return setProfileForPage(cmd),
        .clearProfileForPage => return clearProfileForPage(cmd),
    }
}

fn setProfile(cmd: anytype) !void {
    const params = (try cmd.params(struct {
        profile: lp.App.FingerprintProfile,
    })) orelse return error.InvalidParams;

    try params.profile.validate();
    cmd.cdp.browser.app.config.fingerprint_profile = params.profile;

    return cmd.sendResult(null, .{ .include_session_id = false });
}

fn setProfileForPage(cmd: anytype) !void {
    const params = (try cmd.params(struct {
        targetId: []const u8,
        profile: lp.App.FingerprintProfile,
    })) orelse return error.InvalidParams;

    try params.profile.validate();

    const bc = cmd.browser_context orelse return error.BrowserContextNotLoaded;
    const page = bc.session.currentPage() orelse return error.PageNotLoaded;
    const target_id = bc.target_id orelse return error.TargetNotLoaded;
    if (!std.mem.eql(u8, target_id, params.targetId)) {
        return error.UnknownTargetId;
    }

    page.setFingerprintOverride(params.profile);
    return cmd.sendResult(null, .{});
}

fn clearProfileForPage(cmd: anytype) !void {
    const params = (try cmd.params(struct {
        targetId: []const u8,
    })) orelse return error.InvalidParams;

    const bc = cmd.browser_context orelse return error.BrowserContextNotLoaded;
    const page = bc.session.currentPage() orelse return error.PageNotLoaded;
    const target_id = bc.target_id orelse return error.TargetNotLoaded;
    if (!std.mem.eql(u8, target_id, params.targetId)) {
        return error.UnknownTargetId;
    }

    page.clearFingerprintOverride();
    return cmd.sendResult(null, .{});
}

const testing = @import("../testing.zig");
test "cdp.fingerprint: setProfile" {
    var ctx = testing.context();
    defer ctx.deinit();

    const profile = lp.App.FingerprintProfile.defaultMacOS();
    const json = try std.json.Stringify.valueAlloc(
        std.testing.allocator,
        .{ .id = 1, .method = "Fingerprint.setProfile", .params = .{ .profile = profile } },
        .{ .emit_null_optional_fields = false },
    );
    defer std.testing.allocator.free(json);

    try ctx.processMessage(json);
    try ctx.expectSentCount(1);
}

