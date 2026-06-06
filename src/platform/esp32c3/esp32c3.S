#ifdef ESP32
.global setup_traps


; putc:
;         ret

# takes trap routine address in a0
setup_traps:
        ret
        # find out how to do this
        addi sp, sp, -16
        sw ra, 12(sp)

        csrw mtvec, a0
        la a0, traps
        call printf

        lw ra, 12(sp)
        addi sp, sp, 16
        ret

traps: .string "[QEMU] Traps set-up\n"

#endif
