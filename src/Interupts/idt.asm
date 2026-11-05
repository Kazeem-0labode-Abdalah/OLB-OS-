global flush_idt
flush_idt:
    MOV eax,[esp + 4]
    LIDT [eax]
   ; STI
    RET

%macro ISR_NOERRCODE 1
global isr%1
isr%1:
    CLI
    PUSH LONG 0
    PUSH LONG %1
    JMP isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
global isr%1
isr%1:
CLI
PUSH LONG %1
JMP isr_common_stub
%endmacro

%macro IRQ 2
global irq%1
irq%1:
    CLI
    PUSH LONG 0
    PUSH LONG %2
    JMP irq_common_stub
%endmacro

ISR_NOERRCODE 0 
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7

ISR_ERRCODE 8
ISR_NOERRCODE 9
ISR_ERRCODE 10
ISR_ERRCODE 11
ISR_ERRCODE 12
ISR_ERRCODE 13
ISR_ERRCODE 14
ISR_ERRCODE 17

ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31
ISR_NOERRCODE 128
ISR_NOERRCODE 177

IRQ 0, 32
IRQ 1, 33
IRQ 2, 34
IRQ 3, 35
IRQ 4, 36
IRQ 5, 37
IRQ 6, 38
IRQ 7, 39
IRQ 8, 40
IRQ 9, 41
IRQ 10, 42
IRQ 11, 43
IRQ 12, 44
IRQ 13, 45
IRQ 14, 46


extern isr_handler
isr_common_stub:
;SS
;ESP
;EFLAGS
;CS
;EIP
;all the above are automatically pushed to the stack by the cpu when an interupt occurs if we are in ring 3, in ring 0 just EFLAGS,CS,EIP are pushed
;If it's an exception with an error code, it also pushes the error code
;we push 0, it it was an interrupt where the cpu does not automatically push an error code
;we push interupt number
;pusha then pushes EAX,ECX,EDX,EBX,ESP,EBP,ESI,EDI
;then we push ds and cr3
;note that push esp pushes a memeory addr such as 0x9000,That is exactly like writing in C,InterruptRegisters *regs = (InterruptRegisters*)0x9000;
    pusha
    MOV ebx,ds
    PUSH ebx;saves the data segment
    MOV eax,cr3
    PUSH eax;Save the page directory's physical address
    MOV ax,0x10;Switch all data segments to the kernel data segment.
    MOV ds,ax
    MOV es,ax
    MOV fs,ax
    MOV gs,ax

    PUSH esp;Now the stack contains InterruptRegisters
    CALL isr_handler;C now receives regs

;resore the original data structure
    ADD esp,4
    POP eax
    POP ebx
    MOV ds,bx
    MOV es,bx
    MOV fs,bx
    MOV gs,bx

    POPA;restore the previously pushed gen purpose registers
    add esp,8
   ; STI;Turns interrupts back on.
    IRETD;iret pops EIP,CS,EFLAGS (and, if needed, ESP and SS when returning to a lower privilege level)

extern irq_handler
irq_common_stub:
    pusha
    MOV ebx,ds
    PUSH ebx
    MOV eax,cr3
    PUSH eax
    MOV ax,0x10
    MOV ds,ax
    MOV es,ax
    MOV fs,ax
    MOV gs,ax

    PUSH esp
    CALL irq_handler

    ADD esp,4
    POP eax
    POP ebx
    MOV ds,bx
    MOV es,bx
    MOV fs,bx
    MOV gs,bx

    POPA
    add esp,8
   ; STI
    IRETD

global timer_irq0

timer_irq0:
;check the two dpl bits in the cs register to know if we are about to take the kernel or a user program from and off the cpu and put it the kernel pcb array
;MOV eax,[esp + 4]; get the cs from the stack its pushed automatically by the hardware
;AND eax,3
;JNZ timmer_common_stub

;pushing_kernel_off_cpu:
;save the current frame temprarily cause in we are in ring 0 EFLAGS,CS,EIP has been automatically pused to the stack
;mov eax,[esp]; EIP
;mov ebx,[esp + 4]; CS
;mov ecx,[esp + 8]; EFLAGS
;mov edx,esp
;add edx,12 ; EDX now contains the real esp before the timer interupt was fired

;now we will rebuild in the correct hadware order that it would have been in if timer fired in ring 0
;we want it to be in this order on the stack: SS,ESP,EFLAGS,CS,EIP;
;since the stack grows donwards we need to overwrite

;clear old 3 value off the stack (EFLAGS,CS,EIP) and push 5 values in the correct order
;add esp,12 ;this has remove the old EFLAGS,CS,EIP now esp = the value in edx (real esp before)

;PUSH dword 0x10; SS:0x10 is a selector from the gdt
;PUSH edx ; ESP
;PUSH ecx ; EFLAGS
;PUSH ebx; CS
;PUSH eax; EIP


timmer_common_stub:
    push  0
    push  32
    pusha
    MOV ebx,ds
    PUSH ebx
    MOV eax,cr3
    PUSH eax
    MOV ax,0x10
    MOV ds,ax
    MOV es,ax
    MOV fs,ax
    MOV gs,ax

    PUSH esp
    CALL irq_handler
    ADD esp,4
    POP ebx
    MOV ds,bx
    MOV es,bx
    MOV fs,bx
    MOV gs,bx

    POPA
    add esp,8
   ; STI
    IRETD
