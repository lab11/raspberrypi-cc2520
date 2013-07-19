
/* Simple interface for loading and querying a border router config file.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

interface BRConfig {
  command error_t getPrefix (struct in6_addr* prefix);
  command struct in6_addr* getPrefixPtr ();
}
