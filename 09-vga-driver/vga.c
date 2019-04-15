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

/* Returns the color code given a foreground and background color.
 *
 * A color code in VGA mode is defined by a single byte where the higher bits set the
 * background color and the lower bits set the foreground color.
 */
char vga_color_code(char fg, char bg) {
    return (bg << 4) | fg;
}

void vga_print(char color_code, char* symbols) {
    int i = 0;
    while(symbols[i] != 0) {
        vga_print_char(color_code, symbols[i++]);
    }
}

void vga_print_char(char color_code, char symbol ) {
    if(symbol == '\n') {
        // vga_new_line(b);
        vga_new_line();
        return;
    }

    if(vga_buf.col >= VGA_COLUMNS) {
        vga_new_line();
    }

    int row = VGA_ROWS - 1;
    int col = vga_buf.col;

    ColoredChar c = {
        symbol,
        color_code,
    };
    vga_buf.buf[(row*VGA_COLUMNS) + col] = c;

    vga_buf.col += 1;

    return;
}

void vga_new_line() {
    vga_buf.col = 0;

    // number of characters to copy
    int len = (VGA_ROWS-1)*VGA_COLUMNS;

    for(int i=0; i<len; i++) {
        vga_buf.buf[i] = vga_buf.buf[i+VGA_COLUMNS];
    }

    ColoredChar blank = {
        ' ',
        vga_color_code(VGA_COLOR_WHITE, VGA_COLOR_BLACK),
    };

    for(int i=0; i<VGA_COLUMNS; i++) {
        vga_buf.buf[(VGA_ROWS-1)*VGA_COLUMNS + i] = blank;
    }

    return;
}
