#include "vga.h"

int* VIDEO_ADDRESS = (int*) 0xb8000;

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
    // *page_fault = 42;
    
    // loop forever
    while (1) {
    }

    return;
}
