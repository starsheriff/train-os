# Stack

In the previous section, we have successfully compiled a `C` function and called that
function from our assembly code. If we disassemble the object file generated from our
`c` code we find something interesting.

```bash
$ objdump -d build/start.o

build/start.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <c_start>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	c7 45 fc 4f 0e 4b 0e 	movl   $0xe4b0e4f,-0x4(%rbp)
   b:	48 8b 05 00 00 00 00 	mov    0x0(%rip),%rax        # 12 <c_start+0x12>
  12:	8b 55 fc             	mov    -0x4(%rbp),%edx
  15:	89 10                	mov    %edx,(%rax)
  17:	eb fe                	jmp    17 <c_start+0x17>
```

The first statement is a `push`, which we haven't used actively when we wrote our assembly
code. The second statemend moves `rbp` to `rsp`. We haven' used these registers either.

Both things are related to the `stack` which we havent' thought about yet.

TODO:
* usually the explanation is that we have to set up the stack, but I think that is a
  wrong way to explain it


# (Extremely simple stack)
A very simple way to set up a stack is to simply reserve some bytes at the end of our
assembly file. Similar to how we reserved bytes for the page tables.

```assembly
; boot.asm


section .bss
; reserve one memory frame for the stack
stack_bottom:
    resb 4096
stack_top:
```
The labels `stack_top` and `stack_bottom` are required set the registers for the stack
correctly.

To use this memory frame, we have to tell the CPU to use it. This is done by setting
the stack pointer to the _top_ of the stack.

```assembly
    mov esp, stack_top
```
Now, we want to set up the stack correctly _as soon as possible_. The reason is that if
we change the stack pointer _after_ anything has been put on the stack, we will loose
that data and corrupt our memory. Therefore, we put it at the very beginning of 
`boot.asm`, right after the `start` label.

