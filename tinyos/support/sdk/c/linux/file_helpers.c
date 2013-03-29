#include <unistd.h>
#include <fcntl.h>

#include "file_helpers.h"

// Makes the given file descriptor non-blocking.
// Returns 1 on success, 0 on failure.
int make_nonblocking (int fd) {
int flags, ret;

flags = fcntl(fd, F_GETFL, 0);
if (flags == -1) {
  return 0;
}
// Set the nonblocking flag.
flags |= O_NONBLOCK;
ret = fcntl(fd, F_SETFL, flags);

return ret != -1;
}

