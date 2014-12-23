#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

generic module LinuxLedP (char led_name[]) {
  provides {
    interface GeneralIO;
  }
}

implementation {

  char filename[256];

  // We use makeOutput as the init function.
  // Using GeneralIO for a linux led is dumb as it is.
  async command void GeneralIO.makeOutput () {
    snprintf(filename, 256, "/sys/class/leds/%s/brightness", led_name);
  }

  async command void GeneralIO.set () {
    int led_file = open(filename, O_RDWR);
    write(led_file, "1", 1);
  }

  async command void GeneralIO.clr () {
    int led_file = open(filename, O_RDWR);
    write(led_file, "0", 1);
  }

  async command void GeneralIO.toggle () {
    int led_file = open(filename, O_RDWR);
    if (call GeneralIO.get()) {
      write(led_file, "0", 1);
    } else {
      write(led_file, "1", 1);
    }
  }

  async command bool GeneralIO.get () {
    char buffer[10];
    int led_file = open(filename, O_RDWR);

    read(led_file, buffer, 1);
    if (strncmp(buffer, "1", 1) == 0) {
      return TRUE;
    }
    return FALSE;
  }

  async command void GeneralIO.makeInput () {
  }

  async command bool GeneralIO.isInput () {
    return FALSE;
  }

  async command bool GeneralIO.isOutput () {
    return TRUE;
  }

}
