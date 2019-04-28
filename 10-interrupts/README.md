# Interrupts
In this section, we are going add facilities to our kernel to handle interrupts and
exceptions. Adding these capabilities early on is important I think, because it will
allow us to debug our kernel much easier. 

# Motivation
Let us start by breaking our kernel, to demonstrate _why_ we want to handle interrupts.
In section 6, when we jumped into long mode, we set up a very simple paging implementation
and manually mapped two pages. These two pages are 2 MiB in size each and are _identity
mapped_. That means that _virtual_ and _physical_ addresses match.

If we now declare a pointer with an address _outside_ of the mapped range like this
```c
char *page_fault = (char *) 0x400000;
```
We will get a page fault when we try to access the memory. What happens is that the cpu
takes the address and walks through page table `p4`, `p3` and `p2` which contains the
references to our large 2 MiB frames. In the last step to find the memory frame, the cpu
will index into the third entry of `p2`. However, we only set the first two entries in
`p2` so the age table entry for `p2[2]` is empty. This makes the cpu fire an page fault.

The full code of our `c_start` function is listed below. Since we do not handle
interrupts yet, the cpu will simply reset itself. If we run `qemu` now, it will enter a
restart loop.

```c
#include "vga.h"

void c_start() {
    char color_code = vga_color_code(VGA_COLOR_YELLOW, VGA_COLOR_BLACK); 
    vga_print(color_code, "Don't panic!");

    // declare a pointer to a byte just outside the memory we have mapped with our two
    // 2 MiB pages. The last address we can access is 0x3f ffff.
    // 
    // The declaration does not cause a page fault yet. We are not trying to access the
    // memory yet.
    // 
    //                          0x--||||
    char *page_fault = (char *) 0x400000;

    // Assigning a value to the memory address causes a page fault.
    *page_fault = 42;
    
    // loop forever
    while (1) {
    }

    return;
}
```
The question is, can we do better? Soon, we will have to implement a better version of
our memory mapping code. This will, potentially, lead to page faults similar to the
example above. Therefore, it would be extremely helpful to be able to print debug
messages in case the cpu encounters an error.

In the example it would have been nice if, instead of endlessly rebooting, we
would have gotten a message like

```
segmentation fault: 0x400000 is not mapped
```

This is *our goal* for this session. Make our kernel print an error message instead of
rebooting.

# Interrupt Basics
To do that, we have to utilize the cpus interrupts. Again, I will approach the problem
from the ground up, deriving and assemblying everything from proper sources. Btw. maybe
this is a first peek into _why_ I am doing this. Most of the obvious tutorials that are
available online actually don't cover this. Those that explain interrupts usually stay
in 32-bit protected mode.

Let's pull out the _AMD Programmer's Manual Vol. 2_ again. The relevant sections are 1.6
2.6, 

From section 1.6 we learn

> System software not only sets up the interrupt handlers, but it must also create and
> initialize the data structures the processor uses to execute an interrupt handler when
> an interrupt occurs.

So, this gives the first hint of what we will have to do. First, we will have to
implement the handlers for the interrupts. This one is kind of obvious. Second, we get
told that it is _our_ responsibility to set up the relevant data structures so that
the cpu can _find_ and _execute_ the interrupt handler as intended.

The paragraph goes on, and we get a first glimp of our ride ahead...

> The data structures include the code-segment descriptors for the interrupt-handler
> software and any data-segment descriptors for data and stack accesses. Interrupt-gate
> descriptors must also be supplied. Interrupt gates point to interrupt-handler
> code-segment descriptors, and the entry point in an interrupt handler. Interrupt gates
> are stored in the interrupt-descriptor table. The code-segment and data-segment
> descriptors are stored in the global-descriptor table and, optionally, the
> local-descriptor table. 

Section 2.6 describes interrupts and
exceptions. Already in the first paragraph we are made aware of that the mechanism for
interrupts is different in long-mode than in 32-bit protected mode. This means it might
be that other tutorials, using the 32-bit mode, will not work. So, we are on our own;
unless you have a tutorial that works with long-mode.

## First Overview
From a first read, I get the following points:

1. We need to set up the _interrupt decriptor table_ `IDT`. This `IDT` must contain
   64-bit entries. These entries are called either _trap-gate-_ or _interrupt-gate
   descriptors_. There is a third option, called _task gates_ which we cannot use
   in long-mode. See section 2.6.1 [1].
2. To _use_ the `IDT` we need an _interrupt descriptor table register_ (IDTR), which
   is identical to the `GDTR` we already set up in an earlier section.
3. I don't think we need a _local descriptor table_ `LDT`. We use exclusively the `GDT`.

* filter required from optional things

* _CPL (Current Priviledge Level)_

Wow, this looks like a bumpy ride ahead. 

## IDTR and IDT
First, we reserve space for the IDT without initializing it. Why we do that will become
clear in a minute. Section 4.6.5 contains all we need to know for the moment to reserve
the required space for the IDT.

```assembly
section .data
align 16
idt:
    times 256 dq 0 ; a double quad per entry
```
We have to put the table in the data section since we initialize the entries with `0`
at the moment. I am not sure if this is correct. If it turns out it is not, I will come
back to this. Currently however, this is the best I can do.

Now we can look at the `IDTR`. The `IDTR` (_interrupt descriptor table register_)  tells
the cpu where to find the IDT and how large the table is.
It solves two things with only using one register. Section 4.6.6 explains the register
and Figure 4-8 specifies the format of the fields.

First we have the _limit_ field, length 2 bytes, which contains the 
register...

```assembly
.idtr:
    dw $ - idt - 1  ; two bytes (word), declaring the size of the IDT in bytes
    dq idt          ; 64-bit (double quad word) base address of the idt
```

### IDT Entries
Now we have to go back to section 4.6.5

> The IDT can contain only the following types of gate descriptors:

Note the term _gate descriptors_. We will not find any section in the document called
_IDT entries_ or something similar. Instead, we have to jump to section 4.8.4 _Gate
Descriptors_ in long-mode.

### Questions
* Assembly vs. C
* Two stacks? One stack?
* What to put in the GDT?
* Stack Switch?
* `rsp` vs `esp`?
* should the IDT be in a mapped page or should we reserve the bytes in assembly? Do we
  know exactly what's happening? And, do we now the physical address in the end?

