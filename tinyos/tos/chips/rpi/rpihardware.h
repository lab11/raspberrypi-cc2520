
#ifndef __DEBIAN_HARDWARE_H__
#define __DEBIAN_HARDWARE_H__

#include <signal.h>

typedef uint8_t mcu_power_t;
typedef bool __nesc_atomic_t;

sigset_t global_sig;
bool interrupts_enabled = TRUE;

__nesc_atomic_t __nesc_atomic_start(void);
void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts);

void __nesc_disable_interrupt(void) @safe() {
  sigset_t all;

  if (!interrupts_enabled) return;

  sigfillset(&all);
  sigprocmask(SIG_BLOCK, &all, &global_sig);
  interrupts_enabled = FALSE;
}

void __nesc_enable_interrupt(void) @safe() {
  if (interrupts_enabled) return;
  sigprocmask(SIG_SETMASK, &global_sig, NULL);
  interrupts_enabled = TRUE;
}

/* @spontaneous() functions should not be included when NESC_BUILD_BINARY
   is #defined, to avoid duplicate functions definitions when binary
   components are used. Such functions do need a prototype in all cases,
   though. */
__nesc_atomic_t __nesc_atomic_start(void) @spontaneous() @safe() {
  __nesc_disable_interrupt();
  return 1;
}

void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts) @spontaneous() @safe() {
  __nesc_enable_interrupt();
}



#endif


