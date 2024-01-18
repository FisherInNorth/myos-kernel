#include "kernel/include/types.h"
#include "kernel/include/stat.h"
#include "kernel/include/file.h"
#include "kernel/include/fcntl.h"
#include "xv6-user/user.h"


typedef struct{
  char* testname[20];
}sdfile;
static sdfile time_test[]; //1
static sdfile busybox[];
static sdfile time_test[] = {{{"time-test",0}}, {{0,0}},}; //1
static sdfile busybox[] = {{{"busybox" ,"echo", "#### independent command test" ,  0	}},
	{{"busybox" ,"ash", "-c", "exit" ,  0	}},
	{{"busybox" ,"sh", "-c", "exit" ,  0	}},
	{{"busybox" ,"basename", "/aaa/bbb" ,  0	}},
	{{"busybox" ,"cal" ,  0	}},
/*	{{"busybox" ,"clear" ,  0	}},
	{{"busybox" ,"date", 0	}},
	{{"busybox" ,"df", 0	}},
	{{"busybox" ,"dirname", "/aaa/bbb" ,  0	}},
	{{"busybox" ,"dmesg", 0	}},
	{{"busybox" ,"du" ,  0	}},
	{{"busybox" ,"expr", "1", "+", "1" ,  0	}},
	{{"busybox" ,"false" ,  0	}},
	{{"busybox" ,"true" ,  0	}},
	{{"busybox" ,"which", "ls" ,  0	}},
	{{"busybox" ,"uname" ,  0	}},
	{{"busybox" ,"uptime" ,  0	}},
	{{"busybox" ,"printf", "abc\n" ,  0	}},
	{{"busybox" ,"ps" ,  0	}},
	{{"busybox" ,"pwd" ,  0	}},
	{{"busybox" ,"free" ,  0	}},
	{{"busybox" ,"hwclock" ,  0	}},
	{{"busybox" ,"kill", "10" ,  0	}},
	{{"busybox" ,"ls" ,  0	}},
	{{"busybox" ,"sleep", "1" ,  0	}},
	{{"busybox" ,"echo", "#### file opration test" ,  0	}},
	{{"busybox" ,"touch", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "hello world", ">", "test.txt" ,  0	}},
	{{"busybox" ,"cat", "test.txt" ,  0	}},
	{{"busybox" ,"cut", "-c", "3", "test.txt" ,  0	}},
	{{"busybox" ,"od", "test.txt" ,  0	}},
	{{"busybox" ,"head", "test.txt" ,  0	}},
	{{"busybox" ,"tail", "test.txt",  0	}},
	{{"busybox" ,"hexdump", "-C", "test.txt", 0	}},
	{{"busybox" ,"md5sum", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "ccccccc", ">>", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "bbbbbbb", ">>", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "aaaaaaa", ">>", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "2222222", ">>", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "1111111", ">>", "test.txt" ,  0	}},
	{{"busybox" ,"echo", "bbbbbbb", ">>", "test.txt" ,  0	}},
	{{"busybox" ,"sort", "test.txt", "|", "./busybox", "uniq" ,  0	}},
	{{"busybox" ,"stat", "test.txt" ,  0	}},
	{{"busybox" ,"strings", "test.txt", 0	}},
	{{"busybox" ,"wc", "test.txt" ,  0	}},
	{{"busybox" ,"[", "-f", "test.txt", "]" ,  0	}},
	{{"busybox" ,"more", "test.txt" ,  0	}},
	{{"busybox" ,"rm", "test.txt" ,  0	}},
	{{"busybox" ,"mkdir", "test_dir" ,  0	}},
	{{"busybox" ,"mv", "test_dir", "test" ,  0	}},
	{{"busybox" ,"rmdir", "test" ,  0	}},
	{{"busybox" ,"grep", "hello", "busybox_cmd.txt" ,  0	}},
	{{"busybox" ,"cp", "busybox_cmd.txt", "busybox_cmd.bak" ,  0	}},
	{{"busybox" ,"rm", "busybox_cmd.bak" ,  0	}},
	{{"busybox" ,"find", "-name", "busybox_cmd.txt"  ,0	}},*/
	{{ 0 , 0				}},
  }; //1