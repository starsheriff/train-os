;
; Multiboot compliant header
;
; Specification:
; https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#OS-image-format

section .multiboot_header
header_start:
    ; First Field `magic`
    ; The header has to start with the magic number at offset 0.
    MAGIC equ 0xe85250d6
    dd MAGIC
    
    ; Second Field `architecture`
    ;
    ; Two options are available
    ;   `0` - for 32-bit i386
    ;   `4` - for 32-bit MIPS
    ;
    ; In our case we hav to chose `0`
    dd 0

    ; Third Field `header_length`
    ;
    ; Must be the total length including the magic field and custom tags.
    dd header_end - header_start

    ; Fourthf Field `checksum`
    dd - (MAGIC + 0 + (header_end - header_start))

    ; Mandatory end tag
    dw 0 ; 16-bit, type `0`
	dw 0 ; 16-bit, flags (assuming they should be zero)
	dd 8 ; 32-bit, 8 (preceeded by two 4 byte fields)
header_end:
