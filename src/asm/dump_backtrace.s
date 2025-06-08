.globl dump_backtrace
.type dump_backtrace, @function
dump_backtrace:
        push %rbp
        mov %rsp, %rbp

        mov %rbp, %rbx
loop:
        mov 8(%rbx), %rdi
        call _dump_backtrace

        test (%rbx), %rbx
        jz done

        mov (%rbx), %rbx
        jmp loop

done:
        mov %rbp, %rsp
        pop %rbp
        ret

.section .rodata
backtrace_format_str:
.asciz "%3ld: [%lx] %s () %s\n"
