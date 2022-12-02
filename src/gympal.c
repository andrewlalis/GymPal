#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

volatile uint8_t a = 0;

void updatePin12(uint8_t status) {
    PORTB = status << PORTB4;
}

ISR(PCINT2_vect) {
    uint8_t value = (PIND & (1 << PIND5)) >> PIND5;
    PORTB = value << PORTB4;
}

int main() {
    PCICR |= 1 << PCIE2;
    PCMSK2 |= 1 << PCINT21;
    sei();
    // Pin 12 == Port B4, aka 4th bit on the B register.
    // Set pin 12 as output.
    DDRB |= 1 << PORTB4;
    // Set pin 5 as input.
    DDRD &= ~(1 << PORTD5);
    PORTB &= ~(1 << PORTB4);
    while (1) {
        // updatePin12(ledOn);
        // ledOn = !ledOn;
        // _delay_ms(1000.0);
        // DO NOTHING! rely on interrupt.
    }
    return 0;
}