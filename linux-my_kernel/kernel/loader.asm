%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR
LOADER_STACK_TOP equ LOADER_BASE_ADDR

;构建GDT及其内部描述符
GDT_BASE: dd 0x00000000
	  dd 0x00000000
CODE_DESC: dd 0x0000ffff
	   dd DESC_CODE_HIGH4
DATA_STACK_DESC: dd 0x0000ffff
	         dd DESC_DATA_HIGH4
VIDEO_DESC: dd 0x80000007 ;limit=(0xbffff-0xb8000)/4K=0x7
	    dd DESC_VIDEO_HIGH4  ;此时DPL为0

GDT_SIZE equ $ - GDT_BASE
GDT_LIMIT equ GDT_SIZE - 1 
;----------------------------------------
times 60 dq 0   ;此处预留60个描述符空位
;---------------------------------------
SELECTOR_CODE equ (0x0001 << 3) + TI_GDT + RPL0  ;相当于(CODE_DESC - GDT_BASE) / 8 + TI_GDT + RPL0
SELECTOR_DATA equ (0x0002 << 3) + TI_GDT + RPL0  
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0  

;-------------------------------------------------------------------
;这里是提前定义好存放内存大小的位置，本环节要由bios中断检测可用内存

total_mem_bytes dd 0

;以下是GDT的指针，前两字节是GDT界限，后四字节是GDT地址

gdt_ptr dw GDT_LIMIT
 	dd GDT_BASE
;这里是人工对齐256字节，上面GDT定义部分一共占512字节，total_mem_bytes占4字节，gdt_ptr占6字节，所以设置ards_buf=244 , ards_nr=2,加和共256字节
ards_buf times 244 db  0
ards_nr dw 0


;--------------------------------
;loadermsg db '2 loader in real'
;--------------------------------
loader_start:

;==========这一部分先不要了============================
;;---------------------------------------------
;;INT 0x10   功能号：0x13  功能描述：打印字符串
;;----------------------------------------------
;;输入：
;;AH 子功能号：13H
;;BH = 页码
;;BL = 属性 （若AL = 00H或01H）
;;CX = 字符串长度
;;(DH,DL)坐标（行，列）
;;ES:BP = 字符串地址
;;AL = 显示输出方式
;;  0————字符串中只含显示字符，属性在BL中
;;       显示后，光标位置不变
;;  1————字符串中只含显示字符，属性在BL中
;;       显示后，光标位置变化
;;  2————字符串中含显示字符和属性，显示后，光标位置不变
;;  3————字符串中含显示字符和属性，显示后，光标位置改变
;;无返回值
;
;	mov sp, LOADER_BASE_ADDR 
;	mov bp, loadermsg  ;ES：BP字符串地址
;	mov cx, 17         ;CX 字符串长度
;	mov ax, 0x1301     ;AH 子功能号13H ，AL显示输出方式01H
;	mov bx, 0x001f     ;页号为0（BH=0） ，蓝底粉色字1fh
;	mov dx, 0x1800     
;
;	int 0x10           ;10h号中断
;=============================================================

;int 15h 子功能=0xe820  eax=0x0000e820  ebx=0 ecx=ards结构大小 edx=0x534d4150h

	xor ebx, ebx
	mov edx, 0x534d4150
	mov di, ards_buf
.e820_mem_get_loop:
	mov eax, 0x0000e820
	mov ecx, 20
	int 15h
	jc .e820_failed_so_try_e801

	add di, cx
	inc word [ards_nr]
	cmp ebx, 0
	jnz .e820_mem_get_loop
;循环所有ARDS，找到最大的那个（用冒泡排序），最大的那个就是可用内存
	mov cx, [ards_nr]
	mov ebx, ards_buf
	xor edx, edx       ;edx为最大内存容量
.find_max_mem_area:
	mov eax, [ebx]
	add eax, [ebx+8]
	add ebx, 20
	cmp edx, eax
 	jge .next_ards
	mov edx, eax
.next_ards:
	loop .find_max_mem_area
	jmp .mem_get_ok
