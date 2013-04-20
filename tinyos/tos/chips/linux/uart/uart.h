#ifndef __RPI_UART_H__
#define __RPI_UART_H__

/*
 * Definitions for async_struct (and serial_struct) flags field
 */
#define ASYNC_HUP_NOTIFY      0x0001  // Notify getty on hangups and closes
                                      // on the callout port
#define ASYNC_FOURPORT        0x0002  // Set OU1, OUT2 per AST Fourport settings
#define ASYNC_SAK             0x0004  // Secure Attention Key (Orange book)
#define ASYNC_SPLIT_TERMIOS   0x0008  // Separate termios for dialin/callout
#define ASYNC_SPD_MASK        0x1030
#define ASYNC_SPD_HI          0x0010  // Use 56000 instead of 38400 bps
#define ASYNC_SPD_VHI         0x0020  // Use 115200 instead of 38400 bps
#define ASYNC_SPD_CUST        0x0030  // Use user-specified divisor
#define ASYNC_SKIP_TEST       0x0040  // Skip UART test during autoconfiguration
#define ASYNC_AUTO_IRQ        0x0080  // Do automatic IRQ during autoconfig
#define ASYNC_SESSION_LOCKOUT 0x0100  // Lock out cua opens based on session
#define ASYNC_PGRP_LOCKOUT    0x0200  // Lock out cua opens based on pgrp
#define ASYNC_CALLOUT_NOHUP   0x0400  // Don't do hangups for cua device
#define ASYNC_HARDPPS_CD      0x0800  // Call hardpps when CD goes high
#define ASYNC_SPD_SHI         0x1000  // Use 230400 instead of 38400 bps
#define ASYNC_SPD_WARP        0x1010  // Use 460800 instead of 38400 bps
#define ASYNC_LOW_LATENCY     0x2000  // Request low latency behaviour
#define ASYNC_FLAGS           0x3FFF  // Possible legal async flags
#define ASYNC_USR_MASK        0x3430  // Legal flags that non-privileged
                                      // users can set or reset

// Internal flags used only by kernel/chr_drv/serial.c
#define ASYNC_INITIALIZED     0x80000000 // Serial port was initialized
#define ASYNC_CALLOUT_ACTIVE  0x40000000 // Call out device is active
#define ASYNC_NORMAL_ACTIVE   0x20000000 // Normal device is active
#define ASYNC_BOOT_AUTOCONF   0x10000000 // Autoconfigure port on bootup
#define ASYNC_CLOSING         0x08000000 // Serial port is closing
#define ASYNC_CTS_FLOW        0x04000000 // Do CTS flow control
#define ASYNC_CHECK_CD        0x02000000 // i.e., CLOCAL
#define ASYNC_SHARE_IRQ       0x01000000 // for multifunction cards
#define ASYNC_INTERNAL_FLAGS  0xFF000000 // Internal flags

struct serial_struct {
  int type;
  int line;
  int port;
  int irq;
  int flags;
  int xmit_fifo_size;
  int custom_divisor;
  int baud_base;
  unsigned short close_delay;
  char io_type;
  char reserved_char[1];
  int hub6;
  unsigned short closing_wait; /* time to wait before closing */
  unsigned short closing_wait2; /* no longer used... */
  unsigned char *iomem_base;
  unsigned short iomem_reg_shift;
  int reserved[2];
};

typedef struct {
  int baud_rate;
  int min_return;
} uart_config_t;

#endif
