# GymPal
A simple device for recording gym sessions, using AVR.

## Development
The software for this system is developed in C, using [avr-libc](https://www.nongnu.org/avr-libc/), and the build toolchain is managed by make, using [avr-gcc](https://linux.die.net/man/1/avr-gcc) and [avr-dude](https://github.com/avrdudes/avrdude) to upload firmware to the Atmega328p microcontroller.

To compile the firmware, you can run `make`.

To upload the firmware to an Arduino, run `make flash`.

### Helpful Links
The following links are helpful for learning how to program an AVR-based microcontroller.

- [avr-libc Homepage](https://www.nongnu.org/avr-libc/)
- [avr-libc Library Reference](https://www.nongnu.org/avr-libc/user-manual/modules.html)
- [avrdude Firmware Uploader](https://github.com/avrdudes/avrdude)
