const std = @import("std");
const node_mod = @import("node.zig");

const Node = node_mod.Node;
const NodeChildren = node_mod.NodeChildren;
const NodeType = node_mod.NodeType;
const ElementAttributes = node_mod.ElementAttributes;
const ElementData = node_mod.ElementData;

const debug = std.log.info;
const Allocator = std.mem.Allocator;

pub const DOM = struct {
    allocator: Allocator,

    pub fn createEmptyNodeChildrenList(self: DOM) NodeChildren {
        return NodeChildren.init(self.allocator);
    }

    pub fn createStringNode(_: DOM, text: []const u8) Node {
        return Node{
            .children = null,
            .value = NodeType{ .text = text }
        };
    }

    pub fn createCommentNode(_: DOM, comment: []const u8) Node {
        return Node{
            .children = null,
            .value = NodeType{ .comment = comment }
        };
    }

    pub fn createChildrenList(self: DOM) NodeChildren {
        var children = NodeChildren.init(self.allocator);
        return children;
    }

    pub fn createElementNode(self: DOM, tag: []const u8, children: ?NodeChildren) Node {
        var attrs = ElementAttributes.init(self.allocator);
    
        return Node{
            .children = if (children == null) self.createChildrenList() else children,
            .value = NodeType{
                .element = ElementData{
                    .tag_name = tag,
                    .attributes = attrs
                }
            }
        };
    }

    pub fn destroyNode(self: DOM, node: Node) void {
        if (node.children != null) {
            for (node.children.?.items) |child, i| {
                debug("destroying node child {d}", .{i});
                self.destroyNode(child);
            }
            node.children.?.deinit();
        }

        switch (node.value) {
            .element => self.destroyElementNode(node),
            else => {}
        }

        debug("node was successfully deinited", .{});
    }

    pub fn humanifyNode(_: DOM, node: Node) void {
        switch (node.value) {
            .element => std.debug.print("ElementNode ({s}) [", .{node.value.element.tag_name}),
            .comment => std.debug.print("CommentNode = {s}", .{node.value.comment}),
            .text => std.debug.print("TextNode = {s}", .{node.value.text}),
            // else => return "UnknownNode"
        }

        std.debug.print("\n", .{});
    }

    fn destroyElementNode (_: DOM, node: Node) void {
        debug("destroying element node data", .{});
        var element = node.value.element;

        element.attributes.clearAndFree();
    }

    pub fn prettyPrintNode(self: DOM, node: Node) void {
        std.debug.print("{s}", .{" " ** 2});
        self.humanifyNode(node);
        if (node.children != null) {
            for (node.children.?.items) |child| {
                self.prettyPrintNode(child);
            }
            std.debug.print("  ]\n", .{});
        }
    }
};

pub fn createDOM(allocator: Allocator) DOM {
    return DOM{
        .allocator = allocator
    };
}