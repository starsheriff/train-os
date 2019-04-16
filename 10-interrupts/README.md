# Interrupts

# Motivation
TODO: cause a page fault

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

If we now try to start our kernel with qemu, it will go in a reboot loop. This is typical
for a page fault. The question is, can we do better? Soon, we will have to implement a
better version of our memory mapping code. This will, potentially, lead to page faults
if we are not careful. Therefore, it would be extremely helpful to be able to print debug
messages in case the cpu encounters an error.

In the previous example it would have been nice if, instead of endlessly rebooting, we
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
available online actually don't cover this. Those that explain interrupts stay in 32-bit
protected mode.

Let's pull out the _Programmer's Manual_ again. Section 2.6 describes interrupts and
exceptions. Already in the first paragraph we are made aware of that the mechanism for
interrupts is different in long-mode than in 32-bit protected mode. This means it might
be that other tutorials, using the 32-bit mode, will not work. So, we are on our own;
unless you have a tutorial that works with long-mode.

## First Overview
From a first read, I get the following points:

1. We need an `IDT`, and this `IDT` must contain 64-bit entries.
2. 


_CPL (Current Priviledge Level)_



Wow, this looks like a bumpy ride ahead. 




### Questions

* Assembly vs. C
* Two stacks? One stack?
* What to put in the GDT?
* Stack Switch?
* `rsp` vs `esp`?

