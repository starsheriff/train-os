#include "vga.h"

// handle_interrupt prints a generic message to the screen and does not return.
void handle_interrupt() {
    // print red on black
    char color_code = vga_color_code(VGA_COLOR_RED, VGA_COLOR_BLACK);
    vga_print(color_code, "\nInterrupt handled!");

    while(1) {};
}
