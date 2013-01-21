#ifndef __CC2520RPIDRIVER_H__
#define __CC2520RPIDRIVER_H__

#include <asm/ioctl.h>
#include <linux/types.h>
#include <inttypes.h>

#define BASE 0xCC

struct cc2520_set_channel_data {
	uint8_t channel;
};

struct cc2520_set_address_data {
	uint16_t short_addr;
	uint64_t extended_addr;
	uint16_t pan_id;
};

struct cc2520_set_ack_data {
	uint32_t timeout;
};

struct cc2520_set_lpl_data {
	uint32_t window;
	uint32_t interval;
	bool enabled;
};

struct cc2520_set_csma_data {
	uint32_t min_backoff;
	uint32_t init_backoff;
	uint32_t cong_backoff;
	bool enabled;
};

struct cc2520_set_print_messages_data {
	bool enabled;
};

// Possible TX Powers:
#define CC2520_TXPOWER_5DBM 0xF7
#define CC2520_TXPOWER_3DBM 0xF2
#define CC2520_TXPOWER_2DBM 0xAB
#define CC2520_TXPOWER_1DBM 0x13
#define CC2520_TXPOWER_0DBM 0x32
#define CC2520_TXPOWER_N2DBM 0x81
#define CC2520_TXPOWER_N4DBM 0x88
#define CC2520_TXPOWER_N7DBM 0x2C
#define CC2520_TXPOWER_N18DBM 0x03

struct cc2520_set_txpower_data {
	uint8_t txpower;
};

#define CC2520_IO_RADIO_INIT _IO(BASE, 0)
#define CC2520_IO_RADIO_ON _IO(BASE, 1)
#define CC2520_IO_RADIO_OFF _IO(BASE, 2)
#define CC2520_IO_RADIO_SET_CHANNEL _IOW(BASE, 3, struct cc2520_set_channel_data)
#define CC2520_IO_RADIO_SET_ADDRESS _IOW(BASE, 4, struct cc2520_set_address_data)
#define CC2520_IO_RADIO_SET_TXPOWER _IOW(BASE, 5, struct cc2520_set_txpower_data)
#define CC2520_IO_RADIO_SET_ACK _IOW(BASE, 6, struct cc2520_set_ack_data)
#define CC2520_IO_RADIO_SET_LPL _IOW(BASE, 7, struct cc2520_set_lpl_data)
#define CC2520_IO_RADIO_SET_CSMA _IOW(BASE, 8, struct cc2520_set_csma_data)
#define CC2520_IO_RADIO_SET_PRINT _IOW(BASE, 9, struct cc2520_set_print_messages_data)

// Transmit error codes
#define CC2520_TX_SUCCESS 0
#define CC2520_TX_BUSY 1
#define CC2520_TX_LENGTH 2
#define CC2520_TX_ACK_TIMEOUT 3
#define CC2520_TX_FAILED 4

#endif
