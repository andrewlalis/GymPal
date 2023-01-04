/**
 * @file display.h
 * @author Andrew Lalis (andrewlalisofficial@gmail.com)
 * @brief A wrapper around the hardware driver for the Gympal display which
 * offers more abstract functions for controlling the state of the display.
 */
#ifndef DISPLAY_H
#define DISPLAY_H

#include "lib/st7735.h"

/**
 * @brief Initializes the display.
 */
void display_init();

/**
 * @brief Gets a pointer to the underlying ST7735 LCD struct, which can be used
 * for calling functions on it manually.
 * @return A pointer to the ST7735 LCD struct.
 */
struct st7735* display_get_lcd();

void display_show_str(char* str);

#endif