# Disclaimer
Read the general notes for this tutorial.

## Prerequesits
* I don't assume any knowledge of x86 or os development
* I don't assume any knowledge or experience in systems development.
* I *do* assume knowledge of `C`, I will not cover the language itself. This is not a
  `C` tutorial.
* The other aspects I will cover in great detail.
* Everything from previous sections is assumed common knowledge now.

# Jumping into `C`
The goal for this section is to jump into `C` and print the letters `OK` from our `C`
code. Hopefully, this is a very short section.

First, we add another make target to build `C` files.  We basically have two options
now how we compile our `C` files.

Since we are developing a kernel for `x86_64` on a `x86_64` system, we could just use
the toolchain on our host system (minus the standard library). Alternatively, we can
go the full blown way and set up a cross-compilation toolchain for our target
architecture and system.

I will use the second approach and use the cross-compilation toolchain we set up earlier.

## The simplest C program
All we want to do now is to switch over from _assembly_ to `C` code. The goal is to move
the assembly code that prints `OK` to the screen into a `C` function and call that from
our assembly code.

Let's start with the `C` file and call it `start.c`. First, we need the base address of
the VGA buffer we use to write the characters. We copy it from assembly

```c
char* VIDEO_ADDRESS = (char *) 0xb8000;
```

Next, we add a function with return type `void`, since we will not return from it
(although we could). We could return, but we want to stay in `C` for our kernel. In this
function we write the first four bytes of the VGA register with the same values as
we did in the assembler code. You have to pay attention with the order of the bytes,
the endianness matters.

Last, we add an infinite loop.

```c
void c_start() {
    VIDEO_ADDRESS[0] = 0x4f;
    VIDEO_ADDRESS[1] = 0x0e;
    VIDEO_ADDRESS[2] = 0x4b;
    VIDEO_ADDRESS[3] = 0x0e;

    // loop forever
    while (1) {
    }
}
```
That is all the code we need for now. The next step is to build, link and pack everything
so that we get qemu to print _OK_ as before.

## Compilation
To compile `C` files, we use `gcc` from the cross-compilation toolchain we have build.
In that way we can't accidentally include files from the standard library on our host
system.
```
TARGET=x86_64-elf
CC=$(TARGET)-gcc
```

We also add another list using wildcards to automatically compile all `C` files.
```
c_source_files := $(wildcard *.c)
c_object_files := $(patsubst %.c, $(build_dir)/%.o, $(c_source_files))
```

Finally, we add a make target for `C` files.
```
$(build_dir)/%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
```

# Next
* inspect generated assembly code
* stack
