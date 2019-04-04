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
dd 0xe85250d6
```
