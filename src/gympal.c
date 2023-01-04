#include <avr/io.h>
#include <util/delay.h>

#include "control.h"
#include "display.h"

int main() {
    display_init();
    ctl_init();
    // while (1) {
    //   if (ctl_isButtonAPressed()) {
    //     display_show_str("button A");
    //   } else {
    //     display_show_str("Not button A");
    //   }
    // }
    return 0;
}