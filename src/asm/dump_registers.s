.extern _debug_dump_registers

.section .text
.globl dump_registers
.type dump_registers, @function
dump_registers:
        /* Push all register values to the stack */
        push %rax
        push %rbx
        push %rcx
        push %rdx
        push %rsi
        push %rdi
        push %rbp

        /* The original value of %rsp before pushing to the stack is equal to */
        /* an offset of 8 * (Number of pushes + 1). */
        leaq (8*8)(%rsp), %rax

        push %rax
        push %r8
        push %r9
        push %r10
        push %r11
        push %r12
        push %r13
        push %r14
        push %r15

        /* Pass the stack pointer into rdi to allow C to iterate */
        /* over it and print the value */
        movq %rsp, %rdi

        /* Call the externally-linked C function defined in debug.c */
        call _debug_dump_registers

        /* Restore the original stack position */
        leaq (16*8)(%rsp), %rsp

        ret
