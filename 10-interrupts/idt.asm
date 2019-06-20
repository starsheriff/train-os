global idtr
global init_idt
extern handle_interrupt

section .text

init_idt:
    ; eax is used to store the current location in memory and is advanced until the
    ; end of the idt is reached
    mov rax, idt
    
    mov rbx, idt_handler

.init_single_entry:

    mov word [rax], bx

    ; TODO: set idt entries and advance eax register
    ; for now, just advance by two bytes to not get stalled here
    add eax, 2

    ; compare the current memory address with the end of the idt. If the address is
    ; lower than the end, jump back and initialize another idt entry
    cmp eax, idtr
    jl .init_single_entry
    
    ret

idt_handler:
    ; TODO: store current state of registers etc. before calling the handler
    call handle_interrupt
    
    ; use iretq because we are in long mode
    iretq
    
    
    

section .data
; not sure about the alignment. To be sure, I will page align the idt for now.
align 4096

; the number of available interrupts, i.e. the number of entries in the idt
; ref section 8.2 p. 216 in AMD's programmers manual
IDT_NUM_ENTRIES equ 256

; the size of a single entry in the idt, in _long mode_, is 16 bytes.
; ref section 4.6.5 p. 79 in AMD's programmers manual
IDT_ENTRY_SIZE equ 16

; total size in bytes required for the idt
IDT_TOTAL_SIZE equ IDT_NUM_ENTRIES*IDT_ENTRY_SIZE

idt:
    resb IDT_TOTAL_SIZE
idtr:
    dw $ - idt - 1  ; two bytes (word), declaring the size of the IDT in bytes
    dq idt          ; 64-bit (double quad word) base address of the idt
