const std = @import("std");
const binding = @import("binding");
const print = std.log.info;

pub fn main() anyerror!void {
    print("Multiply of 5*4={}", .{5 * 4});

    const chars = [_]u8{ 'a', ' ', 'A', 0x09, 0x0A, 0x0D };

    for (chars) |char, idx| {
        std.log.warn("{}: is '{c}' whitespace?: {}\n", .{ idx, char, binding.is_whitespace(char) });
    }
    var dg = binding.Doggo{ .age = 11, .name = "Brutus" };
    const d: ?*binding.Doggo = &dg;
    if (d) |doggo| {
        print("what your name: {s}\n", .{doggo.name.?});
        print("At what age: {}\n", .{doggo.age});
    } else {
        print("it's null\n", .{});
    }
}

test "import test" {
    _ = @import("binding");
}
