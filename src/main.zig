const std = @import("std");
const binding = @import("binding");

const log = std.log.scoped(.ffi);

// override the std implementation
pub const std_options = struct {
    pub const log_level = .info;
};

pub fn main() !void {
    log.info("Initializing shared data...\n", .{});
    binding.init_shared_data();

    defer {
        log.info("Shutting down the Rust Tokio event loop...\n", .{});
        binding.shutdown_event_loop();
    }

    log.info("Starting Rust Tokio event loop...\n", .{});
    binding.start_event_loop(10); // Set the counter limit to 10
}
