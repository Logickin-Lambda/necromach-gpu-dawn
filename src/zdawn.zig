const std = @import("std");

const c = @cImport({
    @cInclude("dawn/dawn_proc_table.h");
});

export const proc_table = resolveProcTable();

fn resolveProcTable() c.DawnProcTable {
    var table = c.DawnProcTable{};
    const fields = @typeInfo(c.DawnProcTable).@"struct".fields;
    inline for (fields) |f| {
        const base = f.name; // "createInstance"
        const sym = "wgpu" ++ [1]u8{std.ascii.toUpper(base[0])} ++ base[1..]; // "wgpuCreateInstance"
        @field(table, f.name) = @extern(f.type, .{ .name = sym });
    }
    return table;
}
