const std = @import("std");
const testing = std.testing;

//
//
// Memory layout
//
const MEMORY_SIZE = 1 << 16; // u16 addresses (65 536 words)

const Region = struct {
    start: u16, // word address
    size: u16, // number of u32 words

    pub fn end(self: Region) u16 {
        return self.start + self.size;
    }
};

pub const ROM = Region{
    .start = 0,
    .size = 1 << 15, // 32 768 words (50%)
};

pub const RAM = Region{
    .start = ROM.end(),
    .size = 1 << 14, // 16 384 words (25%)
};

// SCREEN
pub const VRAM = Region{
    .start = RAM.end(),
    .size = (128 * 128) / 4, // 4096 words (6.25%)
};

pub const DEVICES = Region{
    .start = VRAM.end(),
    .size = 8, // 8 words (8 32-bit devices) (0.01%)
};

pub const Opcode = enum(u6) {
    add,
    load,
    mov,
    store,
};
pub const VM = struct {
    memory: [MEMORY_SIZE]u32,
    pc: u16,
    registers: [1 << 5]u32,

    fn process_instruction(self: *VM, raw_instruction: u32) void {
        // The R0 register MUST ALWAYS be ZERO valued.
        // this allows mov r1, r2 to be replaced by ADD R1, R2, r0 for instance
        // simplifying instructions.
        self.registers[0] = 0;

        // header = [opcode: u6 | mode: u3]
        const instr: Instruction = @bitCast(raw_instruction);
        const header = instr.header();
        switch (header.opcode) {
            Opcode.mov => {
                self.registers[instr.imm.reg] = instr.imm.immediate;
            },
            Opcode.store => {
                self.memory[instr.addr.address] = self.registers[instr.addr.reg];
            },
            Opcode.load => {
                self.registers[instr.addr.reg] = self.memory[instr.addr.address];
            },
            Opcode.add => {
                self.registers[instr.r.dest] = self.registers[instr.r.r1] + self.registers[instr.r.r2];
            },
        }
        self.pc += 1;
    }
};

pub const Header = packed struct(u9) {
    opcode: Opcode, // 6 bits
    mode: u3 = 0,
};

pub const RInstr = packed struct(u32) {
    header: Header,
    r1: u5 = 0,
    r2: u5 = 0,
    dest: u5 = 0,
    v_length: u3 = 0,
    _: u5 = 0,
};

pub const AddrInstr = packed struct(u32) {
    header: Header,
    reg: u5 = 0,
    address: u16 = 0,
    _: u2 = 0,
};

pub const ImmediateInstr = packed struct(u32) {
    header: Header,
    reg: u5 = 0,
    immediate: u18 = 0,
};

pub const Instruction = extern union {
    raw: u32,
    r: RInstr,
    addr: AddrInstr,
    imm: ImmediateInstr,

    pub fn header(self: Instruction) Header {
        return self.r.header;
    }
};

test "immediate mov" {
    var vm = VM{ .memory = undefined, .pc = 0, .registers = undefined };
    const inst = ImmediateInstr{ .header = .{ .opcode = Opcode.mov }, .reg = 3, .immediate = 67 };
    vm.process_instruction(@bitCast(inst));
    try testing.expect(vm.registers[3] == 67);
}

test "register mov via R0" {
    var vm = VM{ .memory = undefined, .pc = 0, .registers = undefined };
    vm.registers[3] = 7; // Source register

    // R1 = 3 (Source), R2 = 0 (R0 constant), dest = 5 (Destination)
    // Computes: R5 = R3 + R0 (7 + 0)
    const inst = RInstr{ .header = .{ .opcode = Opcode.add }, .r1 = 3, .r2 = 0, .dest = 5 };

    vm.process_instruction(@bitCast(inst));
    try testing.expect(vm.registers[5] == 7);
}

test "load instruction" {
    var vm = VM{ .memory = undefined, .pc = 0, .registers = undefined };
    vm.memory[0xF00D] = 67;
    const inst = AddrInstr{ .header = .{ .opcode = Opcode.load }, .address = 0xF00D, .reg = 8 };
    vm.process_instruction(@bitCast(inst));
    try testing.expect(vm.registers[8] == vm.memory[0xF00D]);
}

test "store instruction" {
    var vm = VM{ .memory = undefined, .pc = 0, .registers = undefined };
    vm.registers[8] = 67;
    const inst = AddrInstr{ .header = .{ .opcode = Opcode.store }, .address = 0xF00D, .reg = 8 };
    vm.process_instruction(@bitCast(inst));
    try testing.expect(vm.registers[8] == vm.memory[0xF00D]);
}

test "add instruction" {
    var vm = VM{ .memory = undefined, .pc = 0, .registers = undefined };
    vm.registers[6] = 60;
    vm.registers[7] = 7;
    const inst = RInstr{ .header = .{ .opcode = Opcode.add }, .r1 = 6, .r2 = 7, .dest = 5 };
    vm.process_instruction(@bitCast(inst));
    try testing.expect(vm.registers[5] == 67);
}
