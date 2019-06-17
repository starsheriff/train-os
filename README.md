#: Train-OS
A training session to build an operating system. Starting from the ground up, _only_ using
resources from _AMD_ and _Intel_. 

## __STILL IN ALPHA STAGE__
This repository is not polished yet and still has to be regarded in alpha stage. The code
should compile and work, but the texting is just the first draft I noted down besides
while I was coding and researching.

# What is different to other tutorials?
There are a lot of tutorials and a large part of the material I present is
covered also there. So why bother? I especially like and got inspired by these:

* phil TODO: link
* intermezzOS: TODO: link

What is different in this version? When I learn new things, I often have the
feeling that I don't know/learn _how_ I could do what I just did completely
on my own the next time. I don't know if it is the way I learn or just a typical
thing that is easily omitted when writing tutorials. Here are some points I
am wondering about regularily and that I want to address (I will probably miss
out on other essential stuff to make up for it)

* Provide some more details on _what_ points simply are _conventions_ that were
  agreed on, what is a standard, what is architecture specific. 
  I still remember when I first started to learn programming as a teenager I was
  like "uuhh... how does the computer know that the function _main_ has to be
  called first", and none of my friends or teachers new. It was just "magic".
  These things _bother_ me, I want to uderstand where things come from...
* Point to the standard and work from there. I won't present a _finished_ solution
  that you just copy. We take the standard, and actually _look things up_.
  Just as we would have to to if we would like to run the code on let's say
  an ARM Cortex instead of your x86_64 machine. Or, framed differently, what
  if we would be the first ones to write a tutorial, _how_ would we get that
  bootloader going, the interrupts configured or the cpu into 64-bit mode in the first
  place?
* Do things twice. I'll first go barebones, this helps to understand what's
  happening and then, we use tooling to avoid doing that ground work every time.
* Intermediate steps and "checkpoints"
* give an outline first -> to see the bigger picture
* give examples into real code -> e.g. that the first kernel bin is actually
  exactly how linux is built
* present alternatives/choices for each `dependency` we start using. To me it's 
  bummer if I want to follow a tutorial and a lot of external libraries do
  the magic that I actually wanted to learn.

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
4. Manually switch to 64-bin long mode
5. Use GRUB as bootloader and print `Hello World`.
6. Switch to long mode (again).
7. Jump into `C`, print `Hello World`.
8. Stack
9. Implement VGA video driver.
10. Interrupts (Part 1) - Tell CPU where to find handlers, in asm
11. Interrupts (Part 2) - Move code from 10. over to c
12. Implement better handlers
13. Debugging
14. Handle interrupts/exceptions
15. Implement memory paging.
16. Remap Kernel


unspecified:
* refactoring?
* utilities (memset?)

### Later on...
* filesystem
* processes
* scheduling
* system calls
* explore the stack, provoke stack overflows and exceptions
* connect with GDB via UART (for debugging and embedded preview)
* cross-compile some (or many) parts to an ARM processor. (I have an STM and Infineon
  board lying around unused)

# Prerequesits?
None. Seriously, don't get scared. The whole point of this tutorial is to develop all
required knowledge from the ground up. There is only _one_ condition I assume, and that
is that you can program decently. By decent I mean that you at least have heard about
the stack and heap and can be productive in some language. I guess that should be enough.
After all, we are not trying to develop the next gen mainstream os here, we are tinkering
on a hobby level. 

And one things I can assure you: Even if you will never touch this code again and will
never write an OS. The experience _will_ change your understanding of the systems you
are working on _deeply_. The knowledge gained from developing at kernel level spreads
like seeds throughout your career and the insights will prove useful in the most
unexpected moments.

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
2. [Intel Manuals](https://software.intel.com/en-us/articles/intel-sdm)
