ENTRY(_start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 64M
}

RAM_END = ORIGIN(RAM) + LENGTH(RAM);

/* Keep some space away from the very top of mini-rv32ima RAM. */
RESERVED_TOP = 0x10000;

STACK_SIZE = 16K;
STACK_TOP = RAM_END - RESERVED_TOP;
STACK_BOTTOM = STACK_TOP - STACK_SIZE;

SECTIONS
{
    . = 0x80000000;

    .text : {
        KEEP(*(.text.boot))
        *(.text*)
    }

    .rodata : {
        *(.rodata*)
    }

    .data : {
        *(.data*)
    }

    . = ALIGN(4);

    .init_array : {
        __init_array_start = .;
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(.init_array))
        __init_array_end = .;
    }

    . = ALIGN(4);

    .bss : {
        *(.bss*)
        *(COMMON)
    }

    . = ALIGN(16);
    __kernel_end = .;

    __heap_start = .;
    __heap_end = STACK_BOTTOM;

    __stack_bottom = STACK_BOTTOM;
    __stack_top = STACK_TOP;
}
