.extern _debug_dump_registers
.globl dump_registers
.type dump_registers, @function
dump_registers:
	leaq -8(%rsp), %rsp

	//THIS MIGHT BE IN OPPOSITE ORDER
	push %rax
	push %rbx
	push %rcx
	push %rdx
	push %rsi
	push %rdi
	push %rbp
	push %rsp
	push %r8
	push %r9
	push %r10
	push %r11
	push %r12
	push %r13
	push %r14
	push %r15

	movq %rsp, %rdi

	call _debug_dump_registers

	leaq (16*8 + 8)(%rsp), %rsp

	ret
