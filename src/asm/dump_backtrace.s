.globl dump_backtrace
.type dump_backtrace, @function
dump_backtrace:
        /* Set up stack */
        push %rbp
        mov %rsp, %rbp

        /* rbx will keep track of the current rbp position */
        mov %rbp, %rbx
loop:
        /* Move the ret address of the current function frame into rdi */
        mov 8(%rbx), %rdi
        call _dump_backtrace

        /* Check if the next depth is valid */
        test (%rbx), %rbx
        jz done

        /* Dereference the current ret address and go to the next frame */
        mov (%rbx), %rbx
        jmp loop

done:       
        /* Epilog */
        mov %rbp, %rsp
        pop %rbp
        ret

.section .rodata
backtrace_format_str:
.asciz "%3ld: [%lx] %s () %s\n"
