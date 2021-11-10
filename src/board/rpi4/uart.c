#include "uart.h"
#include "mmio.h"
#include <stddef.h>

void uart_init(void)
{
    mmio_write(UART0_CR, 0x00000000);

    mmio_write(GPPUD, 0x00000000);
    delay(150);

    mmio_write(GPPUDCLK0, (1 << 14) | (1 << 15));
    delay(150);

    mmio_write(GPPUDCLK0, 0x00000000);

    mmio_write(UART0_ICR, 0x7FF);

    volatile uint32_t r = (((volatile uint32_t)&mailbox & ~0xF) | 8);
    while (mmio_read(MBOX_STATUS) & 0x80000000)
        ;
    mmio_write(MBOX_WRITE, r);
    while ((mmio_read(MBOX_STATUS) & 0x40000000) || mmio_read(MBOX_READ) != r)
        ;

    mmio_write(UART0_IBRD, 1);
    mmio_write(UART0_FBRD, 40);

    mmio_write(UART0_LCRH, (1 << 4) | (1 << 5) | (1 << 6));
    mmio_write(UART0_IMSC,
        (1 << 1) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7) | (1 << 8) | (1 << 9)
            | (1 << 10));

    mmio_write(UART0_CR, (1 << 0) | (1 << 8) | (1 << 9));
}

void uart_putc(char c)
{
    while (mmio_read(UART0_FR) & (1 << 5))
        ;
    mmio_write(UART0_DR, (uint8_t)c);
}

char uart_getc(void)
{
    while (mmio_read(UART0_FR) & (1 << 4))
        ;
    return (char)mmio_read(UART0_DR);
}

void uart_puts(const char* str)
{
    while (*str) {
        if (*str == '\n')
            uart_putc('\r');
        uart_putc(*str++);
    }
}
