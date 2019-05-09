#include "vga.h"

extern void disable_interrupts();
extern void trigger_interrupt();

void c_start() {
    char color_code = vga_color_code(VGA_COLOR_YELLOW, VGA_COLOR_BLACK); 
    vga_print(color_code, "\nDon't panic!");

    // declare a pointer to a byte just outside the memory we have mapped with our two
    // 2 MiB pages. The last address we can access is 0x3f ffff.
    // 
    // The declaration does not cause a page fault yet. We are not trying to access the
    // memory yet.
    // 
    //                          0x--||||
    char *page_fault = (char *) 0x400000;

    // Assigning a value to the memory address causes a page fault.
    // *page_fault = 42;

    disable_interrupts();
    vga_print(color_code, "\nNow we trigger an interrupt!");
    trigger_interrupt();
    
    // loop forever
    while (1) {
    }

    return;
}

void print_interrupt() {
    char color_code = vga_color_code(VGA_COLOR_RED, VGA_COLOR_BLACK); 
    vga_print(color_code, "\n\nInterrupt!");

    while (1) {};
}
