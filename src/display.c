#include "display.h"

struct st7735 lcd;

void display_init() {
  ST7735_Init (&display_lcd);
  ST7735_CommandSend (&display_lcd, MADCTL);
  ST7735_Data8BitsSend (&display_lcd, 0x00);
  ST7735_ClearScreen (&display_lcd, BLACK);
  ST7735_SetPosition (5, 10);
  ST7735_DrawString (&display_lcd, "Testing", WHITE, X1);
}

void display_show_str(char* str) {
  ST7735_ClearScreen(&display_lcd, BLACK);
  ST7735_SetPosition(5, 10);
  ST7735_DrawString(&display_lcd, str, WHITE, X1);
}