#ifdef RV32IMA

# https://github.com/cnlohr/mini-rv32ima

.global putc, setup_traps
.equ UART_BASE, 0x10000000

putc:
        li t0, UART_BASE
        sb a0, 0(t0)
        ret

setup_traps:
        addi sp, sp, -16
        sw ra, 12(sp)

        la a0, trap_routine
        csrw mtvec, a0
        
        la a0, traps
        call printf

        lw ra, 12(sp)
        addi sp, sp, 16
        ret

traps: .string "[RV32IMA] Traps set-up\n"
        
        
#endif
