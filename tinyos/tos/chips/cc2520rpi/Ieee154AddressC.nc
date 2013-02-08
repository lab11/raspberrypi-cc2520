
configuration Ieee154AddressC {
  provides interface Ieee154Address;

} implementation {
  components Ieee154AddressP;
  components LocalIeeeEui64C;
  components MainC;
  Ieee154Address = Ieee154AddressP;

  MainC.SoftwareInit -> Ieee154AddressP;
  Ieee154AddressP.LocalIeeeEui64 -> LocalIeeeEui64C;

  // workaround until the radio stack uses this interface
  components CC2520RpiRadioC;
  Ieee154AddressP.RadioAddress -> CC2520RpiRadioC.RadioAddress;
}
