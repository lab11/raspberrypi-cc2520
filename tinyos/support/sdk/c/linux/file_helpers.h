#ifndef __FILE_HELPERS_H__
#define __FILE_HELPERS_H__

// Makes the given file descriptor non-blocking.
// Returns 1 on success, 0 on failure.
int make_nonblocking (int fd);

#endif
