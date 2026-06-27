# EugeneOS

This project is still in **early** development.

The only dependency is the LLVM toolchain, used for cross compiling.
(`clang` + `lld`).

Eugene embeds [mini-rv32ima](https://github.com/cnlohr/mini-rv32ima) as a ligthweight RISC-V virtual machine for
development (and WASM support in the future), but it can also run inside
of qemu. It also supports running on hardware, on `esp32c3` chip (`esptool`
is required in order to be able to flash it).

## Running it

Even if it does not do anything useful yet, you can run it using

    ./run.sh run # run inside mini-rv32ima, no dependencies
    ./run.sh qemu # runs inside of qemu
    ./run.sh esp32 # flash and run on esp32c3
