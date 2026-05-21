const std = @import("std");
const vm = @import("vm.zig");
const testing = std.testing;

const AssemblerError = error{ MissingRegister, MissingImmediate, InvalidRegister, InvalidImmediate, UnexpectedEOL };

const Cursor = struct {
    data: []const u8,

    pos: usize = 0,
    line: usize = 0,
    col: usize = 0,

    fn advance(self: *Cursor) void {
        self.col += 1;
        if (self.data[self.pos] == '\n') {
            self.line += 1;
            self.col = 0;
        }
        self.pos += 1;
    }
    fn consumeUntil(self: *Cursor, token: u8) ![]const u8 {
        const start = self.pos;
        if (self.pos >= self.data.len) {
            return AssemblerError.UnexpectedEOL;
        }

        while (self.pos < self.data.len) {
            const c = self.data[self.pos];
            if (c == token) {
                self.advance();
                break;
            }
            if (c == '\n') {
                self.advance();
                break;
            }
            self.advance();
        }

        // if we reach end of file, we need to do +1 to compensate
        // for the absence of token
        if (self.pos == self.data.len) {
            self.pos += 1;
        }

        // -1 to not include the token in the result
        return self.data[start .. self.pos - 1];
    }
    fn consumeTrimmedUntil(self: *Cursor, token: u8) ![]const u8 {
        const rest = try self.consumeUntil(token);
        return std.mem.trim(u8, rest, " \t\r\n");
    }
};

fn parse_opcode(raw_opcode: []const u8) ?vm.Opcode {
    inline for (@typeInfo(vm.Opcode).@"enum".fields) |field| {
        if (std.mem.eql(u8, field.name, raw_opcode)) {
            return @enumFromInt(field.value);
        }
    }
    return null;
}

const Assembler = struct {
    inline fn parseRegister(cursor: *Cursor) !u5 {
        const op = cursor.consumeTrimmedUntil(',') catch return AssemblerError.MissingRegister;
        if (op[0] != 's') return AssemblerError.InvalidRegister;
        return std.fmt.parseInt(u5, op[1..], 10);
    }
    inline fn parseImmediate(cursor: *Cursor) !u18 {
        const op = cursor.consumeTrimmedUntil(',') catch return AssemblerError.MissingImmediate;
        if (op[0] != '#') return AssemblerError.InvalidImmediate;
        return std.fmt.parseInt(u18, op[1..], 10);
    }
    fn parseImmediateInstruction(opcode: vm.Opcode, cursor: *Cursor) !?u32 {
        var instr = vm.ImmediateInstr{ .header = .{ .opcode = opcode } };

        instr.reg = try parseRegister(cursor);
        instr.immediate = try parseImmediate(cursor);
        return @bitCast(instr);
    }
    fn parseRInstruction(opcode: vm.Opcode, cursor: *Cursor) !?u32 {
        var instr = vm.RInstr{ .header = .{ .opcode = opcode } };

        // get 3 operands

        instr.r1 = try parseRegister(cursor);
        instr.r2 = try parseRegister(cursor);
        instr.dest = try parseRegister(cursor);

        return @bitCast(instr);
    }
    fn parse_instruction(self: *Assembler, raw_opcode: []const u8, cursor: *Cursor) !?u32 {
        _ = self;

        if (parse_opcode(raw_opcode)) |opcode| {
            switch (opcode) {
                .add => {
                    return parseRInstruction(opcode, cursor);
                },
                .mov => {
                    return parseImmediateInstruction(opcode, cursor);
                },
                else => {
                    std.debug.print("unknown opcode: {s}\n", .{raw_opcode});
                },
            }
        } else {
            std.debug.print("unknown opcode: {s}\n", .{raw_opcode});
        }
        return null;
    }
    fn parse_line(self: *Assembler, cursor: *Cursor) !?u32 {
        const ftoken = cursor.consumeUntil(' ') catch return null;
        return self.parse_instruction(ftoken, cursor);
    }
    fn assemble(self: *Assembler, assembly: []const u8) !vm.VMMemory {
        var memory: vm.VMMemory = undefined;
        var pos: u16 = 0;
        var cursor = Cursor{ .data = assembly };

        while (self.parse_line(&cursor) catch null) |instruction| {
            memory[pos] = instruction;
            pos += 1;
        }
        return memory;
    }
};

test "assembler add" {
    var assembler = Assembler{};
    const memory = try assembler.assemble(
        \\add s2, s3, s7
    );
    const first: u32 = @bitCast(vm.RInstr{
        .header = .{ .opcode = .add },
        .r1 = 2,
        .r2 = 3,
        .dest = 7,
    });
    try testing.expect(memory[0] == first);
}

test "assembler mov" {
    var assembler = Assembler{};
    const memory = try assembler.assemble(
        \\mov s1, #67
    );
    const first: u32 = @bitCast(vm.ImmediateInstr{
        .header = .{ .opcode = .mov },
        .immediate = 67,
        .reg = 1,
    });
    try testing.expect(memory[0] == first);
}
