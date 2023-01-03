#ifndef DISPLAY_H
#define DISPLAY_H

#include "st7735.h"

// A wrapper around the ST7735 library, which handles all of the gympal-specific display code.

// Internal IO definition needed by the st7735 library.
// Chip Select
struct signal cs = { .ddr = &DDRB, .port = &PORTB, .pin = 2 };
// Back Light
struct signal bl = { .ddr = &DDRB, .port = &PORTB, .pin = 1 };
// Data / Command
struct signal dc = { .ddr = &DDRB, .port = &PORTB, .pin = 0 };
// Reset
struct signal rs = { .ddr = &DDRD, .port = &PORTD, .pin = 7 };
// LCD struct
struct st7735 display_lcd = { .cs = &cs, .bl = &bl, .dc = &dc, .rs = &rs };

/**
 * @brief Initializes the display.
 */
void display_init();

void display_show_str(char* str);

#endif