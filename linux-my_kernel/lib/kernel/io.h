/*--------------------------------------------
 * machine mode
 * b -- 输出寄存器QImode的名称，即寄存器中的最低8位：[a-d]l
 * w -- 输出寄存器HImode的名称，即寄存器中两个字节的部分，如[a-d]x
 * HImode    "half Integer"模式，表示两个字节的整数
 * QImode    “quarter Integer”模式，表示一个字节的整数
 */
#ifndef _LIB_IO_H
#define _LIB_IO_H
#include "stdint.h"
//向端口port写入一个字节
static inline void outb(uint16_t port, uint8_t data){
	//对端口指定N为0~255，d表示用dx储存端口号
	//%b0表示对应al，%wl表示对应dx
	asm volatile ("outb %b0, %w1" : : "a" (data), "Nd" (port));
}
//将addr处的word_cnt个字写入端口port
static inline void outsw(uint16_t port, const void* addr, uint32_t word_cnt){
	//+表示此限制既做输入，也做输出
	//outsw是将ds：esi处的16位内容写入port端口
	asm volatile ("cld; rep outsw" : "+S" (addr),"+c"(word_cnt):"d"(port));
}
//从端口读一个字节返回
static inline uint8_t inb(uint16_t port){
	uint8_t data;
	asm volatile ("inb %w1, %b0":"=a"(data):"Nd"(port));
	return data;
}
//将从端口读入的word_cnt个字写入addr处
static inline void insw(uint16_t port, void* addr, uint32_t word_cnt){
	asm volatile ("cld; rep insw": "+D" (addr),"+c"(word_cnt):"d" (port):"memory");
}
#endif
