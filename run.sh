#!/bin/bash
set -xue 
CC=clang
CFLAGS="-std=c11 -Wall -Wextra --target=riscv32-unknown-elf -mabi=ilp32 -march=rv32ima_zicsr -fno-stack-protector -ffreestanding -nostdlib"
SOURCES="$(find src -name '*.s' -o -name '*.c' -o -name '*.S')"

build() {
  $CC $CFLAGS -Wl,-Tlinker.ld $SOURCES -Iinclude -o dst/eugene "$@"
  llvm-objcopy -O binary dst/eugene dst/eugene.bin

  clang external/mini-rv32ima/*.c -o dst/vm
  
}


if [ $1 == "run" ]; then
  build -DRV32IMA
  ./dst/vm -f ./dst/eugene.bin
fi

if [ $1 == "qemu" ]; then
  build -DQEMU
  qemu-system-riscv32 -machine virt -bios none -nographic -kernel dst/eugene
fi


