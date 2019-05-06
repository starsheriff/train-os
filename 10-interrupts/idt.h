#ifndef idt_h_INCLUDED
#define idt_h_INCLUDED

typedef unsigned short u16;
typedef unsigned int   u32;
typedef unsigned long  u64;
typedef char u8;

#define  IDT_ENTRIES 32

#define CODE_SEL_64 0x08
#define FLAG_INTERRUPT  0xe
#define FLAG_R0     (0 << 5)    // Rings 0 - 3
#define FLAG_P      (1 << 7)

// The layout of an IDT entry is described in section 4.8.4, figure 4.24.
struct idt_entry_struct {
    // the lower 16 bits of the target address
    u16 target_low;
    // kernel segment selector
    u16 selector;
    // IST and ignored
    u8 ist; 
    // type and flags
    u8 flags;
    // uper 16 bits of the lower 32 bits
    u16 target_low_2;
    // upper 32 bits
    u32 target_high;
    // reserved
    u32 reserved;
} __attribute__((packed));

typedef struct idt_entry_struct idt_entry_t;

void idt_set_entry(u8 num, u64 target, u16 selector, u8 flags);

#endif // idt_h_INCLUDED
