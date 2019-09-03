# Creating the first bootable image
The first thing I wanted to do is to create the simplest possible code that
we can boot on a x86 machine. 

# Quickstart

## Pre Requesits
Besides standard tooling you need only a few things in order to build the
project. Namely,
* `nasm` the [netwide assembler](https://en.wikipedia.org/wiki/Netwide_Assembler)
* and `qemu` to emulate a x86_64 machine.

Both should be available as packages for basically every Linux distribution I
can think of.

### Compile
```
nasm -f bin boot.asm -o boot.img
```

### Run with `qemu`
```
qemu boot.img
```

### Hexdump
```
hexdump boot.img
```

# Result

```
> hexdump boot.img
0000000 feeb 0000 0000 0000 0000 0000 0000 0000
0000010 0000 0000 0000 0000 0000 0000 0000 0000
*
00001f0 0000 0000 0000 0000 0000 0000 0000 aa55
0000200
```


# Conclusion
With only a few lines of code, we have actually created a first bootable image.
It is not doing anythin, but we have learned a few things.

Besides that, RTFM(!) really. Do it. It will enlighten you and boost your
knowledge.

1. Multiboot Standard (really readable and easy to understand)
* Intel x86 Programming Manual (pffehhw... it is gigantic, don't even attempt reading it
  front to back. But try to find _specific_ information


# Scratchpad (personal notes)

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
