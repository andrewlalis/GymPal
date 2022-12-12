#include "spi.h"

void spi_initMaster() {
    SPI_DDR = (
        (1 << SPI_MOSI) |
        (1 << SPI_SCK)
    );
    SPCR = (
        (1 << SPE) |
        (1 << MSTR) |
        (1 << SPR0)
    );
}

void spi_initSlave() {
    SPI_DDR = (1 << SPI_MISO);
    SPCR = (1 << SPE);
}

void spi_masterTransmit(uint8_t data) {
    SPDR = data;
    while (!(SPSR & (1 << SPIF))) {
        // Loop until we confirm transmission is done.
    }
}

uint8_t spi_slaveReceive() {
    while (!(SPSR & (1 << SPIF))) {
        // Loop until SPI status is done.
    }
    return SPDR;
}