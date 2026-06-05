#!/bin/bash
set -xue 
if [[ $1 == "build" || $1 == "run" ]]; then

CC=clang
CFLAGS="-std=c11 -Wall -Wextra --target=riscv32-unknown-elf -mabi=ilp32 -march=rv32ima_zicsr -fno-stack-protector -ffreestanding -nostdlib"

$CC $CFLAGS -Wl,-Tlinker.ld src/*.s src/*.c -o dst/eugene
llvm-objcopy -O binary dst/eugene dst/eugene.bin

clang external/mini-rv32ima/*.c -o dst/vm

if [ $1 == "run" ]; then
  ./dst/vm -f ./dst/eugene.bin
fi


fi
