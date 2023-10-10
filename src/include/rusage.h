#ifndef __RUSAGE_H
#define __RUSAGE_H

#include "types.h"
#include "spinlock.h"
#include "timer.h"
#define	RUSAGE_SELF			0
#define	RUSAGE_CHILDREN		(-1)
#define	RUSAGE_THREAD		1
struct rusage {
  struct timeval ru_utime; /* user CPU time used */
  struct timeval ru_stime; /* system CPU time used */
  long   ru_maxrss;        /* maximum resident set size */
  long   ru_ixrss;         /* integral shared memory size */
  long   ru_idrss;         /* integral unshared data size */
  long   ru_isrss;         /* integral unshared stack size */
  long   ru_minflt;        /* page reclaims (soft page faults) */
  long   ru_majflt;        /* page faults (hard page faults) */
  long   ru_nswap;         /* swaps */
  long   ru_inblock;       /* block input operations */
  long   ru_oublock;       /* block output operations */
  long   ru_msgsnd;        /* IPC messages sent */
  long   ru_msgrcv;        /* IPC messages received */
  long   ru_nsignals;      /* signals received */
  long   ru_nvcsw;         /* voluntary context switches */
  long   ru_nivcsw;        /* involuntary context switches */
};


#endif
