#include <avr/io.h>
#include <util/delay.h>

void updatePin12(uint8_t status) {
    PORTB = status << PORTB4;
}

int main() {
    // Pin 12 == Port B4, aka 4th bit on the B register.
    // Set pin 12 as output.
    DDRB = 1 << PORTB4;
    uint8_t ledOn = 1;
    while (1) {
        updatePin12(ledOn);
        ledOn = !ledOn;
        _delay_ms(1000.0);
    }
    return 0;
}