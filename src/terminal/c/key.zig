const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;
const lib_alloc = @import("../../lib/allocator.zig");
const CAllocator = lib_alloc.Allocator;
const key = @import("../../input/key.zig");
const Result = @import("result.zig").Result;

/// Wrapper around KeyEvent that tracks the allocator for C API usage.
/// The UTF-8 text is not owned by this wrapper - the caller is responsible
/// for ensuring the lifetime of any UTF-8 text set via set_utf8.
const KeyEventWrapper = struct {
    event: key.KeyEvent = .{},
    alloc: Allocator,
};

/// C: GhosttyKeyEvent
pub const Event = ?*KeyEventWrapper;

pub fn new(
    alloc_: ?*const CAllocator,
    result: *Event,
) callconv(.c) Result {
    const alloc = lib_alloc.default(alloc_);
    const ptr = alloc.create(KeyEventWrapper) catch
        return .out_of_memory;
    ptr.* = .{ .alloc = alloc };
    result.* = ptr;
    return .success;
}

pub fn free(event_: Event) callconv(.c) void {
    const wrapper = event_ orelse return;
    const alloc = wrapper.alloc;
    alloc.destroy(wrapper);
}

/// C: GhosttyKeyEventOption
pub const EventOption = enum(c_int) {
    action = 1,
    key = 2,
    mods = 3,
    consumed_mods = 4,
    composing = 5,
    utf8 = 6,
    unshifted_codepoint = 7,

    /// Input type expected for setting the given option.
    pub fn SetType(comptime self: EventOption) type {
        return switch (self) {
            .action => key.Action,
            .key => key.Key,
            .mods => key.Mods,
            .consumed_mods => key.Mods,
            .composing => bool,
            .utf8 => ?[*:0]const u8,
            .unshifted_codepoint => u32,
        };
    }

    /// Output type expected for getting the given option.
    pub fn GetType(comptime self: EventOption) type {
        return switch (self) {
            .action => key.Action,
            .key => key.Key,
            .mods => key.Mods,
            .consumed_mods => key.Mods,
            .composing => bool,
            .utf8 => ?[*:0]const u8,
            .unshifted_codepoint => u32,
        };
    }
};

pub fn set(event_: Event, option: EventOption, value: ?*const anyopaque) callconv(.c) void {
    switch (option) {
        inline else => |comptime_option| setTyped(
            event_,
            comptime_option,
            @ptrCast(@alignCast(value)),
        ),
    }
}

fn setTyped(
    event_: Event,
    comptime option: EventOption,
    value: *const option.SetType(),
) void {
    const event: *key.KeyEvent = &event_.?.event;
    switch (option) {
        .action => event.action = value.*,
        .key => event.key = value.*,
        .mods => event.mods = value.*,
        .consumed_mods => event.consumed_mods = value.*,
        .composing => event.composing = value.*,
        .utf8 => event.utf8 = std.mem.span(value.* orelse ""),
        .unshifted_codepoint => event.unshifted_codepoint = @truncate(value.*),
    }
}

pub fn get(event_: Event, option: EventOption, value: ?*anyopaque) callconv(.c) void {
    switch (option) {
        inline else => |comptime_option| getTyped(
            event_,
            comptime_option,
            @ptrCast(@alignCast(value)),
        ),
    }
}

fn getTyped(
    event_: Event,
    comptime option: EventOption,
    out: *option.GetType(),
) void {
    const event: *key.KeyEvent = &event_.?.event;
    out.* = switch (option) {
        .action => event.action,
        .key => event.key,
        .mods => event.mods,
        .consumed_mods => event.consumed_mods,
        .composing => event.composing,
        .utf8 => if (event.utf8.len == 0) null else @ptrCast(event.utf8.ptr),
        .unshifted_codepoint => event.unshifted_codepoint,
    };
}

test "alloc" {
    const testing = std.testing;
    var e: Event = undefined;
    try testing.expectEqual(Result.success, new(
        &lib_alloc.test_allocator,
        &e,
    ));
    free(e);
}

