; boot.asm

; The label start is our entry point. We have to make it
; public so that the linker can use it.
global start

section .text

; we are still in 32-bit protected mode so we have to use
; 32-bit wide instructions
bits 32

start:
    mov word [0xb8000], 0x0e4f ; 'O', yellow on black
    mov word [0xb8002], 0x0e4b ; 'K', yellow on black
    hlt
