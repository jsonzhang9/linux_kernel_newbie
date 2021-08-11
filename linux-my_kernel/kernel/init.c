#include "init.h"
#include "print.h"
#include "interrupt.h"
#include "timer.h"
#include "memory.h"
#include "thread.h"
#include "console.h"
#include "keyboard.h"
#include "tss.h"
#include "ide.h"
#include "syscall-init.h"
#include "fs.h"
//负责所有初始化工作
void init_all(){
	put_str("init_all\n");
	idt_init();  //初始化中断
	mem_init();
	thread_init();
	timer_init();
	console_init();
	keyboard_init();
	tss_init();
	syscall_init();
	intr_enable();  //后面的ide_init需要打开中断
	ide_init();
	filesys_init();
}
