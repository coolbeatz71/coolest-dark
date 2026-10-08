//! Zig language tour.
//!
//! Covers structs, enums, unions, error sets, optionals, comptime,
//! allocators, defer/errdefer, slices and testing.

const std = @import("std");
const Allocator = std.mem.Allocator;
const testing = std.testing;

/// Severity levels for a log line.
pub const Severity = enum(u8) {
    debug = 1,
    info = 2,
    warning = 3,
    err = 4,

    /// Returns true for warning and above.
    pub fn isSevere(self: Severity) bool {
        return @intFromEnum(self) >= @intFromEnum(Severity.warning);
    }
};

/// Errors this module can produce.
pub const RepoError = error{
    NotFound,
    Closed,
    OutOfMemory,
};

/// A tagged union.
pub const Outcome = union(enum) {
    success: LogEntry,
    failure: RepoError,
    empty: void,
};

/// An immutable value type.
pub const LogEntry = struct {
    message: []const u8,
    severity: Severity = .info,
    tags: []const []const u8 = &.{},

    /// Formats the entry. Called by `std.fmt`.
    pub fn format(
        self: LogEntry,
        comptime fmt: []const u8,
        options: std.fmt.FormatOptions,
        writer: anytype,
    ) !void {
        _ = fmt; // inline comment: unused parameters must be discarded
        _ = options;
        try writer.print("[{s}] {s} ({d} tags)", .{
            @tagName(self.severity),
            self.message,
            self.tags.len,
        });
    }
};

/// A generic repository, built at comptime for any value type.
pub fn Repository(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: Allocator,
        store: std.AutoHashMap(u32, T),

        pub fn init(allocator: Allocator) Self {
            return .{ .allocator = allocator, .store = std.AutoHashMap(u32, T).init(allocator) };
        }

        pub fn deinit(self: *Self) void {
            self.store.deinit();
        }

        /// Finds one entry.
        ///
        /// Returns `RepoError.NotFound` when nothing matches.
        pub fn findById(self: *const Self, id: u32) RepoError!T {
            return self.store.get(id) orelse RepoError.NotFound;
        }

        pub fn put(self: *Self, id: u32, value: T) !void {
            try self.store.put(id, value);
        }
    };
}

/// Classifies a count and severity.
pub fn describe(count: usize, severity: Severity) []const u8 {
    if (count == 0) return "empty";

    return switch (severity) {
        .err => "failing",
        .warning, .info => if (count > 100) "busy" else "ok",
        .debug => "ok",
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var repo = Repository(LogEntry).init(allocator);
    defer repo.deinit();

    try repo.put(1, .{ .message = "hello", .severity = .err });

    const entry = repo.findById(1) catch |err| switch (err) {
        RepoError.NotFound => return,
        else => return err,
    };

    std.debug.print("{} -> {s}\n", .{ entry, describe(150, entry.severity) });
}

test "describe classifies correctly" {
    try testing.expectEqualStrings("empty", describe(0, .info));
    try testing.expectEqualStrings("failing", describe(5, .err));
    try testing.expectEqualStrings("busy", describe(200, .info));
}
