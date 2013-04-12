#include <stdio.h>
#include <stdlib.h>
#include <time.h>

module RandomLinuxP @safe() {
  provides {
    interface Init;
    interface ParameterInit<uint16_t> as SeedInit;
    interface Random;
  }
}
implementation {

  command error_t Init.init () {
    unsigned int iseed;

    iseed = (unsigned int) time(NULL);
    srand(iseed);

    return SUCCESS;
  }

  command error_t SeedInit.init (uint16_t s) {
    srand((unsigned int) s);

    return SUCCESS;
  }

  // Return the next 32 bit random number
  async command uint32_t Random.rand32 () {
    return (uint32_t) rand();
  }

  // Return low 16 bits of next 32 bit random number
  async command uint16_t Random.rand16 () {
    return (uint16_t) rand();
  }

}
