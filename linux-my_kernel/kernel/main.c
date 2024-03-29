#include "fs.h"
#include "print.h"
#include "interrupt.h"
#include "syscall-init.h" 
#include "init.h"
#include "syscall.h"
#include "ioqueue.h"
#include "keyboard.h"
#include "process.h"
#include "memory.h"
#include "stdio.h"
//void k_thread_a(void*);
//void k_thread_b(void*);
//void u_prog_a(void);
//void u_prog_b(void);
void init(void);
int main(void)
{
	put_str("I am kernel\n");
	init_all();
	int32_t a = sys_mkdir("/dir1/subdir1");
	if(a == 0){
	printf("/dir1/subdir1 create done!\n");
	}else{
		printf("/dir1/subfir1 create fail!\n");
	}
	int32_t b = sys_mkdir("/dir1");
	if(b == 0){
		printf("/dir1 create done!\n");
	}else{
		printf("/dir1 create fail!\n");
	}
	
	int32_t c = sys_mkdir("/dir1/subdir1");
	if(c == 0){
	printf("now, /dir1/subdir1 create done!\n");
	}else{
		printf("now, /dir1/subfir1 create fail!\n");
	}
	int fd = sys_open("/dir1/subdir1/file2", O_CREAT | O_RDWR);
	if(fd != -1){
		printf("/dir1/subdir1/file2 create done!\n");
		sys_write(fd, "Catch me if you can!\n", 21);
		sys_lseek(fd, 0, SEEK_SET);
		char buf[32] = {0};
		sys_read(fd, buf, 21);
		printf("/dir1/subdir1/file2 says: \n%s", buf);
		sys_close(fd);
	} 
//init进程
void init(void){
	uint32_t ret_pid = fork();
	if(ret_pid){
		printf("i am father, my pid is %d,child pid is %d\n", getpid(), ret_pid);
	}else{
		printf("i am child, my pid is %d, ret pid is %d\n", getpid(), ret_pid);
	}
	while(1);
}
//	intr_enable();
//	int32_t a = sys_unlink("/file1");
//	if(a == 0){
//		printf("/file1 delete done!\n");
//	}else{
//		printf("/file1 delete fail!\n");
//	}
//	uint32_t fd = sys_open("/file1", O_RDWR);
//	printf("open /file1, fd:%d\n", fd);
//	char buf[64] = {0};
//	int read_bytes = sys_read(fd, buf, 18);
//	printf("1_ read %d bytes:\n%s\n", read_bytes, buf);
//
//	memset(buf, 0, 64);
//	read_bytes = sys_read(fd, buf, 6);
//	printf("2_ read %d bytes:\n%s", read_bytes, buf);
//	memset(buf, 0, 64);
//	read_bytes = sys_read(fd, buf, 6);
//	printf("3_ read %d bytes:\n%s", read_bytes, buf);
//
//	printf("_______ close file1 and reopen ______\n");
//	sys_lseek(fd, 0, SEEK_SET);
//	memset(buf, 0, 64);
//	read_bytes = sys_read(fd, buf, 24);
//	printk("4_ read %d bytes:\n%s", read_bytes, buf);
////	process_execute(u_prog_a, "user_prog_a");
////	process_execute(u_prog_b, "user_prog_b");
//
////	thread_start("k_thread_a", 31, k_thread_a, "I am thread_a");	
////	thread_start("k_thread_b", 31, k_thread_b, "I am thread_b");	
////	uint32_t fd = sys_open("/file1", O_CREAT);
////	sys_close(fd);
////	fd = sys_open("/file1", O_RDWR);
////	printf("fd:%d\n", fd);
////	sys_write(fd, "hello,world\n", 12);
//	sys_close(fd);
////	printf("%d closed now\n", fd);
	while(1);
	return 0;
}
////在线程中运行的函数
//void k_thread_a(void* arg){
//	void* addr1 = sys_malloc(256);
//	void* addr2 = sys_malloc(255);
//	void* addr3 = sys_malloc(254);
//	console_put_str(" thread_a malloc addr:0x\n");
//	console_put_int((int)addr1);
//	console_put_char(',');
//	console_put_int((int)addr2);
//	console_put_char(',');
//	console_put_int((int)addr3);
//	console_put_char('\n');
//	int cpu_delay = 100000;
//	while(cpu_delay-- > 0);
//		sys_free(addr1);
//		sys_free(addr2);
//		sys_free(addr3);
//	while(1);
//}
//void k_thread_b(void* arg){
//	void* addr1 = sys_malloc(256);
//	void* addr2 = sys_malloc(255);
//	void* addr3 = sys_malloc(254);
//	console_put_str(" thread_b malloc addr:0x\n");
//	console_put_int((int)addr1);
//	console_put_char(',');
//	console_put_int((int)addr2);
//	console_put_char(',');
//	console_put_int((int)addr3);
//	console_put_char('\n');
//	int cpu_delay = 100000;
//	while(cpu_delay-- > 0);
//		sys_free(addr1);
//		sys_free(addr2);
//		sys_free(addr3);
//	while(1);
//}
//
//void u_prog_a(void){
//	void* addr1 = malloc(256);
//	void* addr2 = malloc(255);
//	void* addr3 = malloc(254);
//	printf(" prog_a malloc addr:0x%x, 0x%x, 0x%x\n", (int)addr1, (int)addr2, (int)addr3);
//
//	int cpu_delay = 100000;
//	while(cpu_delay-- > 0);
//	free(addr1);
//	free(addr2);
//	free(addr3);
//	while(1);
//}
//void u_prog_b(void){
//	void* addr1 = malloc(256);
//	void* addr2 = malloc(255);
//	void* addr3 = malloc(254);
//	printf(" prog_b malloc addr:0x%x, 0x%x, 0x%x\n", (int)addr1, (int)addr2, (int)addr3);
//
//	int cpu_delay = 100000;
//	while(cpu_delay-- > 0);
//	free(addr1);
//	free(addr2);
//	free(addr3);
//	while(1);
//}
