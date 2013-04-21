#ifndef __GPIO_H__
#define __GPIO_H__

// RPi Version 2
enum {
  RPI_V2_GPIO_P1_03 =  2,  // Version 2, Pin P1-03
  RPI_V2_GPIO_P1_05 =  3,  // Version 2, Pin P1-05
  RPI_V2_GPIO_P1_07 =  4,  // Version 2, Pin P1-07
  RPI_V2_GPIO_P1_08 = 14,  // Version 2, Pin P1-08, defaults to alt function 0 UART0_TXD
  RPI_V2_GPIO_P1_10 = 15,  // Version 2, Pin P1-10, defaults to alt function 0 UART0_RXD
  RPI_V2_GPIO_P1_11 = 17,  // Version 2, Pin P1-11
  RPI_V2_GPIO_P1_12 = 18,  // Version 2, Pin P1-12
  RPI_V2_GPIO_P1_13 = 27,  // Version 2, Pin P1-13
  RPI_V2_GPIO_P1_15 = 22,  // Version 2, Pin P1-15
  RPI_V2_GPIO_P1_16 = 23,  // Version 2, Pin P1-16
  RPI_V2_GPIO_P1_18 = 24,  // Version 2, Pin P1-18
  RPI_V2_GPIO_P1_19 = 10,  // Version 2, Pin P1-19, MOSI when SPI0 in use
  RPI_V2_GPIO_P1_21 =  9,  // Version 2, Pin P1-21, MISO when SPI0 in use
  RPI_V2_GPIO_P1_22 = 25,  // Version 2, Pin P1-22
  RPI_V2_GPIO_P1_23 = 11,  // Version 2, Pin P1-23, CLK when SPI0 in use
  RPI_V2_GPIO_P1_24 =  8,  // Version 2, Pin P1-24, CE0 when SPI0 in use
  RPI_V2_GPIO_P1_26 =  7,  // Version 2, Pin P1-26, CE1 when SPI0 in use

  RPI_V2_GPIO_P5_03  = 28, // Version 2, Pin P5-03
  RPI_V2_GPIO_P5_04  = 29, // Version 2, Pin P5-04
  RPI_V2_GPIO_P5_05  = 30, // Version 2, Pin P5-05
  RPI_V2_GPIO_P5_06  = 31  // Version 2, Pin P5-06
};

#endif
