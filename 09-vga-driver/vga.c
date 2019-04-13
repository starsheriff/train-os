

/* VGA color definitions */
char COLOR_BLACK       = 0x0;
char COLOR_BLUE        = 0x1;
char COLOR_GREEN       = 0x2;
char COLOR_CYAN        = 0x3;
char COLOR_RED         = 0x4;
char COLOR_MAGENTA     = 0x5;
char COLOR_BROWN       = 0x6;
char COLOR_LIGHT_GRAY  = 0x7;
char COLOR_DARK_GRAY   = 0x8;
char COLOR_LIGHT_BLUE  = 0x9;
char COLOR_LIGHT_GREEN = 0xa;
char COLOR_LIGHT_CYAN  = 0xb;
char COLOR_LIGHT_RED   = 0xc;
char COLOR_PINK        = 0xd;
char COLOR_YELLOW      = 0xe;
char COLOR_WHITE       = 0xf;


// Returns the color code given a foreground and background color.
char COLOR_CODE(char fg, char bg) {
    return (bg << 4) | fg;
}
