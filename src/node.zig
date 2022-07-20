const std = @import("std");

const NodeChildren = std.ArrayList(Node);
const ElementAttributes = std.StringArrayHashMap(string);
const Allocator = std.mem.Allocator;
const debug = std.log.info;
const string = []const u8;

pub const Node = struct {
    children: ?NodeChildren,
    value: NodeType
};

pub const NodeTypeTag = enum { text, element, comment };
pub const NodeType = union(NodeTypeTag) {
    text: string,
    element: ElementData,
    comment: string
};

pub const ElementData = struct {
    tag_name: string,
    attributes: ElementAttributes
};

pub fn createEmptyNodeChildrenList(allocator: Allocator) NodeChildren {
    return NodeChildren.init(allocator);
}

pub fn createStringNode(text: string) Node {
    return Node{
        .children = null,
        .value = NodeType{ .text = text }
    };
}

pub fn createCommentNode(comment: string) Node {
    return Node{
        .children = null,
        .value = NodeType{ .comment = comment }
    };
}

pub fn createElementNode(tag: string, allocator: Allocator, children: ?NodeChildren) Node {
    var attrs = ElementAttributes.init(allocator);
    
    return Node{
        .children = if (children == null) createEmptyNodeChildrenList(allocator) else children,
        .value = NodeType{
            .element = ElementData{
                .tag_name = tag,
                .attributes = attrs
            }
        }
    };
}

pub fn destroyNode(node: Node) void {
    if (node.children != null) {
        for (node.children.?.items) |child, i| {
            debug("destroying node child {d}", .{i});
            destroyNode(child);
        }
        node.children.?.deinit();
    }

    switch (node.value) {
        .element => destroyElementNode(node),
        else => {}
    }

    debug("node was successfully deinited", .{});
}

fn destroyElementNode (node: Node) void {
    debug("destroying element node data", .{});
    var element = node.value.element;

    element.attributes.clearAndFree();
}

pub fn humanifyNode(node: Node) void {
    switch (node.value) {
        .element => std.debug.print("ElementNode ({s}) [", .{node.value.element.tag_name}),
        .comment => std.debug.print("CommentNode = {s}", .{node.value.comment}),
        .text => std.debug.print("TextNode = {s}", .{node.value.text}),
        // else => return "UnknownNode"
    }

    std.debug.print("\n", .{});
}

pub fn prettyPrintNode(node: Node) void {
    std.debug.print("{s}", .{" " ** 2});
    humanifyNode(node);
    if (node.children != null) {
        for (node.children.?.items) |child| {
           prettyPrintNode(child);
        }
        std.debug.print("  ]\n", .{});
    }
}