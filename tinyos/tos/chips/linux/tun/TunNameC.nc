/* Default implementation of a module that provides the TUN name to use when
 * creating a TUN device. This module is intended to be overwritten if the tun
 * name needs to be customized.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

module TunNameC {
  provides {
    interface TunName;
  }
}

implementation {

  command char* TunName.getTunName () {
    return "\0";
  }

}
