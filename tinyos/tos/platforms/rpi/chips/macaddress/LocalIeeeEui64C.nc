
configuration LocalIeeeEui64C {
  provides {
  	interface LocalIeeeEui64;
  }
}

implementation {
  components LocalIeeeEui64P;
  components Ds2411C;

  LocalIeeeEui64P.ReadId48 -> Ds2411C.ReadId48;

  LocalIeeeEui64 = LocalIeeeEui64P.LocalIeeeEui64;
}
