
interface IO {
  // Add a file descriptor to the select() call
  command error_t register (int file_descriptor);

  // Event that is triggered when data is ready on this io file
  event void receiveReady ();
}
