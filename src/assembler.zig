const std = @import("std");
const vm = @import("vm.zig");
const testing = std.testing;

fn consumeUntil(input: *[]const u8, token: u8) ?[]const u8 {
    if (input.*.len == 0) {
        return null;
    }

    var result: []const u8 = undefined;

    if (std.mem.findScalar(u8, input.*, token)) |idx| {
        result = input.*[0..idx];
        input.* = input.*[idx + 1 ..];
    } else {
        result = input.*;
        input.* = input.*[input.*.len..];
    }
    return result;
}
fn consumeTrimmedUntil(input: *[]const u8, token: u8) ?[]const u8 {
    if (consumeUntil(input, token)) |rest| {
        return std.mem.trim(u8, rest, " \t\r\n");
    }
    return null;
}

const opcode_map = std.StaticStringMap(vm.Opcode).initComptime(.{
    .{ "add", vm.Opcode.add },
    .{ "mov", vm.Opcode.mov },
    .{ "load", vm.Opcode.load },
    .{ "store", vm.Opcode.store },
});

const Assembler = struct {
    fn parse_instruction(self: *Assembler, opcode: []const u8, line: *[]const u8) void {
        _ = self;

        if (opcode_map.get(opcode)) |op| {
            std.debug.print("opcode: {any}\n", .{op});
            while (consumeTrimmedUntil(line, ',')) |operand| {
                std.debug.print("operand: {s}\n", .{operand});
            }
        } else {
            std.debug.print("unknown opcode: {s}\n", .{opcode});
        }
    }
    fn parse_line(self: *Assembler, line: *[]const u8) void {
        if (consumeUntil(line, ' ')) |token| {
            self.parse_instruction(token, line);
        }
    }
    fn assemble(self: *Assembler, assembly: []const u8) void {
        var lines = std.mem.splitScalar(u8, assembly, '\n');

        while (lines.next()) |line| {
            var line_slice = line;
            self.parse_line(&line_slice);
        }
    }
};

test "assembler basic" {
    var assembler = Assembler{};
    assembler.assemble(
        \\add s1, s2, s3
        \\mov s3, s1
        \\add s1, s1, #5
    );
}
