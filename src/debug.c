#define _GNU_SOURCE
#include <dlfcn.h>
#include <stdio.h>

char const *regnames[] = {
    "rax",
    "rbx",
    "rcx",
    "rdx",
    "rsi",
    "rdi",
    "rbp",
    "rsp",
    "r8",
    "r9",
    "r10",
    "r11",
    "r12",
    "r13",
    "r14",
    "r15",
};

int depth = 0;

/* Internal helper function */
void _debug_dump_registers(long const *regvalues)
{
	for(int i = 0; i < 16; i++)
	{
		printf("%s\t%ld (0x%lx)\n", regnames[i], regvalues[15-i], regvalues[15-i]);
	}
}

void _dump_backtrace(void* arg)
{
	Dl_info info;

	dladdr(arg, &info);
	printf("%3ld: [%lx] %s () %s\n", depth, info.dli_saddr, info.dli_sname, info.dli_fname);
	depth++;
}
