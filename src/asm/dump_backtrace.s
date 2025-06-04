.globl dump_backtrace
.type dump_backtrace, @function
dump_backtrace:
	push %rbp
	mov %rsp, %rbp

	mov %rbp, %rbx
loop:
	test %rbx, %rbx
	jz done

	mov 8(%rbx), %rdi
	test %rdi, %rdi
	jz done

	call _dump_backtrace
	mov (%rbx), %rbx

	jmp loop
done:
	mov %rbp, %rsp
	pop %rbp
	ret


.section .rodata
backtrace_format_str:
.asciz "%3ld: [%lx] %s () %s\n"
