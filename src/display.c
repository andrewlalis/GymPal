#include "display.h"

struct signal cs = { .ddr = &DDRB, .port = &PORTB, .pin = 2 };
// Back Light
struct signal bl = { .ddr = &DDRB, .port = &PORTB, .pin = 1 };
// Data / Command
struct signal dc = { .ddr = &DDRB, .port = &PORTB, .pin = 0 };
// Reset
struct signal rs = { .ddr = &DDRD, .port = &PORTD, .pin = 7 };
// LCD struct
struct st7735 lcd = { .cs = &cs, .bl = &bl, .dc = &dc, .rs = &rs };

void display_init() {
  ST7735_Init(&lcd);

  // Set the display as vertical (top is the wired side).
  ST7735_CommandSend(&lcd, MADCTL);
  ST7735_Data8BitsSend(&lcd, 0x00);

  ST7735_ClearScreen(&lcd, WHITE);
  ST7735_SetPosition(1, 1);
  ST7735_DrawString(&lcd, "Gympal", BLACK, X1);
}

struct st7735* display_get_lcd() {
  return &lcd;
}

void display_show_str(char* str) {
  ST7735_ClearScreen(&lcd, BLACK);
  ST7735_SetPosition(5, 10);
  ST7735_DrawString(&lcd, str, WHITE, X1);
}