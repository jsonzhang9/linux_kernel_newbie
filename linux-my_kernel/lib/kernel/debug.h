#ifndef _KERNEL_DEBUG_H
#define _KERNEL_DEBUG_H
void panic_spin(char* filename, int line, const char* func, const char* condition);
/***************_VA_ARGS_**************************
 * _VA_ARGS_是预处理器支持的专用标识符。
 * 代表所有与省略号相对应的参数
 * “.......”表示定义的宏参数可变*/
#define PANIC(...) panic_spin (__FILE__, __LINE__, __func__, __VA_ARGS__)
#ifdef NDEBUG
	#define ASSERT(CONDITION) ((void)0)
#else
#define ASSERT(CONDITION) \
if(CONDITION){}else{ \
PANIC(#CONDITION);}
#endif
#endif

