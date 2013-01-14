

#include "sam3spihardware.h"

module HilSam3SpiP
{
  provides
  {
    interface Init;
    interface SpiByte[uint8_t];
    interface SpiPacket[uint8_t];
  }
  uses
  {
    interface Init as SpiChipInit;
    interface ArbiterInfo;
    interface HplRpiSpiConfig;
    interface HplRpiSpiControl;
    interface HplRpiSpiInterrupts;
    interface HplRpiSpiStatus;
    interface HplNVICInterruptCntl as SpiIrqControl;
  //  interface HplRpiGeneralIOPin as SpiPinMiso;
  //  interface HplRpiGeneralIOPin as SpiPinMosi;
  //  interface HplRpiGeneralIOPin as SpiPinSpck;
  }
}
implementation
{

    void signalDone();
    task void signalDone_task();

    uint8_t* globalTxBuf;
    uint8_t* globalRxBuf;
    uint16_t globalLen;

    command error_t Init.init()
    {
        // turn off all interrupts
        call HplRpiSpiInterrupts.disableAllSpiIrqs();

        // configure NVIC
        call SpiIrqControl.configure(IRQ_PRIO_SPI);
        call SpiIrqControl.enable();

        // configure the proper pins in spi mode
        bcm2835_spi_begin();

        // configure PIO
    //    call SpiPinMiso.disablePioControl();
    //    call SpiPinMiso.selectPeripheralA();
   //     call SpiPinMosi.disablePioControl();
    //    call SpiPinMosi.selectPeripheralA();
    //    call SpiPinSpck.disablePioControl();
    //    call SpiPinSpck.selectPeripheralA();

        // reset the SPI configuration
        call HplRpiSpiControl.resetSpi();

        // configure for master
    //    call HplRpiSpiConfig.setMaster();

        // chip select options
    //    call HplSam3SpiConfig.setFixedCS(); // CS needs to be configured for each message sent!
        //call HplSam3SpiConfig.setVariableCS(); // CS needs to be configured for each message sent!
    //    call HplSam3SpiConfig.setDirectCS(); // CS pins are not multiplexed

        call SpiChipInit.init();
        return SUCCESS;
    }

    async command uint8_t SpiByte.write[uint8_t device]( uint8_t tx)
    {
        uint8_t byte;
        if(!(call ArbiterInfo.userId() == device))
            return -1;

        //call HplSam3SpiChipSelConfig.enableCSActive();
        call HplRpiSpiStatus.setDataToTransmit(tx);
        while(!call HplRpiSpiStatus.isRxFull());
        byte = (uint8_t)call HplRpiSpiStatus.getReceivedData();

        return byte;
    }

    async command error_t SpiPacket.send[uint8_t device](uint8_t* txBuf,
                                                         uint8_t* rxBuf,
                                                         uint16_t len)
    {
        uint16_t m_len = len;
        uint16_t m_pos = 0;

        if(!(call ArbiterInfo.userId() == device))
            return -1;

        if(len)
        {
            while( m_pos < len)
            {
                /**
                 * FIXME: in order to be compatible with the general TinyOS
                 * Spi Interface, we can't do automatic CS control!!!
                if(m_pos == len-1)
                    call HplSam3SpiStatus.setDataToTransmitCS(txBuf[m_pos], 3, TRUE);
                else
                    call HplSam3SpiStatus.setDataToTransmitCS(txBuf[m_pos], 3, FALSE);
                */
                /*
                call HplSam3SpiStatus.setDataToTransmitCS(txBuf[m_pos], device, FALSE);

                while(!call HplSam3SpiStatus.isRxFull());
                rxBuf[m_pos] = (uint8_t)call HplSam3SpiStatus.getReceivedData();
                */
                rxBuf[m_pos] = (uint8_t)call SpiByte.write[device](txBuf[m_pos]);
                m_pos += 1;
            }
        }
        atomic {
            globalRxBuf = rxBuf;
            globalTxBuf = txBuf;
            globalLen = m_len;
        }
        post signalDone_task();
        //atomic signal SpiPacket.sendDone(txBuf, rxBuf, m_len, SUCCESS);
        return SUCCESS;
    }

    task void signalDone_task() {
      atomic signalDone();
    }


    void signalDone() {
        uint8_t device = call ArbiterInfo.userId();
        signal SpiPacket.sendDone[device](globalTxBuf,
                                          globalRxBuf,
                                          globalLen,
                                          SUCCESS);
    }


    default async event void SpiPacket.sendDone[uint8_t device](uint8_t* tx_buf,
                                    uint8_t* rx_buf, uint16_t len, error_t error) {}

    async event void HplRpiSpiInterrupts.receivedData(uint16_t data) {};
}

