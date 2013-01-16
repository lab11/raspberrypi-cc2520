
configuration LocalIeeeEui64C {
  provides {
  	interface LocalIeeeEui64;
  }
}

implementation {
//  components
//    Ds2411C,
//    DallasId48ToIeeeEui64C;

//  LocalIeeeEui64 = DallasId48ToIeeeEui64C;
//  DallasId48ToIeeeEui64C.ReadId48 -> Ds2411C;

  components LocalIeeeEui64P;
  LocalIeeeEui64 = LocalIeeeEui64P.LocalIeeeEui64;
}