.e820_failed_so_try_e801:
	mov ax, 0xe801
	int 15h
	jc .e801_failed_so_try_0x88
	mov cx, 0x400
	mul cx
	shl edx, 16
	and eax, 0x0000ffff
	or edx, eax
	add edx, 0x100000
	mov esi, edx

	xor eax, eax
	mov ax, bx
	mov ecx, 0x10000
	mul ecx
	add esi, eax
	mov edx, esi
	jmp .mem_get_ok
.e801_failed_so_try_0x88:
	mov ah, 0x88
	int 15h
	jc .error_hlt
	and eax, 0x0000ffff
	mov cx, 0x400
	mul cx
	shl edx, 16
	or edx, eax
	add edx, 0x100000
	jmp .mem_get_ok
.error_hlt:
	mov byte [gs:0], 'e'
	mov byte [gs:2], 'r'
	mov byte [gs:4], 'r'
	mov byte [gs:6], 'o'
	mov byte [gs:8], 'r'
	jmp $
.mem_get_ok:
	mov [total_mem_bytes],  edx
;将内存数量转换为字节单位后存入内存


;-----------------准备进入保护模式---------------------
;1、打开A20
;2、加载GDT
;3、PE位置零
  ;---------------打开A20------------------------------
  in al, 0x92
  or al, 0000_0010b
  out 0x92, al
  ;--------------加载GDT-------------------------------
  lgdt [gdt_ptr]
  ;--------------PE位置1-------------------------------
  mov eax, cr0
  or eax, 0x00000001
  mov cr0, eax

  jmp dword SELECTOR_CODE:p_mode_start   ;刷新流水线


[bits 32]
p_mode_start:
	mov ax, SELECTOR_DATA
	mov ds, ax
	mov es, ax
	mov ss, ax
	mov esp, LOADER_STACK_TOP
	mov ax, SELECTOR_VIDEO
	mov gs, ax


;-----------load the kernel----------------------------------
	mov eax, KERNEL_START_SECTOR  ;kernel.bin在硬盘中的扇区号
	mov ebx, KERNEL_BIN_BASE_ADDR  ;从磁盘读出后，写入到ebx指定的地址
	mov ecx, 200   ;读入的扇区数

	call rd_disk_m32

;-----------创建页目录及页表，初始化页内存位图----------------
call setup_page
	sgdt [gdt_ptr]     ;将描述符表地址和界限写入内存，一会儿用新地址加载
	;将gdt描述符中的视频段描述符中的段基址加0xc0000000
	mov ebx, [gdt_ptr + 2]  
	or dword [ebx + 0x18 + 4], 0xc0000000   ;视频段描述符是第三个描述符，每个描述符8字节，故0x18
	;将GDT的基址加上0xc0000000使其成为内核所在的高地址
	add dword [gdt_ptr + 2], 0xc0000000
	add esp, 0xc0000000   ;栈也映射到高地址
	;页目录表地址交给cr3
	mov eax, PAGE_DIR_TABLE_POS
	mov cr3, eax
	;打开cr0的pg位
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax
	;在开启分页后，用GDT新地址重新加载
	lgdt [gdt_ptr]
	jmp SELECTOR_CODE:enter_kernel
enter_kernel:
	call kernel_init
	mov esp, 0xc009f000
	jmp KERNEL_ENTRY_POINT

;--------create page direction entry and page table entry--------------------
setup_page:
	mov ecx, 4096
	mov esi, 0
.clear_page_dir:
	mov byte [PAGE_DIR_TABLE_POS + esi], 0
	inc esi
	loop .clear_page_dir
;---------------下面开始创建页目录项---------------------------------------
.create_pde:
	mov eax, PAGE_DIR_TABLE_POS
	add eax, 0x1000
	mov ebx, eax
;下面将页目录项0和页目录项0xc00都填入第一个页表的地址
	or eax, PG_US_U | PG_RW_W | PG_P      ;写入第一个页表的物理地址及其属性
	mov [PAGE_DIR_TABLE_POS + 0x0], eax   ;在页目录表的第一个页目录项填入第一个页表的地址
	mov [PAGE_DIR_TABLE_POS + 0xc00], eax 
	sub eax, 0x1000
	mov [PAGE_DIR_TABLE_POS + 4092], eax ;使最后一个页目录项指向页目录表自己
