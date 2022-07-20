const std = @import("std");
const node = @import("node.zig");
const DOM = @import("dom.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const leaked = gpa.deinit();
        if (leaked) @panic("GPA has leaked!");
    }

    var dom = DOM.createDOM(allocator);
    var hello = buildHello(dom);
    defer dom.destroyNode(hello);

    dom.prettyPrintNode(hello);

    std.log.info("Hey!", .{});
}

fn buildHello(dom: DOM.DOM) node.Node {
    var hello = dom.createStringNode("Hello!");
    var comment = dom.createCommentNode("sleeepy zzzz");

    var divChildren = node.createChildrenBuilder(dom.allocator).add(hello).add(comment).build();
    var div = dom.createElementNode("div", divChildren);
    return div;
}
 