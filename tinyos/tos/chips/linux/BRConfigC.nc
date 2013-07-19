/* Component for loading and parsing a Border Router config file.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration BRConfigC {
  provides {
    interface BRConfig;
  }
}
implementation {
  components BRConfigP;
  BRConfig = BRConfigP.BRConfig;
}
