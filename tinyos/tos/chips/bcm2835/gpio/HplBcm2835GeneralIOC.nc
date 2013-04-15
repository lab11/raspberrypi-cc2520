#include "gpio.h"

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

}

implementation {

  components HplBcm2835GeneralIOP as IoP;
  components PlatformP;

  PlatformP.GpioInit -> IoP.Init;

  Port1_03 = IoP.Gpio[RPI_V2_GPIO_P1_03];
  Port1_05 = IoP.Gpio[RPI_V2_GPIO_P1_05];
  Port1_07 = IoP.Gpio[RPI_V2_GPIO_P1_07];
  Port1_08 = IoP.Gpio[RPI_V2_GPIO_P1_08];
  Port1_10 = IoP.Gpio[RPI_V2_GPIO_P1_10];
  Port1_11 = IoP.Gpio[RPI_V2_GPIO_P1_11];
  Port1_12 = IoP.Gpio[RPI_V2_GPIO_P1_12];
  Port1_13 = IoP.Gpio[RPI_V2_GPIO_P1_13];
  Port1_15 = IoP.Gpio[RPI_V2_GPIO_P1_15];
  Port1_16 = IoP.Gpio[RPI_V2_GPIO_P1_16];
  Port1_18 = IoP.Gpio[RPI_V2_GPIO_P1_18];
  Port1_19 = IoP.Gpio[RPI_V2_GPIO_P1_19];
  Port1_21 = IoP.Gpio[RPI_V2_GPIO_P1_21];
  Port1_22 = IoP.Gpio[RPI_V2_GPIO_P1_22];
  Port1_23 = IoP.Gpio[RPI_V2_GPIO_P1_23];
  Port1_24 = IoP.Gpio[RPI_V2_GPIO_P1_24];
  Port1_26 = IoP.Gpio[RPI_V2_GPIO_P1_26];

}
