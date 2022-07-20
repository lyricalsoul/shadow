const std = @import("std");
const node = @import("node.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("GPA has leaked!");
    }

    var hello = buildHello(allocator);
    defer node.destroyNode(hello);

    node.prettyPrintNode(hello);

    std.log.info("Hey!", .{});
}

fn buildHello(allocator: std.mem.Allocator) node.Node {
    var hello = node.createStringNode("Hello!");
    var comment = node.createCommentNode("sleeepy zzzz");

    var divChildren = node.createEmptyNodeChildrenList(allocator);
    divChildren.append(hello) catch {
        @panic("Failed to append child to element!");
    };
    divChildren.append(comment) catch {
        @panic("Failed to append child to element!");
    };

    var div = node.createElementNode("hello", allocator, divChildren);
    return div;
}
