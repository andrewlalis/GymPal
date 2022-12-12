#ifndef SPI_H
#define SPI_H

#include <avr/io.h>

#define SPI_DDR DDRB
#define SPI_SCK DDB5
#define SPI_MISO DDB4
#define SPI_MOSI DDB3

/**
 * @brief Initializes this device as an SPI master.
 */
void spi_initMaster();

/**
 * @brief Initializes this device as an SPI slave. 
 */
void spi_initSlave();

/** 
 * @brief Transmits a single byte of data to the currently selected slave
 * device. Blocks until transmission is complete.
 */
void spi_masterTransmit(uint8_t data);

/**
 * @brief Receives a single byte of data from a connected master. Blocks
 * until the receive is complete.
 */
uint8_t spi_slaveReceive();

#endif