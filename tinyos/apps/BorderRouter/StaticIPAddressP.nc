/**
 * Component for doing compile-time address allocation. Wired by the
 * stack, sets a static address based on IN6_PREFIX and the EUI64 on
 * boot. Useful for development or of you want to hard-code addresses.
 *
 * @author Stephen Dawson-Haggerty <stevedh@eecs.berkeley.edu>
 * @author Brad Campbell <bradjc@umich.edu>
 */
#include <lib6lowpan/ip.h>

module StaticIPAddressP {
  uses {
    interface Boot;
    interface IPAddress;
    interface LocalIeeeEui64;
    interface SetIPAddress;
    interface BRConfig;
  }
} implementation {

  event void Boot.booted() {
    struct in6_addr addr;
    ieee154_laddr_t ext;

    // Get the prefix
    call BRConfig.getPrefix(&addr);

    // Set the lower 64 bits as the link-local 64 bits
    ext = call LocalIeeeEui64.getId();
    memcpy(addr.s6_addr+8, ext.data, 8);
    addr.s6_addr[8] ^= 0x2;

    printf("This node's address: ");
    printf_in6addr(&addr);
    printf("\n");

    call SetIPAddress.setAddress(&addr);
  }

  event void IPAddress.changed(bool valid) {}
}
