
interface BlockingIO {
  // Block on all IO calls
  async command void waitForIO ();
}
