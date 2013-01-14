#ifndef SIMPLESACKTEST_H
#define SIMPLESACKTEST_H

enum {
  AM_BLINKTORADIO = 6,
  TIMER_PERIOD_MILLI = 250
};

typedef nx_struct BlinkToRadioMsg {
  nx_uint16_t counter;
} BlinkToRadioMsg;

#endif
