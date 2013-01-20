
#ifndef __DEBIAN_HARDWARE_H__
#define __DEBIAN_HARDWARE_H__

#include <pthread.h>

typedef uint8_t mcu_power_t;
typedef bool __nesc_atomic_t;

pthread_mutex_t atomic_lock;
pthread_mutexattr_t mta;
bool is_init = FALSE;

__nesc_atomic_t __nesc_atomic_start(void);
void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts);

// NOTE: In this code we're checking if the mutex is initialized many
// times a second. It might be better to factor this out into a boot-time
// initialization routine.
// TODO: Refactor the checks for init out.
void __nesc_disable_interrupt(void) @safe()
{
	if (!is_init) {
		pthread_mutexattr_init(&mta);
		pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE);
		pthread_mutex_init(&atomic_lock, &mta);
	}

	pthread_mutex_lock(&atomic_lock);
}

void __nesc_enable_interrupt(void) @safe()
{
	if (!is_init) {
		pthread_mutexattr_init(&mta);
		pthread_mutexattr_settype(&mta, PTHREAD_MUTEX_RECURSIVE);
		pthread_mutex_init(&atomic_lock, &mta);
	}

	pthread_mutex_unlock(&atomic_lock);
}

/* @spontaneous() functions should not be included when NESC_BUILD_BINARY
   is #defined, to avoid duplicate functions definitions when binary
   components are used. Such functions do need a prototype in all cases,
   though. */
__nesc_atomic_t __nesc_atomic_start(void) @spontaneous() @safe()
{
  __nesc_disable_interrupt();
  return 1;
}

void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts) @spontaneous() @safe()
{
  __nesc_enable_interrupt();
}



#endif


