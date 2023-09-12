const std = @import("std");
const binding = @import("binding");
const print = std.log.info;

pub fn main() !void {
    print("Initializing shared data...\n", .{});
    binding.init_shared_data();

    print("Starting Rust Tokio event loop...\n", .{});
    binding.start_event_loop(10); // Set the counter limit to 10

    print("Shutting down the Rust Tokio event loop...\n", .{});
    binding.shutdown_event_loop();
}
