all: clean build

clean:
	rm -rf bin/

flash: build
	avrdude -c arduino -p atmega328p -P /dev/ttyUSB0 -b115200 -U flash:w:bin/gympal.hex:i

build: gympal.hex

gympal.hex: gympal.o control.o
	avr-gcc -Os -mmcu=atmega328p -o bin/gympal.elf bin/gympal.o bin/control.o
	avr-objcopy -O ihex -R .eeprom bin/gympal.elf bin/gympal.hex

gympal.o: src/gympal.c bin
	avr-gcc -Wall -Os -DF_CPU=16000000UL -mmcu=atmega328p -c -o bin/gympal.o src/gympal.c

control.o: src/control.c bin
	avr-gcc -Wall -Os -DF_CPU=16000000UL -mmcu=atmega328p -c -o bin/control.o src/control.c

bin:
	mkdir bin