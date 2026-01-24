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

const js = @import("../../../js/js.zig");
const Page = @import("../../../Page.zig");
const Window = @import("../../Window.zig");
const Document = @import("../../Document.zig");
const Node = @import("../../Node.zig");
const Element = @import("../../Element.zig");
const HtmlElement = @import("../Html.zig");

const IFrame = @This();
_proto: *HtmlElement,

pub fn asElement(self: *IFrame) *Element {
    return self._proto._proto;
}
pub fn asNode(self: *IFrame) *Node {
    return self.asElement().asNode();
}

/// Returns the Window object for the iframe.
/// For sandbox iframes, this returns the main page's window to allow basic DOM access.
/// Note: Full iframe isolation would require separate JS contexts which is not implemented.
pub fn getContentWindow(_: *const IFrame, page: *Page) *Window {
    return page.window;
}

/// Returns the Document object for the iframe.
/// For sandbox iframes with allow-same-origin, returns the main document.
/// This enables scripts to access document.createElement and other DOM methods.
pub fn getContentDocument(_: *const IFrame, page: *Page) *Document {
    return page.document;
}

/// Returns the sandbox attribute value.
/// Empty string means sandboxing is enabled with all restrictions.
pub fn getSandbox(self: *const IFrame, page: *Page) ![]const u8 {
    const element = @constCast(self).asElement();
    return (try element.getAttribute("sandbox", page)) orelse "";
}

/// Sets the sandbox attribute.
pub fn setSandbox(self: *IFrame, value: []const u8, page: *Page) !void {
    const element = self.asElement();
    try element.setAttribute("sandbox", value, page);
}

/// Returns the src attribute.
pub fn getSrc(self: *const IFrame, page: *Page) ![]const u8 {
    const element = @constCast(self).asElement();
    return (try element.getAttribute("src", page)) orelse "";
}

/// Sets the src attribute.
pub fn setSrc(self: *IFrame, value: []const u8, page: *Page) !void {
    const element = self.asElement();
    try element.setAttribute("src", value, page);
}

pub const JsApi = struct {
    pub const bridge = js.Bridge(IFrame);

    pub const Meta = struct {
        pub const name = "HTMLIFrameElement";
        pub const prototype_chain = bridge.prototypeChain();
        pub var class_id: bridge.ClassId = undefined;
    };

    pub const contentWindow = bridge.accessor(IFrame.getContentWindow, null, .{});
    pub const contentDocument = bridge.accessor(IFrame.getContentDocument, null, .{});
    pub const sandbox = bridge.accessor(IFrame.getSandbox, IFrame.setSandbox, .{});
    pub const src = bridge.accessor(IFrame.getSrc, IFrame.setSrc, .{});
};
