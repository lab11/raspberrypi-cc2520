
configuration LocalIeeeEui64C {
  provides {
  	interface LocalIeeeEui64;
  }
}

implementation {
  components LocalIeeeEui64P;
  LocalIeeeEui64 = LocalIeeeEui64P.LocalIeeeEui64;
}
