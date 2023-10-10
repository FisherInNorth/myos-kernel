#include"user.h"
#include"include/elf.h"
//static char teststr[]="ABCD\n";
static char* tim[] = {"./test_all.sh", 0};
void test_time();
//static char *args[] = {"/mytest.sh",0};

int main(int argc, char* argv[]){
  test_time();
//  test_busybox();
//  test_lua();
//  test_lmbench();
  exit(0);
  return 0;
}

void test_time(){
  int status;
  int pid = fork();
  if(pid==0){
    exec("./test_all.sh", tim);
  }
  wait4(pid,&status);
}
