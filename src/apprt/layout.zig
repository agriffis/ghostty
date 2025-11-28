const std = @import("std");
const Allocator = std.mem.Allocator;
const configpkg = @import("../config.zig");
const datastruct = @import("../datastruct/main.zig");

/// Window represents a desired predefined layout for a window hierarchy:
/// a set of tabs, each with their own split tree.
pub const Window = struct {
    /// NOTE: For now, we guarantee tabs.len == 1. This is to simplify
    /// the initial implementation. In the future we will support layouts
    /// for multiple tabs.
    tabs: []const SplitTree,

    pub const CApi = struct {
        pub fn get_tabs_len(self: *const Window) callconv(.c) usize {
            return self.tabs.len;
        }

        pub fn get_tabs(self: *const Window) callconv(.c) [*]const SplitTree {
            return &self.tabs;
        }
    };
};

/// SplitTree represents a desired layout of splits and their associated
/// surface configurations. This is used by apprts to launch and modify
/// predefined terminal layouts.
///
/// This only represents a desired split tree; it doesn't represent
/// tabs, windows, or any other higher-level constructs. These will
/// be represented elsewhere. To start, we only support single-tab
/// layouts.
pub const SplitTree = datastruct.SplitTree(struct {
    const View = @This();

    /// A unique identifier for this leaf node. This is guaranteed to
    /// forever unique and not reused during the lifetime of the
    /// layout. This allows layouts to change at runtime and the apprt
    /// to diff them.
    ///
    /// It is up to the creator of the layout to ensure uniqueness
    /// when creating or updating layouts.
    id: u64,

    /// The configuration associated with this leaf node when creating
    /// the associated terminal surface.
    config: configpkg.Config,

    /// The reference count for this layout node. When it reaches
    /// zero it will be freed.
    refs: usize = 1,

    pub fn ref(self: *View, _: Allocator) Allocator.Error!*View {
        self.refs += 1;
        return self;
    }

    pub fn unref(self: *View, alloc: Allocator) void {
        self.refs -= 1;
        if (self.refs == 0) {
            self.config.deinit();
            alloc.destroy(self);
        }
    }

    pub const CApi = struct {
        pub fn get_id(self: *const View) callconv(.c) u64 {
            return self.id;
        }

        pub fn get_config(self: *const View) callconv(.c) *const configpkg.Config {
            return &self.config;
        }
    };
});
