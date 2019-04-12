# Disclaimer
This text is still in alpha stage, it is a _write along_ while I develop the code for
`train-os`. It is not vettet, will have logical gaps, changes in style etc. etc.

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
or eax, (1 << 5)
mov cr4, eax
```

# What did we just do?
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
We have heard about virtual and physical addresses the first time now and will have to
deal with them for the next step. Paging itself is not a difficult _concept_, but the
implementation is actually quite intricate.

Here are a few points that I missed when reading the first time about paging which I
try to address. 

* It is an essential part of the chips architecture. It is not something we are free to
  design/chose in software. The chip _will_ to the translation from a virtual address
  to the physical address no matter what.
* TODO: more points
* Once we activate long mode, every memory address we give the CPU _will_ inevitable be
  processed according to this paging mechanism. There is nothing we can do about. It
  is a _core_ component of the cpu.
* This means _every_ address we use in our code is treated as a virtual address by the
  cpu.
* As a consequence, the mapping of the page tables and also their entries must be set
  properly.
* If the cpu in this process encounters an error, that is it cannot parse the address
  he was using to load either another page table or read the page table entry, it will
  cause an interrupt, the famous _page fault_.

I really had to do a few passes to understand paging and get my head properly around it.
It was also very helpful to use several different sources, usually they complement each
other and fill each others gaps.

The plan for the following steps is:

1. Read about paging in the following sources:
	a) Programmers Manual
	b) Operating Systems Three Easy Pieces
2. Implement a simple page table
	a) Without dynamically mapping pages
	b) only one 2 MiB page mapped at start
	
## Paging Primer
TODO: explain essentials of the paging mechanism
TODO: maybe drop and refer to resources instead?

* 4 levels
* page table
* offset and indexing
* page tables are _tree structures_!

## The Plan (A very simple page table setup)
Given that we won't take a full dive into page tables yet we implement a simple page
table configuration.

TODO: explain


## Identity Map Page Tables
The next step is to set the `cr3` register with the _physical_ base address of a level
4 page table. To do that, we have to understand page tables a little bit. I want to go
into it in more detail later. For now, lets try to find the easiest possible
implementation.

The paging mechanism is explained in the programmers manual in section 5. The explanation
is actually quite good, but don't get grustrated if you don't get it right away. There
is a lot to grasp and many implementaitons are possible.

Table 5.1 gives a good overview and helps us to narrow down our choices. First, we want
to enable long mode, so only the top row is relevant (we already enabled `cr4.pae`).
Then, given that we want to have a simple solution a 2 MiB physical page size seems to
be okish.

Why? I guess it is not really obvious unless you already know what we are aiming for. To
be honest I don't know how to roll this part here without using some knowledge or plan.

1. A _simple_ solution will avoid that we have to map several pages, so we would like to
  have a decent amount of memory available. This will allow us to hard-wire things in
  assembly without too much hassle. We could maybe live with 4 KiB, but 2 MiB seems to
  be safer.
2. We will remap, i.e. implement the paging mechanism, for our kernel later in a much
  more sophisticated way. So 1 GiB is definitely not required.

### Enable 2 MiB Physical Page Size
From table 5.1 we know that we have to set `PDE.PS=1` and `PDPE.PS=0` to enable 2 MiB
physical pages. Both flags are set using bit number 7 in the respective _page table
entries_. Note! `PDE` and `PDPE` are _NOT_ registers but, rather cumbersome names for
different levels of the page tables. `PDPE` is page table level 3 and `PDE` level 2.

So, we will have to set these bits correctly when we create our page table entries.

### Reserve Memory for Page Tables
Now, we will reserve the space/bytes for the page tables we need. In our simple
configuration where we only want to map _a single_ 2 MiB page we need to exactly one 
`P4`, `P3` and `P2` table each.

The `cr3` register will point to our single P4 table. Thus, we reserve some space for the
`P4`, `P3` and `P2` tables. Each of them requires 4 KiB and to be page aligned.

```assembly
section .bss
; must be page aligned
align 4096
p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
```

### Set `cr3` register
Now, we can set the `cr3` register to point to the `p4_label`. We can safely do that,
because paging is still disabled. We are still able to assemble our kernel and boot it.

```assembly
; Step 3: Set `cr3` register
mov eax, p4_table
mov cr3, eax
```

### Map Page Tables
Now, it is important to keep in mind what we want to achieve in the end. We want to be
able to map _a single_ 2 MiB page frame that where the virtual addresses are identity
mapped to the physical addresses. I.e. virtual and physical address are the same.

Mapping _a single_ page frame means we need exactly one _page table entry_ in the `p2`
table. That entry will point to the base address of the page frame we want to map.
This in turn means we need exactly one `p3` table with one page table entry  and 
a single page table entry in the `p4` table.

Let's further define that we want to map the first 2 MiB of the address space, i.e. the
first page frame. This means, after the mapping we will be able to use the addresses
`0x0000_0000_0000_0000` to `0x0000_0000_001F_FFFF`.
// TODO: describe in octal?

Then, we don't want to corrupt the currently mapped memory. Instead, let's use the
_second_ frame starting from 2 MiB for the page we map. The base address is then
`0x20_0000`. We have to set the correct bits of the page table entry though, bits `0` to
`7`. Figure 5.25 shows the format of the page table entry for `p2` or `PDE` in AMD 
nomenclature. The bits we have to set are `WRITABLE` and `PRESENT` and `LARGE`.

We define these bits as constants:

```assembly
; Flags for _large_ p2 aka. PDE page table entries
PDE_PRESENT  equ 1 << 0
PDE_WRITABLE equ 1 << 1
PDE_LARGE    equ 1 << 7
```

Then we can set the entry at index 1 in the p2 table in the following way:

```assembly
; Step 4: Set the p2[1] entry to point to the _second_ 2 MiB frame
mov eax, (0x20_0000 | PDE_PRESENT | PDE_WRITABLE | PDE_LARGE)
mov [p2_table + 8], eax
```

Now, we have set entry `p2[1]` entry to point to our 2 MiB frame. This means the addresses
`0x20_0000` to `0x3F_FFFF` (`0x20_0000 + 0x1F_FFFF = 0x3F_FFFF`) are mapped with the
`p2[1]` page table entry.

Now we have to set up the remaining mappings, i.e. the page table entries in `p4`
and `p3`. Since all bits higher bits in the addresses we want to map are zero, the
offsets into `p4` and `p3` are also zero. In other words, if we give the cpu an address
within the mapped range, e.g. `0x20_0010`, it will take the _0th_ entry in `p4`, load
`p3` from the base address stored in that page table entry, then load the _0th_ entry
of `p3` and load `p2` from the base address in that entry. 

Now, we can map all entries
```assembly
; Step 5: Set the 0th entry of p3 to point to our p2 table
mov eax, p2_table ; load the address of the p2 table
or eax, (PDE_PRESENT | PDE_WRITABLE)
mov [p3_table], eax

