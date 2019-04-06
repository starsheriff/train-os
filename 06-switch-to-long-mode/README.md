# Switching to long mode
In the last section we have made a minimal bootable kernel loaded with GRUB. We printed
`OK` on the screen and halted the cpu.

From here on, we have many options. There is a ton of things to do that even I know of,
like
* setting up ~a~ the stack,
* reading the memory areas from GRUB,
* or working on a better VGA driver to get better output
capabilities right away. Basically, the options for the next step are many. 

What I want to do is to switch over into long mode (64-bit mode) as soon as possible. And
that is the goal for this section. Again, I will try to do it from specs and vendor
resources, not by purely following an available tutorial.

# Let's begin.
The code is based on the last section. Just start with a copy of the source code from that
chapter.

First off, I have no idea yet what we will need to do to switch over to long mode. I am
also

From the AMD progammers manual, section 14.2:
> Long mode is enabled by setting the long-mode enable control bit (EFER.LME) to 1.
> However, long mode is not activated until software also enables paging. When software
> enables paging while long mode is enabled, the processor activates long mode, which
> the processor indicates by setting the long-mode-active status bit (EFER.LMA) to 1.
> The processor behaves as a 32-bit x86 processor in all respects until long mode is
> activated, even if long mode is enabled. None of the new 64-bit data sizes,
> addressing, or system aspects available in long mode can be used until EFER.LMA=1.

# Resources

[1] https://developer.amd.com/resources/developer-guides-manuals/
[AMD64 Architecture Programmer’s Manual Volume 1: Application Programming](http://support.amd.com/TechDocs/24592.pdf)
[AMD64 Architecture Programmer’s Manual Volume 2: System Programming](http://support.amd.com/TechDocs/24593.pdf)
