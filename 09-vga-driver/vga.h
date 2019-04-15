#ifndef vga_h_INCLUDED
#define vga_h_INCLUDED

/* VGA color definitions */
char VGA_COLOR_BLACK       ;
char VGA_COLOR_BLUE        ;
char VGA_COLOR_GREEN       ;
char VGA_COLOR_CYAN        ;
char VGA_COLOR_RED         ;
char VGA_COLOR_MAGENTA     ;
char VGA_COLOR_BROWN       ;
char VGA_COLOR_LIGHT_GRAY  ;
char VGA_COLOR_DARK_GRAY   ;
char VGA_COLOR_LIGHT_BLUE  ;
char VGA_COLOR_LIGHT_GREEN ;
char VGA_COLOR_LIGHT_CYAN  ;
char VGA_COLOR_LIGHT_RED   ;
char VGA_COLOR_PINK        ;
char VGA_COLOR_YELLOW      ;
char VGA_COLOR_WHITE       ;

/* Rows and columns of the vga display 
 */
const int VGA_COLUMNS;
const int VGA_ROWS;


typedef struct {
    char character;
    char color;
} ColoredChar;

typedef struct {
    int col;
    ColoredChar* buf;
} VGABuffer;

/* API for the VGA display */
char vga_color_code(char fg, char bg);
void vga_new_line(VGABuffer* b);
VGABuffer* vga_init();
void vga_print(VGABuffer* b, char color_code, char* symbols);
void vga_print_char(VGABuffer* b, char color_code, char symbol);

#endif // vga_h_INCLUDED

