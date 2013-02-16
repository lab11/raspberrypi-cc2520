#ifndef __DEBUG_PRINTF_H__
#define __DEBUG_PRINTF_H__

#include <stdio.h>

#define CC2520RPI_DEBUG 1
#define TUN_DEBUG 1

#define DBG(...)\
  do {\
    flockfile(stdout);\
    printf("%s:%d:\t", __FILE__, __LINE__); \
    printf(__VA_ARGS__);\
    funlockfile(stdout);\
  } while (0)


// fprintf(stderr, "%s:%d\t%s:\t", __FILE__, __LINE__, __func__); \

#define ERROR(...)\
  do {\
    flockfile(stderr);\
    fprintf(stderr, "%s:%d\t", __FILE__, __LINE__); \
    fprintf(stderr, __VA_ARGS__);\
    funlockfile(stderr);\
  } while (0)


#ifdef CC2520RPI_DEBUG
#define RADIO_PRINTF(...) DBG(__VA_ARGS__)
#else
#define RADIO_PRINTF(...)
#endif

#ifdef TUN_DEBUG
#define TUN_PRINTF(...) DBG(__VA_ARGS__)
#else
#define TUN_PRINTF(...)
#endif

#endif
