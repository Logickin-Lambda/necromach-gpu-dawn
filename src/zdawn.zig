const std = @import("std");

// pub const c = @cImport({
//     @cInclude("dawn/dawn_proc_table.h");
// });

// export const proc_table = resolveProcTable();

// fn resolveProcTable() c.DawnProcTable {
//     var table = c.DawnProcTable{};
//     const fields = @typeInfo(c.DawnProcTable).@"struct".fields;
//     inline for (fields) |f| {
//         const base = f.name; // "createInstance"
//         const sym = "wgpu" ++ [1]u8{std.ascii.toUpper(base[0])} ++ base[1..]; // "wgpuCreateInstance"
//         @field(table, f.name) = @extern(f.type, .{ .name = sym });
//     }
//     return table;
// }

// export fn tester() void {
//     if (proc_table.createInstance) |createInstance| {
//         _ = createInstance(null);
//     }
// }

pub const c = @cImport({
    @cInclude("dawn/dawn_proc_table.h");
});

comptime {
    @setEvalBranchQuota(10000);
    const fields = @typeInfo(c.DawnProcTable).@"struct".fields;
    for (fields) |f| {
        const base = f.name; // "createInstance"
        const sym = "wgpu" ++ [1]u8{std.ascii.toUpper(base[0])} ++ base[1..]; // "wgpuCreateInstance"

        // @export(&struct {
        //     pub fn call() callconv(.C) void {
        //         return @call(.always_inline, @field(c, sym), .{});
        //     }
        // }.call, .{ .name = sym, .linkage = .strong });

        const target_func = @field(c, sym);
        const wrapper = forwarder(target_func);
        @export(&wrapper.call, .{ .name = f.name, .linkage = .strong });
        // @export(&wrapper.call, .{ .name = sym, .linkage = .strong });
    }
}

fn forwarder(comptime target: anytype) type {
    const fn_info = @typeInfo(@TypeOf(target)).@"fn";
    const Ret = fn_info.return_type orelse void;
    const ps = fn_info.params;

    switch (ps.len) {
        0 => return struct {
            pub fn call() callconv(.C) Ret {
                return target();
            }
        },
        1 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                ) callconv(.C) Ret {
                    return target(a0);
                }
            };
        },
        2 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                    a1: ps[1].type.?,
                ) callconv(.C) Ret {
                    return target(a0, a1);
                }
            };
        },
        3 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                    a1: ps[1].type.?,
                    a2: ps[2].type.?,
                ) callconv(.C) Ret {
                    return target(a0, a1, a2);
                }
            };
        },
        4 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                    a1: ps[1].type.?,
                    a2: ps[2].type.?,
                    a3: ps[3].type.?,
                ) callconv(.C) Ret {
                    return target(a0, a1, a2, a3);
                }
            };
        },
        5 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                    a1: ps[1].type.?,
                    a2: ps[2].type.?,
                    a3: ps[3].type.?,
                    a4: ps[4].type.?,
                ) callconv(.C) Ret {
                    return target(a0, a1, a2, a3, a4);
                }
            };
        },
        6 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                    a1: ps[1].type.?,
                    a2: ps[2].type.?,
                    a3: ps[3].type.?,
                    a4: ps[4].type.?,
                    a5: ps[5].type.?,
                ) callconv(.C) Ret {
                    return target(a0, a1, a2, a3, a4, a5);
                }
            };
        },
        7 => {
            return struct {
                pub fn call(
                    a0: ps[0].type.?,
                    a1: ps[1].type.?,
                    a2: ps[2].type.?,
                    a3: ps[3].type.?,
                    a4: ps[4].type.?,
                    a5: ps[5].type.?,
                    a6: ps[6].type.?,
                ) callconv(.C) Ret {
                    return target(a0, a1, a2, a3, a4, a5, a6);
                }
            };
        },
        else => @compileError("forwarder(): add another case for >7 params"),
    }
}
