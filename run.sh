#!/bin/bash
set -xue 
CC=clang
CFLAGS="-std=c11 -Os -Wall -Wextra --target=riscv32-unknown-elf
        -mabi=ilp32 -march=rv32ima_zicsr -fno-stack-protector -ffreestanding
        -Iinclude -Isrc -nostdinc
       -nostdlib"
SOURCES="$(find src -name '*.s' -o -name '*.c' -o -name '*.S') ./target/riscv32im-unknown-none-elf/debug/*.a"
mkdir -p out

build() {
  cargo build
  $CC $CFLAGS -Wl,-Tlinker.ld $SOURCES -o out/eugene "$@"
  llvm-objcopy -O binary out/eugene out/eugene.bin
  clang external/mini-rv32ima/*.c -o out/vm 
}

build_esp32() {
  cargo build
  $CC $CFLAGS -Wl,-Tlinker.esp32.ld $SOURCES -o out/eugene "$@"
}

if [ $1 == "run" ]; then
  build -DRV32IMA
  ./out/vm -f ./out/eugene.bin
fi

if [ $1 == "qemu" ]; then
  build -DQEMU
  qemu-system-riscv32 -machine virt -bios none -nographic -kernel out/eugene
fi

if [ $1 == "esp32" ]; then
  build_esp32 -DESP32
  esptool.py --chip esp32c3 elf2image out/eugene
  esptool.py --chip esp32c3 image_info out/eugene.bin
  esptool.py --chip esp32c3 \
    write_flash \
    --flash_mode dio \
    --flash_freq 40m \
    --flash_size 4MB \
    0x0 out/eugene.bin
    picocom /dev/ttyACM0
fi


