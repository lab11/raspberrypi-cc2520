/* Interface for retrieving the name a TUN device should use.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

interface TunName {
  command char* getTunName ();
}
