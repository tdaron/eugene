ENTRY(_start)

MEMORY
{
    /* SRAM1 block0, instruction alias */
    IRAM (rx)  : ORIGIN = 0x40380000, LENGTH = 128K

    /* SRAM1 blocks1-2, data aliases */
    DRAM (rw)  : ORIGIN = 0x3FCA0000, LENGTH = 256K
}

STACK_SIZE = 16K;

STACK_TOP = ORIGIN(DRAM) + LENGTH(DRAM);
STACK_BOTTOM = STACK_TOP - STACK_SIZE;

SECTIONS
{
    .text : {
        . = ALIGN(4);

        KEEP(*(.text.boot))
        KEEP(*(.trap_vector))
        KEEP(*(.trap_vector.*))

        *(.text)
        *(.text.*)

        *(.rodata)
        *(.rodata.*)

        *(.literal)
        *(.literal.*)

        . = ALIGN(4);
    } > IRAM

    .preinit_array : {
        . = ALIGN(4);
        __preinit_array_start = .;
        KEEP(*(.preinit_array))
        KEEP(*(.preinit_array.*))
        __preinit_array_end = .;
        . = ALIGN(4);
    } > IRAM

    .init_array : {
        . = ALIGN(4);
        __init_array_start = .;
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(.init_array))
        __init_array_end = .;
        . = ALIGN(4);
    } > IRAM

    .fini_array : {
        . = ALIGN(4);
        __fini_array_start = .;
        KEEP(*(.fini_array))
        KEEP(*(.fini_array.*))
        __fini_array_end = .;
        . = ALIGN(4);
    } > IRAM

    .data : {
        . = ALIGN(4);
        __data_start = .;

        /*
         * RISC-V gp. Your _start must initialize:
         *   la gp, __global_pointer$
         */
        PROVIDE(__global_pointer$ = . + 0x800);

        *(.srodata)
        *(.srodata.*)

        *(.sdata)
        *(.sdata.*)

        *(.data)
        *(.data.*)

        *(.got)
        *(.got.*)

        . = ALIGN(4);
        __data_end = .;
    } > DRAM

    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;

        *(.sbss)
        *(.sbss.*)

        *(.bss)
        *(.bss.*)

        *(COMMON)

        . = ALIGN(4);
        __bss_end = .;
    } > DRAM

    . = ALIGN(16);
    __kernel_end = .;

    __heap_start = .;
    __heap_end = STACK_BOTTOM;

    __stack_bottom = STACK_BOTTOM;
    __stack_top = STACK_TOP;

    ASSERT(__heap_start <= __heap_end, "kernel/heap overlaps stack")
    ASSERT(SIZEOF(.text) <= LENGTH(IRAM), "IRAM overflow")
    ASSERT((__bss_end - ORIGIN(DRAM)) <= LENGTH(DRAM), "DRAM overflow")
}
