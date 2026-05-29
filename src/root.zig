const std = @import("std");
pub const vm = @import("vm.zig");
pub const assembler = @import("assembler.zig");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

test "basic e2e" {
    var machine = vm.VM{ .memory = undefined, .registers = undefined, .pc = 0 };
    var ass = assembler.Assembler{};
    var stdout_buffer: [1024]u8 = undefined;
    var writer: std.Io.Writer = .fixed(&stdout_buffer);
    machine.memory = try ass.assemble(&writer,
        \\ mov s1, #7
        \\ mov s2, #6
        \\ add s3, s1, s2
        \\ add s4, s3, s0
        \\ add s2, s4, s1
        \\ halt
    );
    try machine.run();
    try testing.expect(machine.registers[3] == 13);
    try testing.expect(machine.registers[3] == machine.registers[4]);
    try testing.expect(machine.registers[2] == 20);
}
