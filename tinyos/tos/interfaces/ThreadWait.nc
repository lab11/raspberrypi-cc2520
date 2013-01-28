
interface ThreadWait {
  // Blocking wait for a thread or event to put something on the task queue
  command void wait ();

  // Active the main thread to check the task queue
  command void signalThread ();
}
