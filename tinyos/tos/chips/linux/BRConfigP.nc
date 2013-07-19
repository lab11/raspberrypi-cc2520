#include "ini.h"

/* Supports the following configuration options:
 *
 * [network]
 *   prefix = <ipv6 prefix>
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

module BRConfigP {
  provides {
    interface BRConfig;
  }
}
implementation {

  typedef struct {
    struct in6_addr prefix; // IPv6 prefix for the network
  } border_router_config_t;

  bool inited = FALSE;
  const char* filename = "brconfig.ini";
  border_router_config_t brc;

  int handler (void* user, const char* section, const char* name, const char* value) {
    border_router_config_t* brc_ptr = (border_router_config_t*) user;

    #define MATCH(s, n) strcmp(section, s) == 0 && strcmp(name, n) == 0
    if (MATCH("network", "prefix")) {
      // Save the address as binary data
      inet_pton6(value, &brc_ptr->prefix);
    } else {
      return 0;  // unknown section/name, error
    }
    return 1;
  }

  // Open an .ini file to configure the border router
  error_t init() {
    int result;

    if (inited) return EALREADY;

    result = ini_parse(filename, handler, &brc);
    if (result < 0) {
      ERROR("Could not load %s.\n", filename);
      ERROR("You must provide an .ini file for configuration.\n");
      exit(1);
    }

    inited = TRUE;

    return SUCCESS;
  }

  // Copies the prefix into the address you provide
  command error_t BRConfig.getPrefix (struct in6_addr* prefix) {
    init();

    memcpy(&prefix->s6_addr, &brc.prefix.s6_addr, sizeof(struct in6_addr));
    return SUCCESS;
  }

  command struct in6_addr* BRConfig.getPrefixPtr () {
    init();
    return &brc.prefix;
  }

}
