#include "uart.h"

volatile uint32_t* UART0 = (uint32_t*) 0x09000000;

void uart_init(void)
{
    // do nothing
}

void uart_putc(char c)
{
    *UART0 = c;
}

char uart_getc(void)
{
    return *UART0;
}

void uart_puts(const char* str)
{
    for (size_t i = 0; str[i] != '\0'; i ++)
        uart_putc(str[i]);
}
