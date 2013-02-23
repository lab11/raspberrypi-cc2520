#include <bcm2835.h>

configuration HplBcm2835GeneralIOC {

  // provides all the ports as raw ports
  provides interface HplBcm2835GeneralIO as Port1_03; // GPIO 2
  provides interface HplBcm2835GeneralIO as Port1_05; // GPIO 3
  provides interface HplBcm2835GeneralIO as Port1_07; // GPIO 4
  provides interface HplBcm2835GeneralIO as Port1_08; // GPIO 14
  provides interface HplBcm2835GeneralIO as Port1_10; // GPIO 15
  provides interface HplBcm2835GeneralIO as Port1_11; // GPIO 17
  provides interface HplBcm2835GeneralIO as Port1_12; // GPIO 18
  provides interface HplBcm2835GeneralIO as Port1_13; // GPIO 27
  provides interface HplBcm2835GeneralIO as Port1_15; // GPIO 22
  provides interface HplBcm2835GeneralIO as Port1_16; // GPIO 23
  provides interface HplBcm2835GeneralIO as Port1_18; // GPIO 24
  provides interface HplBcm2835GeneralIO as Port1_19; // GPIO 10
  provides interface HplBcm2835GeneralIO as Port1_21; // GPIO 9
  provides interface HplBcm2835GeneralIO as Port1_22; // GPIO 25
  provides interface HplBcm2835GeneralIO as Port1_23; // GPIO 11
  provides interface HplBcm2835GeneralIO as Port1_24; // GPIO 8
  provides interface HplBcm2835GeneralIO as Port1_26; // GPIO 7

  // provides special ports explicitly
  provides interface HplBcm2835GeneralIO as I2C0_SDA;
  provides interface HplBcm2835GeneralIO as I2C0_SCL;
  provides interface HplBcm2835GeneralIO as UART0_TXD;
  provides interface HplBcm2835GeneralIO as UART0_RXD;
  provides interface HplBcm2835GeneralIO as SPI0_MOSI;
  provides interface HplBcm2835GeneralIO as SPI0_MISO;
  provides interface HplBcm2835GeneralIO as SPI0_SCLK;
  provides interface HplBcm2835GeneralIO as SPI0_CE0_N;
  provides interface HplBcm2835GeneralIO as SPI0_CE1_N;
}

implementation {

  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_03) as P103;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_05) as P105;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_07) as P107;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_08) as P108;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_10) as P110;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_11) as P111;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_12) as P112;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_13) as P113;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_15) as P115;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_16) as P116;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_18) as P118;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_19) as P119;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_21) as P121;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_22) as P122;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_23) as P123;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_24) as P124;
  components new HplBcm2835GeneralIOP(RPI_V2_GPIO_P1_26) as P126;

  Port1_03 = P103;
  Port1_05 = P105;
  Port1_07 = P107;
  Port1_08 = P108;
  Port1_10 = P110;
  Port1_11 = P111;
  Port1_12 = P112;
  Port1_13 = P113;
  Port1_15 = P115;
  Port1_16 = P116;
  Port1_18 = P118;
  Port1_19 = P119;
  Port1_21 = P121;
  Port1_22 = P122;
  Port1_23 = P123;
  Port1_24 = P124;
  Port1_26 = P126;

  I2C0_SDA   = P103;
  I2C0_SCL   = P105;
  UART0_TXD  = P108;
  UART0_RXD  = P110;
  SPI0_MOSI  = P119;
  SPI0_MISO  = P121;
  SPI0_SCLK  = P123;
  SPI0_CE0_N = P124;
  SPI0_CE1_N = P126;
}
