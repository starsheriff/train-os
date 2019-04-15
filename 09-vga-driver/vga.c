#include "vga.h"

/* VGA color definitions */
char VGA_COLOR_BLACK       = 0x0;
char VGA_COLOR_BLUE        = 0x1;
char VGA_COLOR_GREEN       = 0x2;
char VGA_COLOR_CYAN        = 0x3;
char VGA_COLOR_RED         = 0x4;
char VGA_COLOR_MAGENTA     = 0x5;
char VGA_COLOR_BROWN       = 0x6;
char VGA_COLOR_LIGHT_GRAY  = 0x7;
char VGA_COLOR_DARK_GRAY   = 0x8;
char VGA_COLOR_LIGHT_BLUE  = 0x9;
char VGA_COLOR_LIGHT_GREEN = 0xa;
char VGA_COLOR_LIGHT_CYAN  = 0xb;
char VGA_COLOR_LIGHT_RED   = 0xc;
char VGA_COLOR_PINK        = 0xd;
char VGA_COLOR_YELLOW      = 0xe;
char VGA_COLOR_WHITE       = 0xf;

/* Rows and columns of the vga display 
 */
const int VGA_COLUMNS = 80;
const int VGA_ROWS    = 25;



VGABuffer vga_buf = {
    0,
    (ColoredChar*) 0xb8000,
};

VGABuffer* vga_init() {
    return &vga_buf;
}

/* Returns the color code given a foreground and background color.
 *
 * A color code in VGA mode is defined by a single byte where the higher bits set the
 * background color and the lower bits set the foreground color.
 */
char vga_color_code(char fg, char bg) {
    return (bg << 4) | fg;
}

void vga_print(VGABuffer* b, char color_code, char* symbols) {
}

void vga_print_char(VGABuffer* b, char color_code, char symbol ) {
    // switch(symbol) {
    //     case '\n':
    //         vga_new_line(b);
    //         break;
    //     default:
    //         break;
    // }

    
    if(symbol == '\n') {
        // vga_new_line(b);
        vga_new_line(b);
        return;
    }

    if(b->col >= VGA_COLUMNS) {
        vga_new_line(b);
    }

    int row = VGA_ROWS - 1;
    int col = b->col;

    ColoredChar c = {
        symbol,
        color_code,
    };
    b->buf[(row*VGA_COLUMNS) + col] = c;

    b->col += 1;

    return;
}

void vga_new_line(VGABuffer* b) {
    return;
}
