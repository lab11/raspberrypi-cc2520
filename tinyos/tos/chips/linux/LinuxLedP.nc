
generic module LinuxLedP (const char* led_name) {
  provides {
    interface GeneralIO;
  }
}

implementation {

  int led_file;

  // We use makeOutput as the init function.
  // Using GeneralIO for a linux led is dumb as it is.
  async command void GeneralIO.makeOutput () {
    char filename[256];
    snprintf(filename, 256, "/sys/devices/platform/%s", led_name);
    led_file = open(filename, O_WRONLY);
  }

  async command void GeneralIO.set () {
    write(led_file, "0", 1);
  }

  async command void GeneralIO.clr () {
    write(led_file, "0", 1);
  }

  async command void GeneralIO.toggle () {
    write(led_file, "0", 1);
  }

  async command bool GeneralIO.get () {
    return true;
  }

  async command void GeneralIO.makeInput () {
  }

  async command void GeneralIO.isInput () {
  }

  async command void GeneralIO.isOutput () {
  }

}
