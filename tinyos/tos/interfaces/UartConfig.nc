#include "uart.h"

interface UartConfig {
  command error_t setserial (uart_config_t* c);
}
