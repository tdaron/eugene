const std = @import("std");
const vm = @import("vm.zig");
const testing = std.testing;

const AssemblerError = error{
    MissingRegister,
    MissingImmediate,
    InvalidRegister,
    InvalidOpcode,
    InvalidImmediate,
    UnexpectedEOL,
};

const Cursor = struct {
    data: []const u8,
    writer: *std.Io.Writer,
    pos: usize = 0,
    line: usize = 0,
    col: usize = 0,
    previousCol: usize = 0,
    previousConsumeLength: usize = 0,

    fn advance(self: *Cursor) void {
        self.previousCol = self.col;
        self.col += 1;
        if (self.data[self.pos] == '\n') {
            self.line += 1;
            self.col = 0;
        }
        self.pos += 1;
    }

    fn rewind(self: *Cursor) void {
        if (self.col == 0) {
            self.line -= 1;
        }
        self.col = self.previousCol;
    }
    fn gotoNextLine(self: *Cursor) void {
        while (self.pos < self.data.len) {
            if (self.data[self.pos] == '\n') {
                self.advance();
                break;
            }
            self.advance();
        }
    }
    fn consumeUntil(self: *Cursor, token: u8) ![]const u8 {
        const start = self.pos;
        if (self.pos >= self.data.len) {
            self.previousConsumeLength = 0;
            return AssemblerError.UnexpectedEOL;
        }

        var reachedToken = false;
        while (self.pos < self.data.len) {
            const c = self.data[self.pos];
            if (c == token) {
                self.advance();
                reachedToken = true;
                break;
            }
            if (c == '\n') {
                break;
            }
            self.advance();
        }

        const end = if (reachedToken) self.pos - 1 else self.pos;
        // -1 to not include the token in the result
        const res = self.data[start..end];
        self.previousConsumeLength = res.len;
        return res;
    }
    fn consumeTrimmedUntil(self: *Cursor, token: u8) ![]const u8 {
        var rest = try self.consumeUntil(token);
        rest = std.mem.trim(u8, rest, " \t\r\n");
        if (rest.len == 0 and token != '\n') {
            return AssemblerError.UnexpectedEOL;
        }
        self.previousConsumeLength = rest.len;

        return rest;
    }

    fn printPosition(self: *Cursor) !void {
        var lineStart: usize = 0;
        for (0..self.line) |_| {
            const index = (std.mem.findScalarPos(u8, self.data, lineStart, '\n') orelse 0);
            lineStart = index + 1;
        }

        const EOL = std.mem.findScalarPos(u8, self.data, lineStart, '\n') orelse self.data.len;

        try self.writer.print("{s}\n", .{self.data[lineStart..EOL]});
        if (self.previousConsumeLength > self.col) {
            for (0..@max(self.col - self.previousConsumeLength - 1, 0)) |_| {
                try self.writer.print(" ", .{});
            }
        }
        for (0..@max(self.previousConsumeLength, 3)) |_| {
            try self.writer.print("^", .{});
        }
        try self.writer.print("\n", .{});
    }
};

fn parse_opcode(raw_opcode: []const u8) !vm.Opcode {
    inline for (@typeInfo(vm.Opcode).@"enum".fields) |field| {
        if (std.mem.eql(u8, field.name, raw_opcode)) {
            return @enumFromInt(field.value);
        }
    }
    return AssemblerError.InvalidOpcode;
}

pub const Assembler = struct {
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

        instr.dest = try parseRegister(cursor);
        instr.r1 = try parseRegister(cursor);
        instr.r2 = try parseRegister(cursor);

        return @bitCast(instr);
    }
    fn parse_instruction(self: *Assembler, raw_opcode: []const u8, cursor: *Cursor) !?u32 {
        _ = self;

        const opcode = try parse_opcode(raw_opcode);
        switch (opcode) {
            .add => {
                return parseRInstruction(opcode, cursor);
            },
            .mov => {
                return parseImmediateInstruction(opcode, cursor);
            },
            .halt => {
                return @bitCast(vm.RInstr{ .header = .{ .opcode = .halt } });
            },
            else => {
                try cursor.writer.print("unsupported opcode: {s}\n", .{raw_opcode});
                return AssemblerError.InvalidOpcode;
            },
        }
    }
    fn parse_line(self: *Assembler, cursor: *Cursor) !?u32 {
        if (cursor.pos >= cursor.data.len) return null;
        while (cursor.pos < cursor.data.len and cursor.data[cursor.pos] == ' ') {
            cursor.pos += 1;
        }
        const ftoken = try cursor.consumeUntil(' ');
        return self.parse_instruction(ftoken, cursor);
    }
    pub fn assemble(self: *Assembler, output: *std.Io.Writer, assembly: []const u8) !vm.VMMemory {
        var memory: vm.VMMemory = undefined;
        var pos: u16 = 0;
        var cursor = Cursor{ .data = assembly, .writer = output };

        while (self.parse_line(&cursor) catch |err| {
            try cursor.writer.print("{any}\n", .{err});
            try cursor.printPosition();
            return err;
        }) |instruction| {
            memory[pos] = instruction;
            pos += 1;
            cursor.gotoNextLine();
        }
        return memory;
    }
};

pub fn assembleFromTest(code: []const u8) !vm.VMMemory {
    var assembler = Assembler{};
    var err_buf: [1024]u8 = undefined;
    var stderr: std.Io.Writer = .fixed(&err_buf);
    return assembler.assemble(&stderr, code);
}

test "assembler add" {
    const memory = try assembleFromTest(
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
    const memory = try assembleFromTest(
        \\mov s1, #67
    );
    const a = 5;
    _ = a;
    const first: u32 = @bitCast(vm.ImmediateInstr{
        .header = .{ .opcode = .mov },
        .immediate = 67,
        .reg = 1,
    });
    try testing.expect(memory[0] == first);
}

test "error 1" {
    var assembler = Assembler{};
    var err_buf: [1024]u8 = undefined;
    var stderr: std.Io.Writer = .fixed(&err_buf);
    _ = assembler.assemble(&stderr,
        \\add s1, s2, s
        \\add s1, s8, #7
    ) catch null;

    testing.expect(std.mem.containsAtLeast(u8, err_buf[0..stderr.end], 1, "error.InvalidCharacter")) catch |err| {
        std.debug.print("{s}\n", .{err_buf[0..stderr.end]});
        return err;
    };
}
