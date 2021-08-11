#ifndef _THREAD_SYNC_H
#define _THREAD_SYNC_H

#include "list.h"
#include "stdint.h"
#include "thread.h"

//信号量结构
struct semaphore {
	uint8_t value;
	struct list waiters;
};
//锁结构
struct lock{
	struct task_struct* holder;  //锁的持有者
	struct semaphore semaphore;  //用二元信号量实现锁
	uint32_t holder_repeat_nr;  //锁的持有者重复申请锁的次数
};
#endif
