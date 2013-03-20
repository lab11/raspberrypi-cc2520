configuration Ds2411C {
  provides interface ReadId48;
}
implementation {
  components Ds2411P;
  components OneWireMasterC;
  components HplDs2411C;

  Ds2411P.OneWire -> OneWireMasterC.OneWire;
  OneWireMasterC.Pin -> HplDs2411C.Gpio;

  ReadId48 = Ds2411P.ReadId48;
}
