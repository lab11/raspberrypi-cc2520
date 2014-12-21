#ifndef PLATFORM_MESSAGE_H
#define PLATFORM_MESSAGE_H

#include "CC2520LinuxRadio.h"

#define TOSH_DATA_LENGTH 128

typedef union message_header {
  cc2520packet_header_t cc2520;
} message_header_t;

typedef union message_footer {
  cc2520packet_footer_t cc2520;
} message_footer_t;

typedef union message_metadata {
  cc2520packet_metadata_t cc2520;
} message_metadata_t;

#endif
