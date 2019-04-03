; Compile to raw/flat machine code:
; $ nasm -f bin boot.asm -o boot.img
;
; Compile to object file in elf format:
; $ nasm -f elf boot.asm -o boot.o
;
; Run with qemu:
; $ qemu boot.img


; the interrupt code to print a single character is 0x0e
; this value must be written to register ah before triggering the interrupt 0x10
;PRINTCHAR equal 0x0e

; set the bios function to print a single char
mov ah, 0x0e

; move 'H' to register al, the assembler translates the char 'H' to the corresponding
; ascii code
mov al, 'H'

; now we have to trigger the interrupt
int 0x10

; Now we repeat the process for the remaining characters. Note that we don't have to
; set register `ah` anymore since it is already set to the correct BIOS function.
mov al, 'e'
int 0x10
mov al, 'l'
int 0x10
mov al, 'l'
int 0x10
mov al, 'o'
int 0x10
mov al, ' '
int 0x10
mov al, 'W'
int 0x10
mov al, 'o'
int 0x10
mov al, 'r'
int 0x10
mov al, 'l'
int 0x10
mov al, 'd'
int 0x10
mov al, '!'
int 0x10


; stop execution with infinite loop
jmp $

; To calculate the number of bytes we can use the dollar sign notation `$` and `$$`.
; `$` is replaced by the assembler with the address of the beginning of the current
; line, while `$$` is replaced with the address of the beginning of the current section;
; in this case the beginning.
;
; References:
; https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html#section-3.2.5
; https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html#section-3.5
times 512-2-($-$$) db 1

; the magic bytes we have to write at position 510 and 511
; References:
; https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders#The_Bootsector 
dw 0xaa55