test "set" {
    const testing = std.testing;
    var e: Event = undefined;
    try testing.expectEqual(Result.success, new(
        &lib_alloc.test_allocator,
        &e,
    ));
    defer free(e);

    // Test action
    const action = key.Action.press;
    set(e, .action, &action);
    try testing.expectEqual(key.Action.press, e.?.event.action);

    // Test key
    const k = key.Key.key_a;
    set(e, .key, &k);
    try testing.expectEqual(key.Key.key_a, e.?.event.key);

    // Test mods
    const mods: key.Mods = .{ .shift = true, .ctrl = true };
    set(e, .mods, &mods);
    try testing.expect(e.?.event.mods.shift);
    try testing.expect(e.?.event.mods.ctrl);

    // Test consumed mods
    const consumed: key.Mods = .{ .shift = true };
    set(e, .consumed_mods, &consumed);
    try testing.expect(e.?.event.consumed_mods.shift);
    try testing.expect(!e.?.event.consumed_mods.ctrl);

    // Test composing
    const composing = true;
    set(e, .composing, &composing);
    try testing.expect(e.?.event.composing);

    // Test UTF-8
    const text = "hello";
    const text_ptr: ?[*:0]const u8 = text.ptr;
    set(e, .utf8, @ptrCast(&text_ptr));
    try testing.expectEqualStrings(text, e.?.event.utf8);

    // Test UTF-8 null
    const null_ptr: ?[*:0]const u8 = null;
    set(e, .utf8, @ptrCast(&null_ptr));
    try testing.expectEqualStrings("", e.?.event.utf8);

    // Test unshifted codepoint
    const codepoint: u32 = 'a';
    set(e, .unshifted_codepoint, &codepoint);
    try testing.expectEqual(@as(u21, 'a'), e.?.event.unshifted_codepoint);
}

test "get" {
    const testing = std.testing;
    var e: Event = undefined;
    try testing.expectEqual(Result.success, new(
        &lib_alloc.test_allocator,
        &e,
    ));
    defer free(e);

    // Set some values
    const action = key.Action.repeat;
    set(e, .action, &action);

    const k = key.Key.key_z;
    set(e, .key, &k);

    const mods: key.Mods = .{ .alt = true, .super = true };
    set(e, .mods, &mods);

    const consumed: key.Mods = .{ .alt = true };
    set(e, .consumed_mods, &consumed);

    const composing = true;
    set(e, .composing, &composing);

    const text = "test";
    const text_ptr: ?[*:0]const u8 = text.ptr;
    set(e, .utf8, @ptrCast(&text_ptr));

    const codepoint: u32 = 'z';
    set(e, .unshifted_codepoint, &codepoint);

    // Get them back
    var got_action: key.Action = undefined;
    get(e, .action, &got_action);
    try testing.expectEqual(key.Action.repeat, got_action);

    var got_key: key.Key = undefined;
    get(e, .key, &got_key);
    try testing.expectEqual(key.Key.key_z, got_key);

    var got_mods: key.Mods = undefined;
    get(e, .mods, &got_mods);
    try testing.expect(got_mods.alt);
    try testing.expect(got_mods.super);

    var got_consumed: key.Mods = undefined;
    get(e, .consumed_mods, &got_consumed);
    try testing.expect(got_consumed.alt);
    try testing.expect(!got_consumed.super);

    var got_composing: bool = undefined;
    get(e, .composing, &got_composing);
    try testing.expect(got_composing);

    var got_utf8: ?[*:0]const u8 = undefined;
    get(e, .utf8, @ptrCast(&got_utf8));
    try testing.expect(got_utf8 != null);
    try testing.expectEqualStrings("test", std.mem.span(got_utf8.?));

    var got_codepoint: u32 = undefined;
    get(e, .unshifted_codepoint, &got_codepoint);
    try testing.expectEqual(@as(u32, 'z'), got_codepoint);
}

test "complete key event" {
    const testing = std.testing;
    var e: Event = undefined;
    try testing.expectEqual(Result.success, new(
        &lib_alloc.test_allocator,
        &e,
    ));
    defer free(e);

    // Build a complete key event for shift+a
    const action = key.Action.press;
    set(e, .action, &action);

    const k = key.Key.key_a;
    set(e, .key, &k);

    const mods: key.Mods = .{ .shift = true };
    set(e, .mods, &mods);

    const consumed: key.Mods = .{ .shift = true };
    set(e, .consumed_mods, &consumed);

    const text = "A";
    const text_ptr: ?[*:0]const u8 = text.ptr;
    set(e, .utf8, @ptrCast(&text_ptr));

    const codepoint: u32 = 'a';
    set(e, .unshifted_codepoint, &codepoint);

    // Verify all fields
    try testing.expectEqual(key.Action.press, e.?.event.action);
    try testing.expectEqual(key.Key.key_a, e.?.event.key);
    try testing.expect(e.?.event.mods.shift);
    try testing.expect(e.?.event.consumed_mods.shift);
    try testing.expectEqualStrings("A", e.?.event.utf8);
    try testing.expectEqual(@as(u21, 'a'), e.?.event.unshifted_codepoint);
}
