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

# Long Mode Activation

## Disable Paging (if enabled)
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

# Enable Physical Address Extension
Next, we will enable the physical address extension. Again, the programmers manual is
our friend:

> Physical-address extensions are controlled by the PAE bit in CR4 (bit 5). When CR4.PAE
> is set to 1, physical-address extensions are enabled. When CR4.PAE is cleared to 0,
> physical-address extensions are disabled.
> 
> Setting CR4.PAE = 1 enables virtual addresses to be translated into physical addresses
> up to 52 bits long. This is accomplished by doubling the size of paging data-structure
> entries from 32 bits to 64 bits to accommodate the larger physical base-addresses for
> physical-pages.


This means we have to set bit 5 in `cr4`. We follow the same approach as before. First,
we copy the register into `eax`. Then, we set bit 5 in `eax` and then we copy the new
value from `eax` to `cr4`.

```assembly
; Step 2: Enable Physical Address Extension
mov eax, cr4
and eax, (1 << 5)
mov cr4, eax
```

## What did we just do?
So, what is this bit doing exactly? I don't know in detail. What the manual tells me though
is that a) up intil now, the cpu was still addressing its memory using 32-bit addresses.
This means it is physically _impossible_ to address more than 4 GiB. The processor "only"
had 2^32 addresses.

Also, keep in mind that we are _really_ at hardware level now. We are actually
configuring the cpu. Setting the bit will tell the cpu that from now it should use 64-bit
physical addresses. This might have a lot of implications on it's internal workings.
Some of these will even become visible to us. First of all we will be able to use 64-bit
addresses ourselves and second we will have to use a page table entry layout that matches
this mode; i.e. the page table entry is 64 bits long.

## Virtual Addresses, Page Tables?!



# Scratchpad/Notes


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