; Step 6: Set the 0th entry of p4 to point to our p3 table
mov eax, p3_table
or eax, (PDE_PRESENT | PDE_WRITABLE)
mov [p4_table], eax
```

Now all page tables are mapped. If we now give the cpu an address in the mapped area,
it will walk its way through the page tables, end at physical memory frame which includes
the given address and end at the physical address exactly matching the given virtual one.

TODO: explain why the lower bits are used as flags and why that is ingenious!

# Enable EFER.LME
The next step, according to section 14.6.1 of the programmes manual, is to enable the
long mode by setting `EFER.LME` to 1. But how?

Well, searching the manual actually reveals a code example how to set the flag properly

```assembly
; Step 7: Set EFER.LME to 1 to enable the long mode
mov ecx, 0xC0000080
rdmsr
or  eax, 1 << 8
wrmsr
```

# Enable Paging
Now we can enable paging again. The process is almost identical as before when we
disabled paging and should be well known now.

```assembly
; Step 8: enable paging
mov eax, cr0
or eax, 1 << 31
mov cr0, eax
```

If we run `make run` now, qemu still boots and prints the letters `OK`, so we are good?

# Are we in long mode yet?
The big question now is, are we in long mode yet. The long mode activation section in the
manual did not mention any more steps. First, we can still boot our kernel prints the
letters `OK`.

What happens, if we try to load an address that is not mapped in our page table?, e.g.
`0x40_0010` that is just a few bytes outside our mapped range. We can try to copy the
content of that address to `eax`.
```assembly

mov eax, [0x40_0010]
```

If the cpu uses the page table, we should get a page fault trying to access this address.
But we don't. Of course, something is missing.

# Surprise! We have to update the GDT
Ok, if we continue to read the software programmers manual, we find that section 14.6.2
talks about consistency checks, which I will ignore for now. The next section however is
interesting, 

> Immediately after activating long mode, the system-descriptor-table registers (GDTR,
> LDTR, IDTR, TR) continue to reference legacy descriptor tables.

Ok, but we wanted to use paging, and _not_ segmentation. So the GDT should not matter?!
In the same paragraph though:

> After activating long mode, 64-bit operating-system software should use the LGDT, LLDT,
> LIDT, and LTR instructions to load the system descriptor-table registers with
> references to the 64-bit versions of the descriptor tables. See “Descriptor Tables” on
> page 73 for details on descriptor tables in long mode.

Oh boy, there is even more

> Long mode requires 64-bit interrupt-gate descriptors to be stored in the
> interrupt-descriptor table (IDT). Software must not allow exceptions or interrupts to
> occur between the time long mode is activated and the subsequent update of the
> interrupt-descriptor-table register (IDTR) that establishes a reference to the 64-bit
> IDT. 

As far as I can see we have to perform three more steps:

1. Disable all interrupts
2. Update the GDT (we will have to look that up in the _Descriptor Tables_ section.
3. Enable interrupts

## Disable/Enable Interrupts
TODO:

## Update GDT
TODO: Explanation


# Conclusion
Whew, what a ride. The section turned out to be quite long.

## Achievement
Let's face it the code is not aesthetic at all yet. The big thing however is that we have
managed to put together each and every line from actual AMD sources; *no shortcuts*.
That is, at least for me, deeply satisfying.

Now, when time comes and I have to boot an architeture `x`, I feel much more prepared to
take on that ride. Also, it is much less puzzling now if you take code or tools from third
parties since you understand what they are doing under the hood. 

## Up Next
`C`, or stack?

What is next? The difficult thing is to keep an overview.

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
