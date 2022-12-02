#include <avr/io.h>
#include <util/delay.h>

int main() {
    // Pin 12 == Port B4, aka 4th bit on the B register.
    // Set pin 12 as output.
    DDRB = 1 << PORTB4;
    // Set pin 12 as HIGH.
    PORTB = 1 << PORTB4;
    // Delay for 1 second.
    _delay_ms(1000.0);
    // Set pin 12 as LOW.
    PORTB = 0 << PORTB4;
    return 0;
}