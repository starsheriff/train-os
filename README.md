# Outline
A rough outline of what I want to do. Hopefully, in a more or less chronological order.
The point is that there is so much we could possibly do that it actually is quite hard
to choose a path.

First, I would like to get a better understanding of the boot process. What happens
_before_ the bootloader jumps in. Actually rolling your own bootloader (link to osdev)
is a huge task in by itself.

My plan is to explore the early phase in the boot process a little bit. The goal of that
is to understand and appreciate what a bootloader is doing for us. At the end, I would
like to have a rough understanding of the different processor modes, what they offer and
how to switch to the 32-bit protected mode. The concrete goal is to be able to switch
over to the protected mode and print `Hello World!` to the screen. Everything implemented
in assembly and without the use of a boot loader.

After that, I plan to switch over and use GRUB as a bootloader. And continue from there.

## TL;DR
1. Write a minimal bootable image.
2. Bootloader that prints `Hello World` in 16-bit real mode.
3. Manually switch to 32-bin protected mode and print `Hello World`.
3. Manually switch to 64-bin long mode
4. Use GRUB as bootloader and print `Hello World`.
5. Switch to long mode (again).
6. Jump into `C`, print `Hello World`.
7. Implement VGA video driver.
8. Handle interrupts/exceptions
9. Implement memory paging.
10. Remap Kernel

### Later on...
* filesystem
* processes
* scheduling
* system calls
* explore the stack, provoke stack overflows and exceptions
* connect with GDB via UART (for debugging and embedded preview)
* cross-compile some (or many) parts to an ARM processor. (I have an STM and Infineon
  board lying around unused)

# Scratchpad (unorganized ideas from here on)

# Ideas
* what does the cpu do if you put instructions _after_ the first 512 bytes? Are they
  executed? (CPU is in 16-bit real mode)

# Outline

* Bootload -> two choices roll your own or use existing, e.g. GRUB.
* 16bit mode
* entering 32bit protected mode
* entering 64bit long mode
* enter c 
* write memory managemen module


# Cycle 0 - Environment & Cross-Compilation Toolchain

* you may skip some of the steps. We won't need the cross compilation toolchaine before
  before we start writing C code.
* start building your toolchain somewhere under $HOME
* make sure the scope of environment variables is correct
* errors like "don't have permission to create directory `/usr/lib/i686-elf`" indicates
  that `$PREFIX` is not correctly set.
* We're not getting the "real" barebones CPU, there's still the BIOS before us. It
  initializes the CPU and hands over to us with the CPU in real mode.


# Cycle 0 - Bootloader

# Resources

1. NASM Documentation https://www.nasm.us/xdoc/2.14.02/html/nasmdoc3.html
