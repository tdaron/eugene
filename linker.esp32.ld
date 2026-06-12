ENTRY(_start)

MEMORY
{
    IRAM (rwx) : ORIGIN = 0x40380000, LENGTH = 384K
    DRAM (rw)  : ORIGIN = 0x3FC80000, LENGTH = 384K
}

STACK_SIZE = 16K;
STACK_TOP = ORIGIN(DRAM) + LENGTH(DRAM);
STACK_BOTTOM = STACK_TOP - STACK_SIZE;

SECTIONS
{
    .text : {
        . = ALIGN(4);
        KEEP(*(.text.boot))
        *(.text*)
        *(.rodata*)
    } > IRAM

    .init_array : {
        . = ALIGN(4);
        __init_array_start = .;
        KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
        KEEP(*(.init_array))
        __init_array_end = .;
    } > IRAM
    

    .data : {
        *(.data*)
    } > IRAM


    .bss : {
        __bss_start = .;
        *(.bss*)
        *(COMMON)
        __bss_end = .;

    } > DRAM

    . = ALIGN(16);
    __kernel_end = .;

    __heap_start = .;
    __heap_end = STACK_BOTTOM;

    __stack_bottom = STACK_BOTTOM;
    __stack_top = STACK_TOP;
}
