
interface TimerQuery {
  // Get the number of milliseconds until the next timer should fire.
  command uint16_t nextTimerTime ();
}
