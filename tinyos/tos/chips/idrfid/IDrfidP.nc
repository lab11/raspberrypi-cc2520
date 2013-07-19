#include "uart.h"

/**
 * Module for reading the ID series of RFID readers.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 * @version $Revision: 1.1
 */

module IDrfidP {
  provides {
    interface Notify<uint8_t*>;
  }
  uses {
    interface UartBuffer;
    interface UartConfig;
  }
}
implementation {

  bool active = FALSE;
  uint8_t rfid_code[5];

  uart_config_t rfid_uart_conf = {9600, 16};

  command error_t Notify.enable() {
    active = TRUE;
    return call UartConfig.setserial(&rfid_uart_conf);
  }

  command error_t Notify.disable() {
    active = FALSE;
    return SUCCESS;
  }

  uint8_t ahex2b (uint8_t ascii) {
    if (ascii > 0x2f && ascii < 0x3a) {
      // is numeral
      return ascii - 0x30;
    } else if (ascii > 0x40 && ascii < 0x47) {
      // is uppercase hex letter
      return ascii - 0x37;
    } else if (ascii > 0x60 && ascii < 0x67) {
      // is lowercase hex letter
      return ascii - 0x57;
    }
    // error - is not hex character in ascii
    return 0x0;
  }

  void convert_rfid (uint8_t* buf, uint8_t* code) {
    int i;
    uint8_t char1, char2;
    for (i=0; i<5; i++) {
      char1 = ahex2b(buf[i<<1]);
      char2 = ahex2b(buf[(i<<1)+1]);
      code[i] = (char1<<4) | char2;
    }
  }

  bool verify_checksum (uint8_t* code, uint8_t* chksum_buf) {
    int i;
    uint8_t chksum = 0;
    uint8_t zero_checker = 0;   // makes sure the code is not all zeros
    uint8_t real_chksum = (ahex2b(chksum_buf[0])<<4) | ahex2b(chksum_buf[1]);

    for (i=0; i<5; i++) {
      chksum ^= code[i];
      zero_checker |= code[i];
    }

    return chksum == real_chksum && zero_checker;
  }

  event void UartBuffer.receive (uint8_t* buf,
                                 uint8_t len,
                                 uint64_t timestamp) {
    bool chksum;

    if (!active) {
      return;
    }

    if (len != 16) {
      return;
    }

    convert_rfid(buf + 1, rfid_code);
    chksum = verify_checksum(rfid_code, buf+11);
    if (chksum) signal Notify.notify(rfid_code);
  }

}

