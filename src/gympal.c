#include <avr/io.h>
#include <util/delay.h>

#include "control.h"

int main() {
    ctl_init();
    // Just for testing the interrupts, we're setting up B4 as an indicator LED.
    DDRB |= 1 << PORTB4;
    PORTB &= ~(1 << PORTB4);
    uint8_t led = 0;
    while(1) {
        uint8_t v = (CTL_INPUT_FLAGS & (1 << CTL_BUTTON_B_FLAG)) >> CTL_BUTTON_A_FLAG;
        if (led != v) {
            led = v;
            if (led) {
                PORTB |= 1 << PORTB4;
            } else {
                PORTB &= ~(1 << PORTB4);
            }
        }
    }
    return 0;
}