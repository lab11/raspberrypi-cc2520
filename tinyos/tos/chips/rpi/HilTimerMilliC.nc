
/**
 * HilTimerMilliC provides a parameterized interface to a virtualized
 * millisecond timer.  TimerMilliC in tos/system/ uses this component to
 * allocate new timers.
 *
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 * @see  Please refer to TEP 102 for more information about this component and its
 *          intended use.
 */

configuration HilTimerMilliC
{
  provides interface Init;
  provides interface Timer<TMilli> as TimerMilli[ uint8_t num ];
  provides interface LocalTime<TMilli>;
}
implementation
{
  components new AlarmMilli32P();
  components new AlarmToTimerC(TMilli);
  components new VirtualizeTimerC(TMilli,uniqueCount(UQ_TIMER_MILLI));
  components new CounterToLocalTimeC(TMilli);
  components LocalTimeMilli32P;

  Init = AlarmMilli32P;
  TimerMilli = VirtualizeTimerC;
  LocalTime = LocalTimeMilli32P;

  VirtualizeTimerC.TimerFrom -> AlarmToTimerC;
  AlarmToTimerC.Alarm -> AlarmMilli32P;

//  CounterToLocalTimeC.Counter -> CounterMilli32C;

/*
  components new AlarmMilli32C();
  components new AlarmToTimerC(TMilli);
  components new VirtualizeTimerC(TMilli,uniqueCount(UQ_TIMER_MILLI));
  components new CounterToLocalTimeC(TMilli);
  components CounterMilli32C;

  Init = AlarmMilli32C;
  TimerMilli = VirtualizeTimerC;
  LocalTime = CounterToLocalTimeC;

  VirtualizeTimerC.TimerFrom -> AlarmToTimerC;
  AlarmToTimerC.Alarm -> AlarmMilli32C;
  CounterToLocalTimeC.Counter -> CounterMilli32C;
*/
}
