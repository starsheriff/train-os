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
Back to business. Looks like the first thing we have to do is to disable paging. We have
not yet talked about paging. This is a big topic and I am looking forward to it. I happen
to know a bit about paging, so it is maybe a bit unfair if you have never heard about it.





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
