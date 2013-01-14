
/**
 * An HPL abstraction of USART0 on the MSP430.
 *
 * @author Jonathan Hui <jhui@archrock.com>
 * @author Joe Polastre
 * @version $Revision: 1.7 $ $Date: 2010-06-29 22:07:45 $
 */

//#include "msp430usart.h"

configuration HplRpiUsartC {

  provides interface HplRpiUsart;
//  provides interface HplMsp430UsartInterrupts;
//  provides interface HplMsp430I2CInterrupts;

}

implementation {

  components HplRpiUsartP as HplUsartP;
  HplRpiUsart = HplUsartP;
//  HplMsp430UsartInterrupts = HplUsartP;
//  HplMsp430I2CInterrupts = HplUsartP;

  components HplRpiGeneralIOC as GIO;
  HplUsartP.SPI0_MOSI -> GIO.SPI0_MOSI;
  HplUsartP.SPI0_MISO -> GIO.SPI0_MISO;
  HplUsartP.SPI0_SCLK -> GIO.SPI0_SCLK;
  HplUsartP.UART0_RXD -> GIO.UART0_RXD;
  HplUsartP.UART0_TXD -> GIO.UART0_TXD;
  HplUsartP.I2C0_SDA  -> GIO.I2C0_SDA;
  HplUsartP.I2C0_SCL  -> GIO.I2C0_SCL;

}
