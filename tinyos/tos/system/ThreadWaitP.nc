
#include <pthread.h>
#include <stdio.h>

module ThreadWaitP {
  provides {
    interface ThreadWait;
    interface Init;
  }
}

implementation {

  pthread_mutex_t mutex_threadwait;
  pthread_cond_t cond_threadwait;

  command error_t Init.init () {
    pthread_mutex_init(&mutex_threadwait, NULL);
    pthread_cond_init(&cond_threadwait, NULL);
  }

  command void ThreadWait.wait () {

    struct timespec ts;

    pthread_mutex_lock(&mutex_threadwait);

    clock_gettime(CLOCK_REALTIME, &ts);
    ts.tv_sec += 5;
    pthread_cond_timedwait(&cond_threadwait, &mutex_threadwait, &ts);
   // pthread_cond_wait(&cond_threadwait, &mutex_threadwait);

    pthread_mutex_unlock(&mutex_threadwait);
  }

  command void ThreadWait.signalThread () {
   // pthread_mutex_lock(&mutex_threadwait);
    pthread_cond_signal(&cond_threadwait);
   // pthread_mutex_unlock(&mutex_threadwait);
  }

}
