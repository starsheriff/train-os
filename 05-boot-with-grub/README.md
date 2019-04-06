# Booting with GRUB
The goal for this session is to use GRUB as a bootloader to jumpstart the development
of the kernel. The previous sessions were helpful to learn what is happening during the
boot sequence and for me that is a great help to appreciate what a boot loader like
GRUB does for us.

So first of all, what does it do for us? Basically it provides a first layer of
abstraction from the underlying hardware to software, in that case for kernel developers.
Without generic boot loaders each and every os would have to implement its own boot loader
which is tedious and also would lead to a situation where the bootloaders are not able
to boot different operating systems. Dual-boot would not work.

Enter multiboot and multiboot2, two standards that were develop to address exactly that.
GRUB is both multiboot and multiboot2 compliant, exactly which version we're going to
use I don't know at the moment.

The standard can be found [here](http://nongnu.askapache.com/grub/phcoder/multiboot.pdf),
and I strongly recommend to read it. It is well written and gives more background
information.

> OS images should be easy to generate.  Ideally, an OS image should simply be an
> ordinary32-bit executable file in whatever file format the operating system normally
> uses. It shouldbe possible tonmor disassemble OS images just like normal executables.
> Specialized toolsshould not be required to create OS images in aspecialfile format. 

# The Plan
As already mentioned in the previous chapters. There are plenty of tutorials available
we could simply follow along. That's not what I want to do. I will document the _process_
of _figuring out_ what we have to do _from generic sources_.

I can recommend this approach since the learning experience is much better. At least for
me.

# The Multiboot Header
Section 1.6 of the multiboot specification states that:

> Multiboot-compliant  OS  images  always  contain  a  magic Multiboot
> header (seeSection  3.1  [OSimage  format],  page  5),  which  allows  the  boot
> loader  to  load  the  image  without  havingto  understand  numerous  a.out  variants
> or  other  executable  formats.

Furthermore,

> This  magic header does not need to be at the very beginning of the executable file,
> so kernel images can still conform to the local a.out format variant in addition to
> being Multiboot-compliant.

So, next step is to figure out _how_ this multiboot header should be constructed and
second where we have to put it or _how_ we have to link it so that the bootloader can
find it.

## Header Layout
Section [3.1.1](https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-layout)
of the multiboot specification describes the header layout we have to follow:

| Offset | Type | Field | Name | Note |
|--------|------|-------|------|------|
| 0 | `u32` | `magic` | required |
| 4 | `u32` | `architecture` | required |
| 8 | `u32` | `headerlength` | required |
| 12 | `u32` | `checksum` | required | 
| 16-XX | | `tags` | required |

That does not look too bad. Not overly complicated; actually that looks quite straight
forward. Also it looks like the header supports arbitrary `tags` and that the header
does not have a fixed size.

Sidenote: You might have noticed that the link to the multiboot specification posted
above and the link in this section are called multiboot and multiboot2 specification.
I still don't know the difference (if any), but we will figure that out along the way.

Let's create a new asm file called `multiboot_header.asm` and construct the required
fields. The first one is easy just add a 32-bit constant

```assembly
; multiboot_header.asm
dd 0xe85250d6
```

The second field has to be set to `0` indicating that we want to boot into 32-bit mode
on a i386 architecture; we cannot chose 64-bit yet, that is not supported by the
standard.

```assembly
; multiboot_header.asm
dd 0xe85250d6
dd 0
```

The third field requires that we add tags at the beginning and the end of the section
to calculate the length of the header. Hard coding the length would be a bad idea and
difficult to maintain. 

```assembly
; multiboot_header.asm
header_start:
	dd 0xe85250d6
	dd 0
	dd header_end - header_start
header_end:
```

The fourth part requires to calculate a checksum. The standard defines this as

> The field ‘checksum’ is a 32-bit unsigned value which, when added to the other 
> magic fields (i.e. ‘magic’, ‘architecture’ and ‘header_length’), must have a 32-bit
> unsigned sum of zero. 

```assembly
; multiboot_header.asm
header_start:
	dd 0xe85250d6
	dd 0
	dd header_end - header_start
	dd - (0xe85250d6 + 0 + (header_end - header_start))
header_end:
```

### Gotcha! We need _at least_ one header tag.
This was not obvious and I just discovered that by chance. Not sure how much pain it
that would have caused to find later on.

Section [3.1.3](https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html#Header-tags)
says that

> Tags are terminated by a tag of type ‘0’ and size ‘8’. 

This means we have to add one tag to our header file. I assume otherwise GRUB not be
able to find the end of the header.

So, we follow the spec and add the end header

```assembly
; multiboot_header.asm
dw 0 ; 16-bit, type `0`
dw 0 ; 16-bit, flags (assuming they should be zero)
dd 8 ; 32-bit, 8 (preceeded by two 4 byte fields)
```

That's it. I _think_ that the header is complete now.

# Something to Boot
Now we need a minimal "kernel" that we can actually try to boot. We have to be aware of
that GRUB will boot into the 32-bit protected mode. This means it is not possible to use
the BIOS functions anymore.

Instead, we now have the frame buffer available at our hands, which is nice. So, to give
us _some_ visual feedback that we did boot successfully, we just write a few bytes
directly to the vga memory, e.g. `OK`.

Let's create a new asm file called `boot.asm`, the only thing we do is to print the
two letters `OK` in yellow on black background.

*How do we do that?*
It seems like "everybody" just knows that writing bytes to the memory address `0xb8000`
prints ascii characters in a 80x25 grid on the screen. Well, _how_ can you find this from
specs? Who specs it? Which _part_ of the computer is responsible for it? The vendor or
is it part of the CPU architecture, i.e. x86_64? I have no idea.

Searching on the web, I found a wiki page on [osdev.org](https://wiki.osdev.org/Text_UI#Video_Memory),
but there are also no references to where you would find that information. However,
it explains the bits and their meaning a bit more.

From the osdev page, we learn that each character to print uses two bytes. One for the
color code and one for the ascii code to print. I give up to dig deeper on that one for
now and just use the information from the osdev page.

Now that we also "know" that we have to write to the memory area beginning at `0xb8000`
to print characters and that the byte `0x0e` prints the character in yellow on black
background and that the ascii codes for the characters 'O' and 'K' are `0x4f` and `0x4b`.
We can finally put together a simple assembly file. This file will then be linked with
the multiboot header and loaded by GRUB.

```assembly
; boot.asm

; The label start is our entry point. We have to make it
; public so that the linker can use it.
global start

section .text

; we are still in 32-bit protected mode so we have to use
; 32-bit wide instructions
bits 32

start:
    mov word [0xb8000], 0x0e4f ; 'O', yellow on black
    mov word [0xb8002], 0x0e4b ; 'K', yellow on black
    hlt
``` 

# Linking the kernel
TODO: linker script

# ELF? Entry Point
TODO: readelf tool and explain entry point

# Building a bootable image
TODO: grub process

# Automation (Makefile)

TODO: Summarize makefile

# Playing Around
Now, we can easily play around. Since we have automated the whole build, the dev cycle
is really fast; just run `make run` to start qemu with a freshly built image.

For me, since I don't have much experience with assembler I mainly changed the two lines
printing our two characters `OK`

```
mov word [0xb8000], 0x0e4f ; 'O', yellow on black
mov word [0xb8002], 0x0e4b ; 'K', yellow on black
```

What happens if you change the lines to the following? Explore, and try to understand.
I will leave you alone on that one.

```
mov dword [0xb8000], 0x0e4f
mov word [0xb8002], 0x0e4b
```

```
mov word [0xb8000], 0x0e4f
mov word [0xb8001], 0x0e4b
```

```
mov word [0xb8000], 0x0e4f
mov word [0xb8006], 0x0e4b
```

```
mov word [0xb8000], 0x0e4f
mov dword [0xb8002], 0x0e4b
```


# TODO
tool: readelf -> check the start address and entrypoint

linker script
grub commands
Automation -> Makefile
do we have a stack already? -> next
Why does C need a stack? -> next
How do we read memory information?
