#include "idt.h"

extern void idt_handler();

volatile idt_entry_t idt_entries[IDT_ENTRIES];

void init_idt() {
    for(int i=0; i<IDT_ENTRIES; i++) {
        idt_set_entry(i, (u64)idt_handler, 0x08, (FLAG_P|FLAG_R0|FLAG_INTERRUPT));
    }
}

void idt_set_entry(u8 num, u64 target, u16 selector, u8 flags) {
    idt_entries[num].target_low = (u16) (target & 0xFFFF);
    idt_entries[num].target_low_2 = (u16)((target & 0xFFFF0000) >> 16 );
    idt_entries[num].target_high = (u32)(target >> 32);

    idt_entries[num].ist = 0x00;
    idt_entries[num].selector = selector;
    idt_entries[num].flags = flags;
    idt_entries[num].reserved = 0x00;
}



