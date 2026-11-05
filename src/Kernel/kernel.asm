global _start
extern kernel_main

_start:
call kernel_main


halt:
    hlt
    jmp halt