;下面创建页表项
	mov ecx, 256   ;1M低端内存/4K=256
	mov esi, 0
	mov edx, PG_US_U | PG_RW_W | PG_P
.create_pte:
	mov [ebx+esi*4], edx
	add edx, 4096
	inc esi
	loop .create_pte
;创建内核其他页表的PTE
	mov eax, PAGE_DIR_TABLE_POS
	add eax, 0x2000  ;指向第二个页表位置
	or eax, PG_US_U | PG_RW_W | PG_P ;属性为7
	mov ebx, PAGE_DIR_TABLE_POS
	mov ecx, 254  ;范围为769~1022的所有目录项数量
	mov esi, 769
.create_kernel_pde:
	mov [ebx+esi*4], eax
	inc esi
	add eax, 0x1000
	loop .create_kernel_pde
	ret

;------------------------------------initial kernel------------------------------------------------
kernel_init:
	xor eax, eax
	xor ebx, ebx   ;ebx记录程序头表地址
	xor ecx, ecx   ;cx记录程序头表中的program header的数量
	xor edx, edx   ;edx记录program header的尺寸,即e_phentsize

	mov dx, [KERNEL_BIN_BASE_ADDR + 42]  ;偏移文件42字节处是e_phentsize
	mov ebx, [KERNEL_BIN_BASE_ADDR + 28]  ;偏移文件28字节处是e_phoff ,表示第一个program header在文件中的偏移量
	;其实该值应该是0x34,不过应该谨慎一点，来这里读取实际值
	add ebx, KERNEL_BIN_BASE_ADDR 
	mov cx, [KERNEL_BIN_BASE_ADDR + 44]
	;偏移文件44的位置是e_phnum,表示有几个program header

.each_segment:
	cmp byte [ebx + 0], PT_NULL   ;若p_type等于PT_NULL,说明此program header未使用
	je .PTNULL   ;为函数memcpy压入参数，参数是从右往左压的
	;函数原型类似于memcpy(dst,src,size)
	push dword [ebx + 16]
	;program header中偏移16字节的是p_filesz
	;压入函数memcpy的第三个参数size
	mov eax, [ebx + 4]  ;距离程序头四个字节的是p_offset
	add eax, KERNEL_BIN_BASE_ADDR ;加上kernel.bin被加载到的物理地址，eax为该段的物理地址
	push eax    ;压入函数memcpy的第二个参数，源地址
	push dword [ebx + 8]  ;压入该函数的第一个参数，目的地址
	
	call mem_cpy
	add esp, 12
.PTNULL:
	add ebx, edx   ;edx为program header大小，即e_phentsize
			;在此ebx指向下一个program header
	loop .each_segment

;--------------------逐字节拷贝------------------------------
;函数memcpy(dst, src, size)
;栈中三个参数(dst,src, size)
;输出：无
mem_cpy:
	cld 
	push ebp
	mov ebp, esp
	push ecx    ;rep指令用到了ecx，但是ecx对于外层段的循坏还有用，故先入栈备份

	mov edi, [ebp + 8]
	mov esi, [ebp + 12]
	mov ecx, [ebp + 16]
	rep movsb
	;恢复环境
	pop ecx
	pop ebp
	ret

;------------------------protection model read disk-------------------------------
rd_disk_m32:	
	mov esi, eax
	mov di, cx
	mov dx, 0x1f2
	mov al, cl
	out dx, al
	mov eax, esi
	mov dx, 0x1f3
	out dx, al
	mov cl, 8
	shr eax, cl
	mov dx, 0x1f4
	out dx, al
	shr eax, cl
	mov dx, 0x1f5
	out dx, al
	shr eax, cl
	and al, 0x0f
	or al, 0xe0
	mov dx, 0x1f6
	out dx, al
	mov dx, 0x1f7
	mov al, 0x20
	out dx, al
.not_ready:
	nop
	in al, dx
	and al, 0x88
	cmp al, 0x08
	jnz .not_ready

	mov ax, di
	mov dx, 256
	mul dx
	mov cx, ax
	mov dx, 0x1f0

.go_on_read:
 	in ax, dx
	mov [ds:ebx], ax
	add ebx, 2
	loop .go_on_read
	ret
