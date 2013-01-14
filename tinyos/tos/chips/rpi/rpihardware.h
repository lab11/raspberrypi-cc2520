
#ifndef __DEBIAN_HARDWARE_H__
#define __DEBIAN_HARDWARE_H__

typedef uint8_t mcu_power_t;
typedef bool __nesc_atomic_t;

__nesc_atomic_t __nesc_atomic_start(void);
void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts);

void __nesc_disable_interrupt(void) @safe()
{
 // dint();
  //nop();
}

void __nesc_enable_interrupt(void) @safe()
{
 // eint();
}

/* @spontaneous() functions should not be included when NESC_BUILD_BINARY
   is #defined, to avoid duplicate functions definitions when binary
   components are used. Such functions do need a prototype in all cases,
   though. */
__nesc_atomic_t __nesc_atomic_start(void) @spontaneous() @safe()
{
//  __nesc_atomic_t result = ((READ_SR & SR_GIE) != 0);
//  __nesc_disable_interrupt();
//  asm volatile("" : : : "memory"); /* ensure atomic section effect visibility */
  return 0;
}

void __nesc_atomic_end(__nesc_atomic_t reenable_interrupts) @spontaneous() @safe()
{
//  asm volatile("" : : : "memory"); /* ensure atomic section effect visibility */
//  if( reenable_interrupts )
//    __nesc_enable_interrupt();
}



#endif


