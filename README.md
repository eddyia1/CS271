# CS271 - Final Project
**Note**: Our default implementation of the dump_backtrace program is implemented in debug.c and assembly. If we were supposed to implement dump_backtrace entirely in assembly, we included another program called dump_backtrace_asm.txt in the /src/asm folder. However, both programs yield the same output.

## Authors
- Alexander Blajev 
- Dylan Hess
- Ian Eddy

## Overview

This project supports two features:

  1. **Register Dump:** The register dump program prints to the terminal the decimal and hex value of the 16 most common registers in amd64 assembly. It prints register name, register value in decimal, and register value in hexadecimal. It is useful for debugging and understanding the state of the computer at a specific point during execution. The program operates on the following registers:
  ```
  rax, rbx, rcx, rdx, rsi, rdi, rbp, rsp, r8–r15
  ```
     
  2. **Stack Backtrace:** The stack backtrace program traverses the current call stack and prints it to the terminal. It utilizes the dladdr function, and prints depth, symbol address, symbol name, and file name. For this project, we included two versions of the stack backtrace. One program relies on a C file, while the other implements everything in assembly.

## Register Dump 
The assembly implementation of the register dump is as follows:

```asm
dump_registers:
        push %rax
        push %rbx
        push %rcx
        push %rdx
        push %rsi
        push %rdi
        push %rbp

        /* Calculate offset for initial value of rsp */
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

        /* Pass the stack pointer into the first arg */
        movq %rsp, %rdi

        call _debug_dump_registers

        /* Restore the stack pointer */
        leaq (16*8)(%rsp), %rsp

        ret
```
  The assembly function operates by pushing every register to the stack, and then passing a pointer to the stack into a C print function. The initial value of rsp can be calculated through the simple formula of (8 * (Number of Pushes + 1)). The 1 offset accounts for the calling of the dump_registers function, which increments rsp's position by 8 bytes. Therefore, since we pushed 7 times before pushing rsp, the initial value of rsp is equal to an offset of (8 * (7+1)). We can store this in any of the previous registers since we have already pushed their value to the stack, but the program arbitrarily chooses rax for this.  
<br>

The C implementation of the register dump is as follows:
```c
void _debug_dump_registers(long const *regvalues)
{
        for(int i = 0; i < 16; i++)
        {
                printf("%s\t%ld (0x%lx)\n", regnames[i], regvalues[15-i], regvalues[15-i]);
        }
}
```
The function is self-explanatory and prints the relevant information for each register. The parameter of regvalues is the rsp stack pointer from the assembly program.

## Stack Backtrace With C File
This version of the stack backtrace relies on calling dladdr from a C function. The assembly implementation is as follows:
```asm
dump_backtrace:
        /*Set up stack */
        push %rbp
        mov %rsp, %rbp

        /* rbx will keep track of the current rbp position */
        mov %rbp, %rbx
loop:
        /* Move the ret address into rdi */
        mov 8(%rbx), %rdi
        call _dump_backtrace

        /* Test if the next address is valid */
        test (%rbx), %rbx
        jz done

        /* Move on to the next function frame */
        mov (%rbx), %rbx
        jmp loop

```
The assembly implementation is rather simple. It relies on obtaining the ret address of the current function frame (8 offset from rbp's position), passing it into _dump_backtrace, and then dereferencing the current address to move onto the next frame.
<br>
The _dump_backtrace function is as follows;
```c
void _dump_backtrace(void* arg)
{
        Dl_info info;

        dladdr(arg, &info);
        printf("%3ld: [%lx] %s () %s\n", depth, info.dli_saddr, info.dli_sname, info.dli_fname);
        depth++;
}

This function is also straightforward. Members of Dl_info are accessed with the dot operator and printed to the terminal. This contrasts with the approach of stack backtracing without a C file.

```


## Stack Backtrace Without C File
This version of the stack backtrace relies on calling dladdr from assembly directly, rather than inside a C function. The assembly implementation is as follows:

```asm
.section .bss
dl_info: .space 32

dump_backtrace:
        /* Set up stack */
        push %rbp
        mov %rsp, %rbp

        /* r13 will keep track of the current depth */
        mov $0, %r13 

        /* rbx will keep track of the rbp value */
        mov %rbp, %r12
loop:
        /* Move the ret address into rdi and print it */
        movq 8(%r12), %rdi
        leaq dl_info(%rip), %rsi

        call dladdr

        /* Access dladdr struct pointer members and store them into the appropriate args for printf */
        leaq backtrace_format_str(%rip), %rdi
        movq %r13, %rsi /* Depth */
        movq 24+dl_info(%rip), %rdx /* Symbol address */
        movq 16+dl_info(%rip), %rcx /* Symbol name */
        movq dl_info(%rip), %r8 /* File name */

        xor %rax, %rax

        call printf

        /* Determine if the next depth is valid */
        test (%r12), %r12
        jz done

        /* Increment depth */
        incq %r13

        /* Move on to the next depth*/
        mov (%r12), %r12

        jmp loop
```
The man page for Dl_info specifies a format of:

```C
typedef struct {
               const char *dli_fname;  /* Pathname of shared object that
                                          contains address */
               void       *dli_fbase;  /* Base address at which shared
                                          object is loaded */
               const char *dli_sname;  /* Name of symbol whose definition
                                          overlaps addr */
               void       *dli_saddr;  /* Exact address of symbol named
                                          in dli_sname */
           } Dl_info;
```
Rather than accessing these members directly in C, the program instead accesses the members through a byte offset of the return value of dladdr. For example, dli_saddr is 3 memory addresses away from dli_fname, and therefore can be accessed by adding 24 to the start of the dli_info space.

## Usage

Use "Make all" to run the test file for both programs.
