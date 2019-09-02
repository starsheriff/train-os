; Compile to raw/flat machine code:
; $ nasm -f bin boot.asm -o boot.img
;
; Compile to object file in elf format:
; $ nasm -f elf boot.asm -o boot.o
;
; Run with qemu:
; $ qemu boot.img
; 


; `jmp` jumps to the given address, `$` is a shorthand notation in nasm syntax
; referencing to the address of the beginning of the current line
jmp $

; instead of writing the remaining bytes all out in the file (which we could) we use
; the `times` nasm directive to fill the remaining bytes with zeros.
;
; The bios expects the magic bytes 0xaa55 at the end of the 512 bytes block.
;
; The number of bytes to write is then 512 minus the two bytes at the end, minus the
; number of bytes we have used already.
;
; To calculate the number of bytes we can use the dollar sign notation `$` and `$$`.
; `$` is replaced by the assembler with the address of the beginning of the current
; line, while `$$` is replaced with the address of the beginning of the current section;
; in this case the beginning.
;
; References:
; https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html#section-3.2.5
; https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html#section-3.5
times 512-2-($-$$) db 0

; the magic bytes we have to write at position 510 and 511
; References:
; https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders#The_Bootsector 
dw 0xaa55
