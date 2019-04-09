; boot.asm

; The label start is our entry point. We have to make it
; public so that the linker can use it.
global start

section .text

; we are still in 32-bit protected mode so we have to use
; 32-bit wide instructions
bits 32

start:
    ; Switching to long mode
    ;
    ; Step 1: Disable paging
    ;
    ; to disable paging set `CR0.PG` to `0`.
    mov eax, cr0
    and eax, ~(1 << 31)
    mov cr0, eax

    ; Step 2: Enable Physical Address Extension
    mov eax, cr4
    and eax, (1 << 5)
    mov cr4, eax

    ; Step 3: Set `cr3` register
    mov eax, p4_table
    mov cr3, eax

    ; Step 3: Configure 2 MiB physical pages

    mov word [0xb8000], 0x0e4f ; 'O', yellow on black
    mov word [0xb8002], 0x0e4b ; 'K', yellow on black
    hlt

section .bss
; must be page aligned
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096

