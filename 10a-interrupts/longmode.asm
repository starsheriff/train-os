global longstart

section .text
bits 64
longstart:
    mov word [0xb8000], 0x0e4f ; 'O', yellow on black
    mov word [0xb8002], 0x0e4b ; 'K', yellow on black
    
	;mov eax, [0xFF_FFFF]
    hlt
    

