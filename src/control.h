#ifndef CONTROL_H
#define CONTROL_H

#include <avr/io.h>
#include <avr/interrupt.h>

#define CTL_ROTARY_ENCODER_DT PORTD2
#define CTL_ROTARY_ENCODER_DT_IN PIND2
#define CTL_ROTARY_ENCODER_DT_INT PCINT18
#define CTL_ROTARY_ENCODER_DT_FLAG 0

#define CTL_ROTARY_ENCODER_CLK PORTD3
#define CTL_ROTARY_ENCODER_CLK_IN PIND3
#define CTL_ROTARY_ENCODER_CLK_INT PCINT19
#define CTL_ROTARY_ENCODER_CLK_FLAG 1

#define CTL_BUTTON_A PORTD5
#define CTL_BUTTON_A_IN PIND5
#define CTL_BUTTON_A_INT PCINT21
#define CTL_BUTTON_A_FLAG 2

#define CTL_BUTTON_B PORTD6
#define CTL_BUTTON_B_IN PIND6
#define CTL_BUTTON_B_INT PCINT22
#define CTL_BUTTON_B_FLAG 3

#define CTL_BUTTON_C PORTD7
#define CTL_BUTTON_C_IN PIND7
#define CTL_BUTTON_C_INT PCINT23
#define CTL_BUTTON_C_FLAG 4

extern volatile uint8_t CTL_INPUT_FLAGS;

/**
 * @brief Initializes the user control inputs and interrupts.
 */
void ctl_init();

/**
 * @brief Determines if button A has been pressed.
 * @return uint8_t 1 if pressed, 0 otherwise.
 */
inline uint8_t ctl_isButtonAPressed() {
    return (CTL_INPUT_FLAGS & (1 << CTL_BUTTON_A_FLAG)) >> CTL_BUTTON_A_FLAG;
}

inline uint8_t ctl_isButtonBPressed() {
    return (CTL_INPUT_FLAGS & (1 << CTL_BUTTON_B_FLAG)) >> CTL_BUTTON_B_FLAG;
}

inline uint8_t ctl_isButtonCPressed() {
    return (CTL_INPUT_FLAGS & (1 << CTL_BUTTON_C_FLAG)) >> CTL_BUTTON_C_FLAG;
}

#endif