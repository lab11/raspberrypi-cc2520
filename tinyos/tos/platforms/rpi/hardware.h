/**
 * Hardware definition for the Raspberry Pi platform.
 *
 * @author Brad Campbell
 */
#ifndef _H_hardware_h
#define _H_hardware_h

//#include "msp430hardware.h"

// enum so components can override power saving,
// as per TEP 112.
//enum {
//  TOS_SLEEP_NONE = MSP430_POWER_ACTIVE,
//};
/*
// LEDS
TOSH_ASSIGN_PIN(RED_LED, 4, 0);
TOSH_ASSIGN_PIN(GREEN_LED, 4, 3);
TOSH_ASSIGN_PIN(YELLOW_LED, 4, 7);

// CC2420 RADIO
TOSH_ASSIGN_PIN(RADIO_CSN, 4, 2);
TOSH_ASSIGN_PIN(RADIO_VREF, 4, 5);
TOSH_ASSIGN_PIN(RADIO_RESET, 4, 6);
TOSH_ASSIGN_PIN(RADIO_FIFOP, 1, 0);
TOSH_ASSIGN_PIN(RADIO_SFD, 4, 1);
TOSH_ASSIGN_PIN(RADIO_GIO0, 1, 3);
TOSH_ASSIGN_PIN(RADIO_FIFO, 1, 3);
TOSH_ASSIGN_PIN(RADIO_GIO1, 1, 4);
TOSH_ASSIGN_PIN(RADIO_CCA, 1, 4);

TOSH_ASSIGN_PIN(CC_FIFOP, 1, 0);
TOSH_ASSIGN_PIN(CC_FIFO, 1, 3);
TOSH_ASSIGN_PIN(CC_SFD, 4, 1);
TOSH_ASSIGN_PIN(CC_VREN, 4, 5);
TOSH_ASSIGN_PIN(CC_RSTN, 4, 6);

// USART0
TOSH_ASSIGN_PIN(SIMO0, 3, 1);
TOSH_ASSIGN_PIN(SOMI0, 3, 2);
TOSH_ASSIGN_PIN(UCLK0, 3, 3);

// USART1
TOSH_ASSIGN_PIN(SIMO1, 5, 1);
TOSH_ASSIGN_PIN(SOMI1, 5, 2);
TOSH_ASSIGN_PIN(UCLK1, 5, 3);

// UART1
TOSH_ASSIGN_PIN(UTXD0, 3, 4);
TOSH_ASSIGN_PIN(URXD0, 3, 5);
TOSH_ASSIGN_PIN(UTXD1, 3, 6);
TOSH_ASSIGN_PIN(URXD1, 3, 7);

// 1-Wire
TOSH_ASSIGN_PIN(ONEWIRE, 2, 4);
*/
// need to undef atomic inside header files or nesC ignores the directive
#undef atomic

#endif // _H_hardware_h
