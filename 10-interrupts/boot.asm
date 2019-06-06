; boot.asm

; The label start is our entry point. We have to make it
; public so that the linker can use it.
global start
extern c_start

; we are still in 32-bit protected mode so we have to use
; 32-bit wide instructions
bits 32

;
PTE_PRESENT equ 1 << 7

; Flags for _large_ p2 aka. PDE page table entries
PDE_PRESENT  equ 1 << 0
PDE_WRITABLE equ 1 << 1
PDE_LARGE    equ 1 << 7


; GDT Flags

start:
    ; Set stack pointer
    mov esp, stack_top
    
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
    or eax, (1 << 5)
    mov cr4, eax

    ; Step 3: Set `cr3` register
    mov eax, p4_table
    mov cr3, eax

    ; Step 4: Set the p2[1] entry to point to the _second_ 2 MiB frame
    mov eax, (0x20_0000 | PDE_PRESENT | PDE_WRITABLE | PDE_LARGE)
    mov [p2_table + 8], eax

    ; point the 0th entry to the first frame
    ; TODO: explain
    mov eax, (0x00_0000 | PDE_PRESENT | PDE_WRITABLE | PDE_LARGE)
    mov [p2_table], eax

	; Step 5: Set the 0th entry of p3 to point to our p2 table
	mov eax, p2_table ; load the address of the p2 table
	or eax, (PDE_PRESENT | PDE_WRITABLE)
	mov [p3_table], eax

	; Step 6: Set the 0th entry of p4 to point to our p3 table
	mov eax, p3_table
	or eax, (PDE_PRESENT | PDE_WRITABLE)
	mov [p4_table], eax

	; Step 7: Set EFER.LME to 1 to enable the long mode
	mov ecx, 0xC0000080
	rdmsr
	or  eax, 1 << 8
	wrmsr

	; Step 8: enable paging
	mov eax, cr0
	or eax, 1 << 31
	mov cr0, eax

	; is paging enabled now?
	; -> No, this instruction still works
	;mov eax, [0xFF_FFFF]

	; Step 9: Disable Interrupts

	; Step 11: Enable Interrupts

    lgdt [gdt64.pointer]
    jmp gdt64.code:longstart
   
section .text
bits 64
longstart:
    ; uncomment the next line and you will have a page fault
    ;mov eax, [0xFF_FFFF]
    call c_start

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
stack_bottom:
	resb 4096
stack_top:
    
section .rodata
gdt64:
	dq 0
.code: equ $ - gdt64
	dq (1 << 43) | (1 << 44) | (1 << 47) | (1 << 53)
.pointer:
	dw $ - gdt64 - 1 ; length of the gdt64 table
	dq gdt64         ; addess of the gdt64 table

section .text
