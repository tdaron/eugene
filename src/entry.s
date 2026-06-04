.section .text
.global print, putc, syscall, context_switch

.equ UART_BASE, 0x10000000

context_switch:
        addi sp, sp, -64
        beq a0, zero, 1f # when starting the scheduler there is nothing to save
        sw ra,  0(sp)
        sw s0,  4(sp)
        sw s1,  8(sp)
        sw s2, 12(sp)
        sw s3, 16(sp)
        sw s4, 20(sp)
        sw s5, 24(sp)
        sw s6, 28(sp)
        sw s7, 32(sp)
        sw s8, 36(sp)
        sw s9, 40(sp)
        sw s10, 44(sp)
        sw s11, 48(sp)

        sw sp, 0(a0) # old->sp = sp
1:
        lw sp, 0(a1) 

        lw ra,  0(sp)
        lw s0,  4(sp)
        lw s1,  8(sp)
        lw s2, 12(sp)
        lw s3, 16(sp)
        lw s4, 20(sp)
        lw s5, 24(sp)
        lw s6, 28(sp)
        lw s7, 32(sp)
        lw s8, 36(sp)
        lw s9, 40(sp)
        lw s10, 44(sp)
        lw s11, 48(sp)
        
        addi sp, sp, 64
        ret

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
        

                
