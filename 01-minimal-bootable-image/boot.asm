; Compile to raw/flat machine code:
; $ nasm -f bin boot.asm -o boot.img
;
; Run with qemu:
; $ qemu boot.img

; `jmp` jumps to the given address, `$` is a shorthand notation in nasm syntax
; referencing to the address of the beginning of the current line
;jmp $
jmp 0x4499989

; We have to write a whole block of 512 bytes with the last two bytes being
; 0xaa55.
;
; Instead of writing the remaining bytes all out in the file (which we could)
; we use the `times` nasm directive to fill the remaining bytes with zeros.
; The number of bytes to write we have to write is 512 minus the two bytes at
; the end, minus the number of bytes we have used already.
;
; To calculate the number of bytes we can use the dollar sign notation `$` and
; `$$`. `$` is replaced by the assembler with the address of the beginning of
; the current line, while `$$` is replaced with the address of the beginning of
; the current section in this case the beginning.
;
; References:
; https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html#section-3.2.5
; https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html#section-3.5
times 512-2-($-$$) db 0

; The magic bytes we have to write at position 510 and 511
; References:
; https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders#The_Bootsector 
dw 0xaa55
