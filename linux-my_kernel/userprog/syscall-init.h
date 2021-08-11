#ifndef __USERPROG_SYSCALLINT_H
#define __USERPROG_SYSCALLINT_H
#include "stdint.h"
void syscall_init(void);
uint32_t sys_getpid(void);
uint32_t syswrite(char* str);
#endif 
