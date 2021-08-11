;在该文件中，要实现使用宏打印32个中断地址，给出中断选择子和中断在内存中的地址
[bits 32]
%define ERROR_CODE nop
%define ZERO push 0   ;如果有ERROR码，则什么都不做，若没有，则压入一个0，保持占位
extern idt_table 

section .data
global intr_entry_table
intr_entry_table:
	
	%macro VECTOR 2
	section .text
	intr%1entry:
	%2
	push ds
	push es
	push fs
	push gs
	pushad
	
	;如果从片进入的中断，除了往从片送EOI外，还要给主片送
	mov al, 0x20  ;中断结束命令
	out 0xa0, al   ;送从片
	out 0x20, al   ;送主片

	push %1   ;不管idt_table中的目标程序是否需要参数，一律压入中断向量号
	call [idt_table + %1*4]
	jmp intr_exit
	
section .data
	dd intr%1entry     ;储存各个中断入口的地址,形成intr_entry_table数组
  	%endmacro
section .text
global intr_exit
intr_exit:
;恢复上下文
	add esp, 4   ;跳过中断号
	popad
	pop gs
	pop fs
	pop es
	pop ds
	add esp, 4
	iretd


VECTOR 0x00, ZERO
VECTOR 0x01, ZERO
VECTOR 0x02, ZERO
VECTOR 0x03, ZERO
VECTOR 0x04, ZERO
VECTOR 0x05, ZERO
VECTOR 0x06, ZERO
VECTOR 0x07, ZERO
VECTOR 0x08, ERROR_CODE
VECTOR 0x09, ZERO
VECTOR 0x0a, ERROR_CODE
VECTOR 0x0b, ERROR_CODE
VECTOR 0x0c, ZERO
VECTOR 0x0d, ERROR_CODE
VECTOR 0x0e, ERROR_CODE 
VECTOR 0x0f, ZERO
VECTOR 0x10, ZERO
VECTOR 0x11, ERROR_CODE
VECTOR 0x12, ZERO
VECTOR 0x13, ZERO
VECTOR 0x14, ZERO
VECTOR 0x15, ZERO
VECTOR 0x16, ZERO
VECTOR 0x17, ZERO
VECTOR 0x18, ERROR_CODE 
VECTOR 0x19, ZERO
VECTOR 0x1a, ERROR_CODE 
VECTOR 0x1b, ERROR_CODE 
VECTOR 0x1c, ZERO
VECTOR 0x1d, ERROR_CODE 
VECTOR 0x1e, ERROR_CODE 
VECTOR 0x1f, ZERO
VECTOR 0x20, ZERO       ;时钟中断对应入口
VECTOR 0x21, ZERO	;键盘中断对应入口
VECTOR 0x22, ZERO	;级联用
VECTOR 0x23, ZERO	;串口2对应的入口
VECTOR 0x24, ZERO	;串口1对应的入口
VECTOR 0x25, ZERO	;并口2对应的入口
VECTOR 0x26, ZERO	;软盘对应的入口
VECTOR 0x27, ZERO	;并口1对应的入口
VECTOR 0x28, ZERO	;定时时钟对应的入口
VECTOR 0x29, ZERO	;重定向
VECTOR 0x2a, ZERO	;保留
VECTOR 0x2b, ZERO	;保留
VECTOR 0x2c, ZERO	;/ps/2鼠标
VECTOR 0x2d, ZERO	;fpu浮点单元异常
VECTOR 0x2e, ZERO	;硬盘
VECTOR 0x2f, ZERO	;保留

;;;;;;;;;;0x80号中断;;;;;;;;;;;;;;
[bits 32]
extern syscall_table
section .text
global syscall_handler
syscall_handler:
	;1 保存上下文环境
	push 0
	push ds
	push es
	push fs
	push gs
	pushad
	push 0x80
	;2 为系统调用子功能传入参数
	push edx
	push ecx
	push ebx
	;3 调用子功能处理函数
	call [syscall_table + eax * 4]
	add esp, 12
	;4 将call调用后的返回值存入当前的内核栈中eax的位置
	mov [esp + 8 * 4], eax
	jmp intr_exit
