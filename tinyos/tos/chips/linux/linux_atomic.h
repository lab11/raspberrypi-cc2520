#ifndef __LINUX_ATOMIC_H__
#define __LINUX_ATOMIC_H__

#include <signal.h>

typedef uint8_t mcu_power_t;
typedef bool __nesc_atomic_t;

// We can safely use norace with these variables. There are only accessed when
// interrupts are disabled, but the nesc compiler doesn't know that.
norace bool interupts_enabled = TRUE;
norace sigset_t global_sigmask;

__nesc_atomic_t __nesc_atomic_start(void);
void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts);

void __nesc_disable_interrupt(void) @safe() {
  sigset_t all;
  sigset_t temp_sigmask;

  // Unconditionally block all signals when this function is called. This
  // simulates a microcontroller where you can disable and re-disable global
  // interrupts anytime.
  sigfillset(&all);
  sigprocmask(SIG_BLOCK, &all, &temp_sigmask);

  // Now that interrupts are disabled, check to see if they were already
  // disabled or, if not, we need to save the previous mask in order to use
  // it to re-enable interrupts.
  if (interupts_enabled) {
    global_sigmask = temp_sigmask;
    interupts_enabled = FALSE;
  }
}

void __nesc_enable_interrupt(void) @safe() {
  // To re-enable interrupts, just apply the old sigmask we had before we
  // disabled interrupts.
  interupts_enabled = TRUE;
  sigprocmask(SIG_SETMASK, &global_sigmask, NULL);
}

__nesc_atomic_t __nesc_atomic_start(void) @spontaneous() @safe() {
  __nesc_atomic_t prev_state = interupts_enabled;
  __nesc_disable_interrupt();
  return prev_state;
}

void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts) @spontaneous() @safe() {
  if (reenable_interrupts) {
    __nesc_enable_interrupt();
  }
}

#endif
