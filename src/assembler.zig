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

fn parse_opcode(raw_opcode: []const u8) ?vm.Opcode {
    inline for (@typeInfo(vm.Opcode).@"enum".fields) |field| {
        if (std.mem.eql(u8, field.name, raw_opcode)) {
            return @enumFromInt(field.value);
        }
    }
    return null;
}

const AssemblerError = error{
    MissingRegister,
    MissingImmediate,
    InvalidRegister,
    InvalidImmediate,
};

const Assembler = struct {
    inline fn parseRegister(line: *[]const u8) !u5 {
        const op = consumeTrimmedUntil(line, ',') orelse return AssemblerError.MissingRegister;
        if (op[0] != 's') return AssemblerError.InvalidRegister;
        return std.fmt.parseInt(u5, op[1..], 10);
    }
    inline fn parseImmediate(line: *[]const u8) !u18 {
        const op = consumeTrimmedUntil(line, ',') orelse return AssemblerError.MissingImmediate;
        if (op[0] != '#') return AssemblerError.InvalidImmediate;
        return std.fmt.parseInt(u18, op[1..], 10);
    }
    fn parseImmediateInstruction(opcode: vm.Opcode, line: *[]const u8) !u32 {
        var instr = vm.ImmediateInstr{ .header = .{ .opcode = opcode } };

        instr.reg = try parseRegister(line);
        instr.immediate = try parseImmediate(line);
        return @bitCast(instr);
    }
    fn parseRInstruction(opcode: vm.Opcode, line: *[]const u8) !u32 {
        var instr = vm.RInstr{ .header = .{ .opcode = opcode } };

        // get 3 operands

        instr.r1 = try parseRegister(line);
        instr.r2 = try parseRegister(line);
        instr.dest = try parseRegister(line);

        return @bitCast(instr);
    }
    fn parse_instruction(self: *Assembler, raw_opcode: []const u8, line: *[]const u8) void {
        _ = self;

        if (parse_opcode(raw_opcode)) |opcode| {
            std.debug.print("opcode: {any}\n", .{opcode});

            switch (opcode) {
                .add => {
                    const instruction = parseRInstruction(opcode, line);
                    std.debug.print("Instruction: {any}\n", .{instruction});
                },
                .mov => {
                    const instruction = parseImmediateInstruction(opcode, line);
                    std.debug.print("Instruction: {any}\n", .{instruction});
                },
                else => {
                    std.debug.print("unknown opcode: {s}\n", .{raw_opcode});
                },
            }
        } else {
            std.debug.print("unknown opcode: {s}\n", .{raw_opcode});
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
        \\add s2, s3, s7
        \\mov s3, #9223
        \\add s1, s1, s10
    );
}
