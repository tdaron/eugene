const std = @import("std");
const rl = @import("raylib");
const vm_mod = @import("vm.zig");

var VM = vm_mod.VM{ .memory = undefined, .registers = undefined, .pc = 0 };

const VRAM_begin = vm_mod.VRAM.start;
const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

var palette: [256]Color = undefined;

const scaling = 5;
const screenWidth = 128;
const screenHeight = 128;
pub fn recolor(data: []u8) void {
    for (0..screenHeight) |y| {
        for (0..screenWidth) |x| {
            const pixel_idx = y * screenWidth + x;
            const color = palette[VM.getPixel(x, y)];
            const i = pixel_idx * 4;
            data[i] = color.r;
            data[i + 1] = color.g;
            data[i + 2] = color.b;
            data[i + 3] = color.a;
        }
    }
}

pub fn main() !void {
    for (0..256) |i| {
        palette[i] = .{
            .r = @as(u8, @intCast(i)),
            .g = @as(u8, @intCast(i / 2)),
            .b = @as(u8, @intCast(255 - i)),
            .a = 255,
        };
    }

    @memset(VM.memory[0..], 0);

    for (0..screenHeight) |y| {
        for (0..screenWidth) |x| {
            VM.setPixel(x, y, @as(u8, @intCast(x + y)));
        }
    }
    VM.setPixel(50, 50, 255);
    var data: [screenHeight * screenHeight * 4]u8 = undefined;
    recolor(data[0..]);

    rl.initWindow(screenWidth * scaling, screenHeight * scaling, "raylib-zig [core] example - basic window");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    const img = rl.Image{
        .data = @ptrCast(&data),
        .width = screenWidth,
        .height = screenHeight,
        .mipmaps = 1,
        .format = rl.PixelFormat.uncompressed_r8g8b8a8,
    };

    const tex = try rl.loadTextureFromImage(img);
    rl.setTextureFilter(tex, rl.TextureFilter.point);

    //--------------------------------------------------------------------------------------

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.drawTexturePro(
            tex,
            .{ .height = screenHeight, .width = screenWidth, .x = 0, .y = 0 },
            .{ .height = screenHeight * scaling, .width = screenWidth * scaling, .x = 0, .y = 0 },
            .{ .x = 0, .y = 0 },
            0,
            .white,
        );

        rl.clearBackground(.white);
        recolor(data[0..]);
        rl.updateTexture(tex, @ptrCast(&data));
    }
}
