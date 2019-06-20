# Interrupts
In this section, we are going add facilities to our kernel to handle interrupts and
exceptions. Adding these capabilities early on is important I think, because it will
allow us to debug our kernel much easier. 

## Disclaimer
Don't be put off if this section turns out to be quite hard. The first time I was
actually implementing this part took me around eight to ten hours, just for this small
section here. most of the time was spent browsing the programmers manual and trying
to debug. Basically, the kernel was causing triple faults all the time and I spent
most of the time using bochs and gdb to debug the cause.

Step by step you solve the puzzle and get things together. The hard part is that you
won't be able to confirm your progress until the end, because the kernel won't run
until each and every detail is in place.

This is hard and tedious, but also incredibly rewarding.

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
    // The declaration itself does not cause a page fault yet. We are not trying to
    // read or write the memory yet.
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

This is *our goal* for this session. Make our kernel print an (generic) error message
instead of entering a reboot loop.

# Interrupt Basics
To do that, we have to utilize the cpus interrupts. Again, I will approach the problem
from the ground up, deriving and assemblying everything from proper sources. Btw. maybe
this is a first peek into _why_ I am doing this. Most of the obvious tutorials that are
available online actually don't cover this. Those that explain interrupts usually stay
in 32-bit protected mode.

Let's pull out the _AMD Programmer's Manual Vol. 2_ again. The relevant sections are 1.6
2.6, 4.6.5, 4.8.4 and the whole section 8. A lot of material.

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

Section 2.6 describes interrupts and exceptions. Already in the first paragraph we are
made aware of that the mechanism for interrupts is different in long-mode than in 32-bit
protected mode. This means it might be that other tutorials, using the 32-bit mode, will
not work. So, we are on our own; unless you have a tutorial that works with long-mode.

## First Overview - Summary
From a first read, I get the following points:

1. We need to set up the _interrupt decriptor table_ `IDT`. This `IDT` must contain
   64-bit entries. These entries are called either _trap-gate-_ or _interrupt-gate
   descriptors_. There is a third option, called _task gates_ which we cannot use
   in long-mode. See section 2.6.1 [1].
2. To _use_ the `IDT` we need an _interrupt descriptor table register_ (IDTR), which
   is identical to the `GDTR` we already set up in an earlier section.
3. I don't think we need a _local descriptor table_ `LDT`. We use exclusively the `GDT`.
4. To _handle_ the interrupts correctly we have to consider how and when the cpu pushes
   to the stack. It looks like there are important differences between protected and long
   mode. This however, will be dealt with in the next section.

* filter required from optional things

* _CPL (Current Priviledge Level)_

Wow, this looks like a bumpy ride ahead. 

## Generic Interrupt Handler
The first thing we do is to create a generic _non-returning_ interrupt handler. It will
simply print the string "Interrupt handled!" to the screen, we have achieved the goal of
this section. 

```c
//interrupt.c
#include "vga.h"

// handle_interrupt prints a generic message to the screen and does not return.
void handle_interrupt() {
    // print red on black
    char color_code = vga_color_code(VGA_COLOR_RED, VGA_COLOR_BLACK);
    vga_print(color_code, "\nInterrupt handled!");

    while(1) {};
}
```

Now, we have to tell the cpu to call this function whenever _any_ interrupt or exception
occurs. Once we have achieved that, we can refine the interrupt handler.

## IDT (reserve space)
Then, we reserve space for the IDT without initializing it. Why we do that will become
clear in a minute. Section 4.6.5 and 8.2 contain all we need to know for the moment to reserve
the required space for the IDT.

> In long mode, interrupt descriptor-table entries are 16 bytes. [p. 79]

> Up to 256 unique interrupt vectors are available. [p. 216]

With this information we can reserve the required space for the _idt_. In `idt.asm`, we
declare a new `.data` section.
```assembly
; file: idt.asm

section .data:
; not sure about the alignment. To be sure, I will page align the idt for now.
align 4096

; the number of available interrupts, i.e. the number of entries in the idt
; ref section 8.2 p. 216 in AMD's programmers manual
IDT_NUM_ENTRIES equ 256

; the size of a single entry in the idt, in _long mode_, is 16 bytes.
; ref section 4.6.5 p. 79 in AMD's programmers manual
IDT_ENTRY_SIZE equ 16

; total size in bytes required for the idt
IDT_TOTAL_SIZE equ IDT_NUM_ENTRIES*IDT_ENTRY_SIZE

idt:
    resb IDT_TOTAL_SIZE
```

We have to put the table in the data section since we initialize the entries with `0`
at the moment. I am not sure if this is correct. If it turns out it is not, I will come
back to this. Currently however, this is the best I can do.

The kernel should still run. As long as you comment the line that tries to access our
unmapped memory in `c_start`.

## IDTR
Now we can look at the `IDTR`. The `IDTR` (_interrupt descriptor table register_)  tells
the cpu where to find the IDT and how large the table is. 
Basically, the _IDTR_ is not a complicated thing. It simply is a standardised data
structure that allows the cpu to read relevant information with only using one register.
The _IDTR_ contains two _fields_, the _base address_ where the IDT can be found and
second the _limit_ as it is called in the programmers manual; the number of entries in
the IDT. Section 4.6.6 explains the register and Figure 4-8 specifies the format of the
fields. It is identical to the _global descriptor table register_ that we have set up
already earlier.

