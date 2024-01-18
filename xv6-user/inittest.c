// init: The initial user-level program

#include "test.h"


int
main(void)
{
    int pid, wpid;
    int i;
  // if(open("console", O_RDWR) < 0){
  //   mknod("console", CONSOLE, 0);
  //   open("console", O_RDWR);
  // }
    dev(O_RDWR, CONSOLE, 0);
    dup(0);  // stdout
    dup(0);  // stderr
//    printf("time-test\n");
    //start time-test
    pid = fork();
	  if(pid == 0){
		  exec("time-test",time_test[0].testname);
		  exit(0);
	  }
    wpid = wait((int *) 0);
      if(wpid == pid){
        // the shell exited; restart it.
      } else if(wpid < 0){
        printf("init: wait returned an error\n");
        exit(0);
      } else {
        // it was a parentless process; do nothing.
      }


    //start busybox
    i=0;
//    printf("busybox test\n");
    for(i = 0; busybox[i].testname[1]; i++){
      pid = fork();
      if(pid < 0){
        printf("busybox test %d failed \n", i);
        exit(0);
      }
      if(pid == 0){
        exec("busybox", busybox[i].testname);
        exit(0);
      }

    for(;;){
      // this call to wait() returns if the shell exits,
      // or if a parentless process exits.
      wpid = wait((int *) 0);
      if(wpid == pid){
        // the shell exited; restart it.
        break;
      } else if(wpid < 0){
        printf("init: wait returned an error\n");
        exit(1);
      } else {
        // it was a parentless process; do nothing.
      }
    }
  }
  exit(1);
}