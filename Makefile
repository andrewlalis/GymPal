all: clean build

clean:
	rm -rf bin/

flash: build
	avrdude -c arduino -p atmega328p -P /dev/ttyUSB0 -b115200 -U flash:w:bin/gympal.hex:i

build: gympal.hex

gympal.hex: src/gympal.c bin
	avr-gcc -Wall -Os -DF_CPU=16000000UL -mmcu=atmega328p -c src/gympal.c -o bin/gympal.o
	avr-gcc -Os -mmcu=atmega328p -o bin/gympal.elf bin/gympal.o
	avr-objcopy -O ihex -R .eeprom bin/gympal.elf bin/gympal.hex

bin:
	mkdir bin