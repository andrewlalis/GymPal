/*
This example showcases digital input and output using the AVR chip's GPIO
pins. For all pins, we first have to configure them as either input or output.
We do this by writing to the DDRx register (data direction register) either a 1
(for output) or 0 (for input).

We can set the output of a pin by writing to PORTx, using bitwise operators.

Reading can be done by reading from PINx, using bitwise operators.
*/
#include <avr/io.h>
#include <util/delay.h>

int main() {
    // Pin 12 == Port B4, aka 4th bit on the B register.
    // Set pin 12 as output.
    DDRB |= 1 << PORTB4;
    // Set pin 5 as input.
    DDRD &= ~(1 << PORTD5);
    // Write a 0 to pin 12 initially.
    PORTB &= ~(1 << PORTB4);
    uint8_t led = 0;
    while (1) {
        // Write current led status to pin 12.
        if (led) {
            PORTB |= 1 << PORTB4;
        } else {
            PORTB &= ~(1 << PORTB4);
        }
        led = !led;
        _delay_ms(1000.0);
        // Read input from pin 5. If it's HIGH, keep the LED on.
        uint8_t pin5Value = (PIND & (1 << PIND5)) >> PIND5;
        if (pin5Value) led = 1;
    }
    return 0;
}