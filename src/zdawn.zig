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
    const fields = @typeInfo(c.DawnProcTable).@"struct".fields;
    for (fields) |f| {
        const base = f.name; // "createInstance"
        const sym = "wgpu" ++ [1]u8{std.ascii.toUpper(base[0])} ++ base[1..]; // "wgpuCreateInstance"
        @export(&@field(c, sym), .{ .name = sym, .linkage = .strong });
    }
}
