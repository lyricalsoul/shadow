const std = @import("std");

pub const NodeChildren = std.ArrayList(Node);
pub const ElementAttributes = std.StringArrayHashMap([]const u8);
pub const Allocator = std.mem.Allocator;

pub const Node = struct {
    children: ?NodeChildren,
    value: NodeType
};

pub const NodeTypeTag = enum { text, element, comment };
pub const NodeType = union(NodeTypeTag) {
    text: []const u8,
    element: ElementData,
    comment: []const u8
};

pub const ElementData = struct {
    tag_name: []const u8,
    attributes: ElementAttributes
};

pub const NodeChildrenBuilder = struct {
    list: NodeChildren,

    pub fn add(self: NodeChildrenBuilder, node: Node) NodeChildrenBuilder {
        self.list.append(node) catch @panic("Couldn't add node to NodeChildrenBuilder!!");
        return self;
    }

    pub fn build(self: NodeChildrenBuilder) NodeChildren {
        return self.list;
    }
};

pub fn createChildrenBuilder(allocator: Allocator) NodeChildrenBuilder {
    return NodeChildrenBuilder{ .list = NodeChildren.init(allocator) };}