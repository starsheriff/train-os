#include "vga.h"

int* VIDEO_ADDRESS = (int*) 0xb8000;

void c_start() {
    char color_code = vga_color_code(VGA_COLOR_YELLOW, VGA_COLOR_BLACK); 
    // vga_print_char(buf, color_code, 'O');
    // vga_print_char(buf, color_code, 'K');
    vga_print(color_code, "Don't panic!");
    vga_new_line();
    vga_print(color_code, "\nThe answer is 42.");
    
    // loop forever
    while (1) {
    }

    return;
}
