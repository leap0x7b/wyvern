#include "uart.h"

volatile uint32_t* UART0 = (uint32_t*)0x09000000;

void uart_init(void) {}

void uart_putc(char c) { *UART0 = c; }

char uart_getc(void) { return *UART0; }

void uart_puts(const char* str)
{
    while (*str) {
        if (*str == '\n')
            uart_putc('\r');
        uart_putc(*str++);
    }
}
