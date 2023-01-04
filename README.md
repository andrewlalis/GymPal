# GymPal
A simple device for recording gym sessions, using AVR.

The GymPal is a lightweight piece of hardware with built-in storage, time-keeping, display, and controls, to allow you to record exercise metrics on-the-fly in a satisfying, tactile way.

## Development
The software for this system is developed in C, using [avr-libc](https://www.nongnu.org/avr-libc/), and the build toolchain is managed by make, using [avr-gcc](https://linux.die.net/man/1/avr-gcc) and [avr-dude](https://github.com/avrdudes/avrdude) to upload firmware to the Atmega328p microcontroller.

```shell
sudo apt install gcc-avr
sudo apt install avr-libc
sudo apt install avrdude
```

After cloning this repository, you must first compile the build script with `./prepare-build-tools.d`. Then, you can run `./build <command>` to run various build commands. See `./build help` for more information.

## Hardware
Here's a list of the hardware that this project uses, just for reference:
- Microprocessor: [Atmega328p](https://ww1.microchip.com/downloads/en/DeviceDoc/Atmel-7810-Automotive-Microcontrollers-ATmega328P_Datasheet.pdf)
- Real-Time-Clock: [DS3231SN](https://nl.mouser.com/datasheet/2/256/DS3231-1513891.pdf)
- Display (subject to change): [SSD1306 OLED 128x64](https://cdn-shop.adafruit.com/datasheets/SSD1306.pdf)
- Onboard storage: [Adafruit SD Card Module](https://cdn-shop.adafruit.com/datasheets/TS16GUSDHC6.pdf)

### Helpful Links
The following links are helpful for learning how to program an AVR-based microcontroller.

- [avr-libc Homepage](https://www.nongnu.org/avr-libc/)
- [avr-libc Library Reference](https://www.nongnu.org/avr-libc/user-manual/modules.html)
- [avrdude Firmware Uploader](https://github.com/avrdudes/avrdude)
