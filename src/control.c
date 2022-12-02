#include "control.h"

volatile uint8_t CTL_INPUT_FLAGS = 0;

uint8_t readPin(uint8_t inputRegister, uint8_t inputPin) {
    return (inputRegister & (1 << inputPin)) >> inputPin;
}

ISR(PCINT2_vect) {
    cli();
    uint8_t rotDt = readPin(PIND, CTL_ROTARY_ENCODER_DT_IN);
    uint8_t rotClk = readPin(PIND, CTL_ROTARY_ENCODER_CLK_IN);
    uint8_t buttonA = readPin(PIND, CTL_BUTTON_A_IN);
    uint8_t buttonB = readPin(PIND, CTL_BUTTON_B_IN);
    uint8_t buttonC = readPin(PIND, CTL_BUTTON_C_IN);
    CTL_INPUT_FLAGS = (
        (rotDt << CTL_ROTARY_ENCODER_DT_FLAG) |
        (rotClk << CTL_ROTARY_ENCODER_CLK_FLAG) |
        (buttonA << CTL_BUTTON_A_FLAG) |
        (buttonB << CTL_BUTTON_B_FLAG) |
        (buttonC << CTL_BUTTON_C_FLAG)
    );
    sei();
}

void ctl_init() {
    // Set all control pins as input (0).
    DDRD &= ~(
        (1 << CTL_ROTARY_ENCODER_DT) |
        (1 << CTL_ROTARY_ENCODER_CLK) |
        (1 << CTL_BUTTON_A) |
        (1 << CTL_BUTTON_B) |
        (1 << CTL_BUTTON_C)
    );
    // Set up interrupts for handling control pin state changes.
    // Luckily, all interrupts happen on PCINT[16..23] so we only need one interrupt to handle them all.
    PCICR |= 1 << PCIE2; // Enable PCINT2_vector interrupts.
    PCMSK2 |= (// Enable the flag for each input we want to cause interrupts on state change.
        (1 << CTL_ROTARY_ENCODER_DT_INT) |
        (1 << CTL_ROTARY_ENCODER_CLK_INT) |
        (1 << CTL_BUTTON_A_INT) |
        (1 << CTL_BUTTON_B_INT) |
        (1 << CTL_BUTTON_C_INT)
    );
    // Enable the global interrupt flag.
    sei();
}