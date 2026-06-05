.section .text
.global print, putc, syscall, context_switch

.equ UART_BASE, 0x10000000


print:
        addi sp, sp, -16
        sw ra, 12(sp)
        sw s0, 8(sp)
        mv s0, a0 # s0 = char* string
1:
        lbu a0, 0(s0)
        beq a0, zero, 2f
        call putc
        addi s0, s0, 1
        j 1b
2:
        lw ra, 12(sp)
        lw s0, 8(sp)
        addi sp, sp, 16
        ret

putc:
        li t0, UART_BASE
        sb a0, 0(t0)
        ret
        

                
