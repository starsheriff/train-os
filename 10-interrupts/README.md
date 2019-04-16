# Interrupts

# Motivation
TODO: cause a page fault

```c
char *page_fault = (char *) 0x400000;

// Assigning a value to the memory address causes a page fault.
*page_fault = 42;
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

## Interrupt Basics
To do that, we have to utilize the cpus interrupts.

