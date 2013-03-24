

//#include <sam3spihardware.h>

generic configuration RpiSpiC(uint8_t chip_enable)
{
  provides
  {
    interface Resource;
    interface SpiByte;
    interface FastSpiByte;
    interface SpiPacket;
    interface HplRpiSpiChipSelConfig;
  }
  uses {
    interface Init as SpiInit;
    interface ResourceConfigure;
  }
}
implementation
{
  enum {
    CLIENT_ID = unique(RPI_SPI_BUS),
  };

  components HilRpiSpiC as SpiC;
  SpiC.SpiChipInit       = SpiInit;
  Resource               = SpiC.Resource[CLIENT_ID];
  SpiByte                = SpiC.SpiByte[CLIENT_ID];
  FastSpiByte            = SpiC.FastSpiByte[CLIENT_ID];
  SpiPacket              = SpiC.SpiPacket[CLIENT_ID];
  HplRpiSpiChipSelConfig = SpiC.HplRpiSpiChipSelConfig[chip_enable];

  components new RpiSpiP(chip_enable);
  ResourceConfigure = RpiSpiP.ResourceConfigure;
  RpiSpiP.SubResourceConfigure <- SpiC.ResourceConfigure[CLIENT_ID];
  RpiSpiP.HplRpiSpiConfig -> SpiC.HplRpiSpiConfig;
}

