#include <signal.h>

typedef void (*sighandler_t)(int);

void signal_wrapper(int s, void*p ) {
	signal(s, (sighandler_t) p);
}