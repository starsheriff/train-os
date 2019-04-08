# Switching to long mode
In the last section we have made a minimal bootable kernel loaded with GRUB. We printed
`OK` on the screen and halted the cpu.

From here on, we have many options. There is a ton of things to do that even I know of,
like
* setting up ~a~ the stack,
* reading the memory areas from GRUB,
* or working on a better VGA driver to get better output
Basically, the options for the next step are many. 

What I want to do is to switch over into long mode (64-bit mode) as soon as possible. And
that is the goal for this section. Again, I will try to do it from specs and vendor
resources, not by purely following an available tutorial. If at the end of the section
we are still able to print `OK` to the screen, we're happy.

# Let's begin.
The code is based on the last section. Just start with a copy of the source code from that
chapter.

First off, I have no idea yet what we will need to do to switch over to long mode. I am
also

Let's start off with the _AMD64 Architecture Programmer's Manual Volume 2_. Skimming
through the outline leads me to chapter 14, which seems to be exactly what we are after:

> This chapter describes the hardware actions taken following a processor reset and the
> steps that must be taken to initialize processor resources and activate long mode.

In chapter 14.6.1, the process of activating long mode is described in more detail.
> Switching the processor to long mode requires several steps. In general, the sequence
> involves disabling paging (CR0.PG=0), enabling physical-address extensions (CR4.PAE=1),
> loading CR3, enabling long mode (EFER.LME=1), and finally enabling paging (CR0.PG=1). 

## <personal_interlude> (Skip if not of interest)
Just a side note from my personal learning experience and preferences. Reading these
sentences in an official programmers manual for an architecture is fundamentally different
than reading the same sentences in a tutorial or other book.
Obtaining this information from a primary source has much more value to me. It proves that
I am able to find information to _any_ problem, or at least reinforces my confidence.
Just reading and accepting this kind of knowledge from a book, tutorial or blogpost
would not enable me to find this kind of information. And rest assured, as soon as you
leave the path and diverge a bit from the tutorial you are following, questions _will_
pop up and you _will_ have to solve them. Knowing _where_ to find this kind of information
is way more satisfying and robust than relying on StackOverflow or Google. My 2 cents.


# Disable Paging (if enabled)
Back to business, the first thing we have to is to disable paging. Do disable paging,
the manual describes, we have to set register `CR0.PG` to `0`.

What does that mean exactly? 

If we try to set the register `cr0` to `0` using the `mov` instruction the assembler
raises errors:

```
$ nasm -f elf64 boot.asm -o build/boot.o
boot.asm:19: error: invalid combination of opcode and operands
```

So, the assembler does not allow us to set the register directly. Also, the manual talks
about `CR0.PG` and not `CR0`. So what is the `.PG` part? If we search for `CR0` we find
the following in section _5.1.2 Page-Translation Enable Bit (PG)_:

> Page translation is controlled by the PG bit in CR0 (bit 31). When CR0.PG is set to 1,
> page translation is enabled. When CR0.PG is cleared to 0, page translation is disabled.

This means we are not supposed to clear the whole register but _only_ bit 31. To do
that, we have to temporarily store the register. We use `eax`.

```
mov eax, cr0
```

This compiles. Now we clear bit 31. To clear a bit, one generally uses a bitwise `and`
operation where all bits you want to keep unchanged are set to `1` and all bits you want
to clear are set to `0`. 

To get that bitmap we can either manually write it out and `and` it with `eax

```
and eax, 0b1000_0000_0000_0000_0000_0000_0000_0000
```

but this is obviously _way_ to verbose. Instead, we use a bitshift `<<` with a negation:
```
and eax, ~(1 << 31)
```
This is way easier to read and write.

Last, we set `cr0` to the value that we now have stored in `eax`. This time, the write
to `cr0` works.

```
mov cr0, eax
```

Now, bit 31 of `cr0`, `cr0.pg`, is cleared.

# Next


From the AMD progammers manual, section 14.6:
> Long mode is enabled by setting the long-mode enable control bit (EFER.LME) to 1.
> However, long mode is not activated until software also enables paging. When software
> enables paging while long mode is enabled, the processor activates long mode, which
> the processor indicates by setting the long-mode-active status bit (EFER.LMA) to 1.
> The processor behaves as a 32-bit x86 processor in all respects until long mode is
> activated, even if long mode is enabled. None of the new 64-bit data sizes,
> addressing, or system aspects available in long mode can be used until EFER.LMA=1.


# Set up the Stack
TODO



# Resources

[1] https://developer.amd.com/resources/developer-guides-manuals/

[AMD64 Architecture Programmer’s Manual Volume 1: Application Programming](http://support.amd.com/TechDocs/24592.pdf)

[AMD64 Architecture Programmer’s Manual Volume 2: System Programming](http://support.amd.com/TechDocs/24593.pdf)
