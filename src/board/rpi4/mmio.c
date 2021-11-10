#include "mmio.h"

uint32_t mmio_read(uint32_t reg) { return *((volatile uint32_t*)MMIO_BASE + reg); }

void mmio_write(uint32_t reg, uint32_t data)
{
    *((volatile uint32_t*)MMIO_BASE + reg) = data;
}

void delay(int32_t count)
{
    asm volatile("__delay_%=: subs %[count], %[count], #1; bne __delay_%=\n"
                 : "=r"(count)
                 : [count] "0"(count)
                 : "cc");
}

volatile uint32_t mailbox[36] = { 9 * 4, 0, 0x38002, 12, 8, 2, 3000000, 0, 0 };
