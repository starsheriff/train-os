# Disclaimer
Read the general notes for this tutorial.

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

Let's start with the `C` file and call it `start.c`.


## Makefile
```
c_source_files := $(wildcard *.c)
c_object_files := $(patsubst %.c, $(build_dir)/%.o, $(c_source_files))


$(build_dir)/%.o: %.c
	@$(CC) $(CFLAGS) -c $< -o $@
```

