#include <string.h>
#define NOB_IMPLEMENTATION
#include "external/nob.h"
#include <stdio.h>

// To change according to your machine / distro !
#define CC "riscv64-linux-musl-gcc"
#define AS "riscv64-linux-musl-as"
#define LD "riscv64-linux-musl-ld"
#define OBJCOPY "riscv64-linux-musl-objcopy"

void compile_c_riscv(char* file, char* output) {
	if (!nob_needs_rebuild1(output, file)) return;
	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, CC);
	nob_cmd_append(&cmd,
		"-march=rv32ima_zicsr",
		"-mabi=ilp32",
		"-ffreestanding",
		"-nostdlib",
		"-nostartfiles",
		"-fno-stack-protector",
		"-fno-pic", "-fno-pie",
		"-c"
	);
	nob_cc_inputs(&cmd, file);
	nob_cc_output(&cmd, output);
	nob_cmd_run(&cmd);
}

void assemble(char* file, char* output) {
	if (!nob_needs_rebuild1(output, file)) return;
	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, AS);
	nob_cmd_append(&cmd,
		"-march=rv32ima_zicsr",
		"-mabi=ilp32",
	);
	nob_cc_inputs(&cmd, file);
	nob_cc_output(&cmd, output);
	nob_cmd_run(&cmd);
}

void linker(char* linker_script, char** items, int count, char* output) {
	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, LD);
	nob_cmd_append(&cmd,
		"-m", "elf32lriscv",
		"-T", linker_script,
	);
	for (int i = 0; i < count; i++) {
		nob_cmd_append(&cmd, items[i]);
	}
	nob_cmd_append(&cmd, "-o", output);
	nob_cmd_run(&cmd);

}

void compile_c(char* file, char* output) {
	if (!nob_needs_rebuild1(output, file)) return;
	Nob_Cmd cmd = {0};
	nob_cc(&cmd);
	nob_cc_inputs(&cmd, file);
	nob_cc_output(&cmd, output);
	nob_cmd_run(&cmd);
	
}

void objcpy(char* file, char* output) {
	if (!nob_needs_rebuild1(output, file)) return;
	Nob_Cmd cmd = {0};
	nob_cmd_append(&cmd, OBJCOPY);
	nob_cmd_append(&cmd, "-O", "binary");
	nob_cmd_append(&cmd, file);
	nob_cmd_append(&cmd, output);
	nob_cmd_run(&cmd);
}

int main(int argc, char** argv) {
	NOB_GO_REBUILD_URSELF(argc, argv);
	nob_mkdir_if_not_exists("dst");
	printf("hello, world !\n");
	compile_c("./external/mini-rv32ima/mini-rv32ima.c", "dst/vm");
	compile_c_riscv("src/main.c", "src/main.o");
	assemble("src/entry.s", "src/entry.o");
	assemble("src/boot.s", "src/boot.o");

	char* objects[] = {
		"src/main.o",
		"src/entry.o",
		"src/boot.o"	
	};
	linker("linker.ld", objects, 3, "dst/main");
	objcpy("dst/main", "dst/rom.bin");

	if (argc > 1 && strcmp(argv[1], "run") == 0) {
		Nob_Cmd cmd = {0};
		nob_cmd_append(&cmd, "./dst/vm", "-f", "./dst/rom.bin");
		nob_cmd_run(&cmd);
	}
}
