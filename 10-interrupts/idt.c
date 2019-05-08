#include "idt.h"
#include "vga.h"

extern void idt_handler();
// extern u64 idt;
extern void flush_idt(u64);
void flush_wrapper(u64);

idt_entry_t idt[IDT_ENTRIES];
idt_ptr_t idt_ptr;

void init_idt() {
    vga_print(COLORCODE_Y_ON_B, "\ninitializing idt");

    idt_ptr.limit = sizeof(idt_entry_t) * IDT_ENTRIES - 1;
    idt_ptr.base = (u64)&idt;

    memory_set((u8 *)&idt, 0, sizeof(idt_entry_t)*IDT_ENTRIES);
    
    for(int i=0; i<IDT_ENTRIES; i++) {
        idt_set_entry(i, (u64)idt_handler, CODE_SEL, (FLAG_P|FLAG_R0|FLAG_INTERRUPT));
    }
    // this mf was missing!!!
    // this is wrong, a pointer to the idtr is required
    flush_wrapper((u64)&idt_ptr);
}

void flush_wrapper(u64 a) {
    flush_idt(a);
}



static void idt_set_entry(u8 num, u64 target, u16 selector, u8 flags) {
    // idt_entry_t *idt_entries = idt;
    // idt_entry_t *idt = idt;
    // idt_entry_t *idt =  (idt_entry_t *)0x100720; # manually hack the address
    
    // vga_print(COLORCODE_Y_ON_B, "\nset target. Start.");
    idt[num].target_low = 0x00;
    // vga_print(COLORCODE_Y_ON_B, "\nset target. Start.");
    idt[num].target_low = (u16) (target & 0xFFFF);
    idt[num].target_low_2 = (u16)((target >> 16) & 0xFFFF);
    idt[num].target_high = (u32)((target >> 32) & 0xFFFFFFFF);

    // vga_print(COLORCODE_Y_ON_B, "\nset target. Done.");
    idt[num].ist = 0x00;
    idt[num].selector = selector;
    idt[num].flags = flags;
    idt[num].reserved = 0x00;

}

void memory_set(u8* s, u8 c, u64 n) {
    for(; n!=0; n--) {
        *s = c;
        s++; 
    }
}
