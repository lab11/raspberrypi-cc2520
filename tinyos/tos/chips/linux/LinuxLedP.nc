#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

generic module LinuxLedP (char led_name[]) {
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
    snprintf(filename, 256, "/sys/class/leds/%s/brightness", led_name);
    led_file = open(filename, O_WRONLY);
  }

  async command void GeneralIO.set () {
    int f;
    atomic f = led_file;
    write(f, "1", 1);
  }

  async command void GeneralIO.clr () {
    int f;
    atomic f = led_file;
    write(f, "0", 1);
  }

  async command void GeneralIO.toggle () {
    int f;
    atomic f = led_file;
    if (call GeneralIO.get()) {
      write(f, "0", 1);
    } else {
      write(f, "1", 1);
    }
  }

  async command bool GeneralIO.get () {
    char buffer[10];
    int f;
    atomic f = led_file;

    read(f, buffer, 1);
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