```assembly
; file: idt.asm
global idtr

idtr:
    dw $ - idt - 1  ; two bytes (word), declaring the size of the IDT in bytes
    dq idt          ; 64-bit (double quad word) base address of the idt
```

Now we have to set the IDTR.
```assembly
; file: boot.asm
extern idtr

lidt [idtr]
```

Now, both the space for the _idt_ is reserved, and the _idtr_ is set. The cpu now "knows"
where to find the correct interrupt handler, or more precise the gate descriptor for any
of the possible 256 interrupts.

We have not yet initialized the idt yet. This is the next thing to do.

## IDT Entries aka gate descriptors
So far so good. Until now, I haven't encountered larger problems. This section though
required a fair bit of debugging to get everything together properly. Also, the AMD
programmer's manual was not easy to read. You have to follow a lot of references to get
everything together.

### Why not statically initialized?
First off, why don't we simply initialize the idt in a data section statically? In
principle we _could_ do that, but then our kernel would lack a crucial feature: changing
interrupt handlers at runtime. The kernel _must_ be able to change the interrupt handlers.
Therefore, we have to intitialize the idt at runtime.

### Initialize IDT
In the routine `longstart`, we call a new routine `init_idt` which we put in the file
`idt.asm`.

```assembly
; file: boot.asm
extern init_idt

; in longstart
call init_idt
```

In the `init_idt` routine, we have to set the entries of the idt properly. For now, we
will _always_ call the same routine to handle the interrupt to keep things easy. There
is enough to get going and we can easily extend our code afterwards. For now, the goal is
simply to get the idt entries correctly set.

## IDT entry layout
First some terminology. In the programmers manual, an entry in the idt is called a _gate
descriptor_. The term is used as a generic name for all types of entries in the different
_descriptor tables_. There are _many_ types of gate descriptors. Table 4-6 in section 4.8.3
gives an overview, although it is probably hard to understand at first.

From section 4.6.5, we know that the size of a single entry in _long mode_ is _always_
16 bytes. Otherwise, there is not much to learn from that section for now. Instead, we
can jump to section 4.8.4 _"Gate Descriptors"_. There, we get all the information we
need to set the entries.

First, we find that the _type_ of gate descriptor, a _64-bit interrupt gate_, is of type
`0x0E`. We need put this byte at the correct location in each entry. The full bit layout
is shown in figure 4-24.

Unfortunately the individual fields are not explained in huge detail, so we have to
collect the information on what to use for the individual fields from other sections.

### Scaffolding
Before we set the individual fields, we have to write some scaffolding around to write
all entries of the idt. The way I will do it here is to initialize the whole idt in a
single pass over the memory.

We need a pointer to the start of the idt. Then we will advance the pointer after we set
each field and compare it to the address of the end of the `idt` (which is the address of
the `idtr`.)

```assembly
; file: idt.asm

init_idt:
    ; eax is used to store the current location in memory and is advanced until the
    ; end of the idt is reached
    mov eax, idt
    
.init_single_entry:
    ; TODO: set idt entries and advance eax register
    ; for now, just advance by two bytes to not get stalled here
    add eax, 2 ; advance to not get stalled

    ; compare the current memory address with the end of the idt. If the address is
    ; lower than the end, jump back and initialize another idt entry
    cmp eax, idtr
    jl .init_single_entry
    
    ret
```

Let us walk through all the fields in their order of appearance.

### Target Offset [0:15]
The first 16 bits are the _lower_ 16 bits of the target address. The target address is
the address of our interrupt handler routine. As already explained above, for now we will
use the same address, aka. same handler for all interrupts.

To copy the _lower_ 16 bits of the idt handlers address, we can use `mov word`.

```assembly
    mov word [eax], idt_handler
```







## Old text from here:

If we enable intterupts now with `sti` it should work, but we get reboots. So something
is not right. If we disable interrupts with `cli` right after, we can boot again. This
is because we haven't set the IDT entries properly yet.

Now, that we have set the IDTR, the CPU knows where to look for the interrupt descriptors.
The memory we have reserved for the IDT is still empty though. That's what I will do next,
figure out how these entries have to look like.

The kernel should still run. As long as you comment the line that tries to access our
unmapped memory in `c_start`.

### IDT Entries (Initialize IDT)
Now we have to go back to section 4.6.5

> The IDT can contain only the following types of gate descriptors:

Note the term _gate descriptors_. We will not find any section in the document called
_IDT entries_ or something similar. Instead, we have to jump to section 4.8.4 _Gate
Descriptors_ in long-mode. This tells us what to do.



### Outline
* entries
* common handler


### Questions
* Assembly vs. C
* Two stacks? One stack?
* What to put in the GDT?
* Stack Switch?
* `rsp` vs `esp`?
* should the IDT be in a mapped page or should we reserve the bytes in assembly? Do we
  know exactly what's happening? And, do we now the physical address in the end?


* debugging with gdb
* debugging with bochs (interrupt)
* add example errors
* next step: make interrupt handler change a memory address or register --> bad
  --> therefore context switching required!
