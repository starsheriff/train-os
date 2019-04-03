# Hello World in 16-bit real mode
The cpu is currently still in 16-bit real mode as initialized by the BIOS. The next thing
to do is to print `Hello World!` on the screen.

The goal is to learn about and how to use the 
[BIOS functions](https://wiki.osdev.org/BIOS#BIOS_functions).

We could just follow a tutorial like 
[this one](http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf)
(which is really good!), but my intention is to find a way to solve the problems from
source. The reason is that for me, the learning experience is _way_ better if I learn
where I can look up things when I encounter a problem.

Hence, I will try to find sources and document the process of finding them. I will make
the chapters a bit more verbose than they would have to but I think it provides some
value that is often missing in other tutorials.

# Getting Started
So, how did I learn about BIOS functions at all? Well first read

* this: https://wiki.osdev.org/BIOS
* this: https://en.wikibooks.org/wiki/X86_Assembly/Bootloaders
* and chapters 2 and 3.1 of this: http://www.cs.bham.ac.uk/~exr/lectures/opsys/10_11/lectures/os-dev.pdf

These sources explain the boot process and also explain the conept of BIOS functions or
BIOS interrupt calls. It is very similar to syscalls. You write a value to a specific
register with the function you want to execute and then cause an interrupt.

## Invoking a BIOS function
To invoke a bios function we have to raise an interrupt, specifically an interrupt with
a number associated with the BIOS function we want to run. 

I was not able to find exhaustive documentaion of the available functions. It still
bothers me is that the only sources I could find are the osdev wiki pages, wikipedia
pages and the tutorial. The osdev page gives a high level overview.

```
    INT 0x10 = Video display functions (including VESA/VBE)
    INT 0x13 = mass storage (disk, floppy) access
    INT 0x15 = memory size functions
    INT 0x16 = keyboard functions 
```
Interrupt `0x10` is used for _Video display functions_ which is likely what we are
looking for to print a character to the screen.

We also learn that we have to set register `ax` with some values for the specific function
we want to execute. More specifically, we have to set the high bit `ah` to the value
of the function and `al` is most likely used as argument to the function. Again, I could
not find more thorough documentation.

## Which function can we use to print to the screen?
How the heck can we print something to screen? The immediate questions
I hade were:

1. I need an overview of the available functionality.
2. Which function can I use to print to the screen?
3. Where can I find documentation about the BIOS functions.
4. Is this standardised?
5. Who implements them? The cpu vendors or mainboard vendors?

I could not find any exhaustive or otherwise authorative source of information to help
me solve these questions.

...

Except this beauty here: http://www.ctyme.com/intr/rb-0106.htm

This is the _best_ information I could find... come on. That site was showing me nsfw
ads and immediately causes eye cancer. Anyway, I found what I needed to know to print a
character to the screen:

```
VIDEO - TELETYPE OUTPUT

AH = 0Eh
AL = character to write
BH = page number
BL = foreground color (graphics modes only)

Return:
Nothing

Desc: Display a character on the screen, advancing the cursor and scrolling the screen as necessary

Notes: Characters 07h (BEL), 08h (BS), 0Ah (LF), and 0Dh (CR) are interpreted and do the expected things. IBM PC ROMs dated 1981/4/24 and 1981/10/19 require that BH be the same as the current active page 
```

# Summary
We are still in 16-bit real mode, but managed to invoce a BIOS function by causing an
software interrupt and setting the correct registers to the correct values.

We also learned that it is quite hard to find good resources for this particular topic.
