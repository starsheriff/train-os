#include "idt.h"

extern void idt_handler();
extern idt_entry_t *idt;
// extern void flush_idt(idt_entry_t *idt);

// idt_entry_t idt[IDT_ENTRIES];

void init_idt() {
    for(int i=0; i<IDT_ENTRIES; i++) {
        idt_set_entry(i, (u64)idt_handler, CODE_SEL, (FLAG_P|FLAG_R0|FLAG_INTERRUPT));
    }
}

static void idt_set_entry(u8 num, u64 target, u16 selector, u8 flags) {
    // idt_entry_t *idt_entries = idt;
    
    idt[num].target_low = (u16) (target & 0xFFFF);
    idt[num].target_low_2 = (u16)((target >> 16) & 0xFFFF);
    idt[num].target_high = (u32)((target >> 32) & 0xFFFFFFFF);

    idt[num].ist = 0x00;
    idt[num].selector = selector;
    idt[num].flags = flags;
    idt[num].reserved = 0x00;

    // this mf was missing!!!
    // this is wrong, a pointer to the idtr is required
    // flush_idt(idt);
}
