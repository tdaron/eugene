#ifdef RV32IMA

# https://github.com/cnlohr/mini-rv32ima

.global putc
.equ UART_BASE, 0x10000000

putc:
        li t0, UART_BASE
        sb a0, 0(t0)
        ret
        
#endif
