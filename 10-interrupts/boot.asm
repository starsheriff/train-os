; boot.asm

; The label start is our entry point. We have to make it
; public so that the linker can use it.
global start
extern c_start
extern init_idt
extern print_interrupt
global idt
global flush_idt

; we are still in 32-bit protected mode so we have to use
; 32-bit wide instructions
bits 32

;
PTE_PRESENT equ 1 << 7

; Flags for _large_ p2 aka. PDE page table entries
PDE_PRESENT  equ 1 << 0
PDE_WRITABLE equ 1 << 1
PDE_LARGE    equ 1 << 7

; number of entries in
IDT_ENTRIES equ 32


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

    ; Now we set up the IDT
    
	; Step 9: Disable Interrupts

    lgdt [gdt64.pointer]
	; Step 11: Enable Interrupts

    ; cli ; disable interrupts
    jmp gdt64.code:longstart
   
section .text
bits 64
longstart:
    mov rsp, stack_top

    ; not sure if we have to reload the lgdt once we are in 64-bit mode.
    lgdt [gdt64.pointer]

    ; load the interrupt descriptor table register. This allows the cpu to find the
    ; interrupt descriptor table (IDT).
    lidt [idt.idtr]
    call init_idt ; c code
    call populate_idt ; asm code

    
    ;mov word [0xb8000], 0x0e4f ; 'O', yellow on black
    ;mov word [0xb8002], 0x0e4b ; 'K', yellow on black
    ; sti

    ; immediately clear interupts to avoid reboots
    ; cli

    ; uncomment the next line and you will have a page fault
    ;mov eax, [0xFF_FFFF]
    call c_start


; dummy handler that does _nothing_
global idt_handler
idt_handler:
    ; jmp $
    call print_interrupt
    iretq

global disable_interrupts
disable_interrupts:
    cli
    ret

global trigger_interrupt
trigger_interrupt:
    int 0x03
    ret

; *************************************** IDT *********************
FLAG_INTERRUPT equ 0xe
FLAG_R0 equ (0 << 5)    ;Rings 0 - 3
FLAG_P equ (1 << 7)
CODE_SEL equ 0x08

GLOBAL populate_idt
populate_idt:
    mov eax, idt
    mov ebx, idt_handler
    ; or ebx, (VIRT_BASE & 0xFFFFFFFF)
 
idt_init_one:
    ; /* Target Low (word) */
    mov ecx, ebx
    mov word [eax], cx
    add eax, 2
 
    ; /* Code Selector (word) */
    mov word[eax], CODE_SEL
    add eax, 2
 
    ; /* IST (byte) */
    mov byte[eax], 0
    add eax, 1
 
    ; /* Flags (byte) */
    mov byte[eax], (FLAG_P|FLAG_R0|FLAG_INTERRUPT)
    add eax, 1
 
    ; /* Target High (word) */
    shr ecx, 16
    mov word[eax], cx
    add eax, 2
 
    ; /* Long Mode Target High 32 */
    shr ecx, 16
    mov dword[eax], ecx ;(idt_handler >> 32)
    add eax, 4
 
    mov dword[eax], 0
    add eax, 4
 
    cmp eax, idt.idtend
    jl idt_init_one
 
    ; lidt[IDTR]
    ret

flush_idt:
    mov eax, [rsp+8]
    lidt[eax]
    ret
    
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
	dq gdt64         ; address of the gdt64 table

section .data
;
; the IDT table contains 256 64-bit entries.
; Hence, we reserve 256 double quad words (64-bit) entries.
;
; The IDT must be 16-bit aligned.
align 16
idt:
    times IDT_ENTRIES dq 0 ; a double quad per entry
    times IDT_ENTRIES dq 0 ; a double quad per entry
; Figure 4-8 shows the format of the `IDTR` in long-mode. The format is identical to the
; format in protected mode, except the size of the base address.
.idtr:
    dw $ - idt - 1  ; two bytes (word), declaring the size of the IDT in bytes
    dq idt          ; 64-bit (double quad word) base address of the idt
.idtend:
