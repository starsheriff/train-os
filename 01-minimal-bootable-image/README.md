# Creating the first bootable image

# Things to cover (still WIP)

First off we create a very simple bootable image.

* bios will look for the magic bytes at position 510 and 511, if they are set
  the CPU will start executing from there
* in which mode will the CPU be
* what is TTY mode
* link to Multiboot Specification
* link to Intels Programming Manual
* the different output formats (bin = binary disk image, elf electronic linkable format)
* why don't we need `section .text` and `section .data` for the binary? Because
  we are not linking anything yet. 
* disassemble with `ndism`, bot .o and .bin files and compare output.
	* why are there so many `add EAX, AL` insructions?
	* What is the difference between `ndism` and `objdump`?
* what is the difference with `i686-elf-as` and `nasm`?
  -> both produce the same machine code but use different syntax
  -> nasm is specifically for x86 architectures, so on other architectures the assembler
     from the cross-compilation toolchain must be used


## More Information
RTFM, really. Do it. It will enlighten you and boost your knowledge.

* Multiboot Standard (really readable and easy to understand)
* Intel x86 Programming Manual (pffehhw... it is gigantic, don't even attempt reading it
  front to back. But try to find _specific_ information
 
