TI_GDT equ 0
RPL0 equ 0
SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

;[bits 32]
section .data
put_int_buffer dq 0
[bits 32]
section .text;section .text
;---------------------------------------------
;put_str通过调用put_char来实现字符串打印
;---------------------------------------------
;输入：栈中参数为打印的字符串
;输出：无

global put_str
put_str:
;由于本函数中只用到了ebx和ecx，只需备份这两个
	push ebx
	push ecx
	xor ecx, ecx
	mov ebx, [esp + 12]
.goon:
	mov cl, [ebx]
	cmp cl, 0
	jz .str_over
	push ecx
	call put_char
	add esp, 4
	inc ebx
	jmp .goon
.str_over:
	pop ecx
	pop ebx
	ret


;--------------put_char------------------------
;功能描述：把栈中的一个字符写入光标所在处
;---------------------------------------------
global put_char
put_char:
	pushad       ;备份32位寄存器环境
	;需要保证gs中为正确的视频段选择子
	;为保险起见，每次打印时都为gs赋值
	mov ax, SELECTOR_VIDEO
	mov gs, ax
;---------------获取光标位置-----------------
	;先获得高8位
	mov dx, 0x03d4   ;索引寄存器
	mov al, 0x0e     ;用于提供光标位置的高8位
	out dx, al
	mov dx, 0x03d5   ;通过读写数据端口0x03d5来获得或设置光标位置
	in al, dx        ;得到了光标位置的高8位
	mov ah, al
	;再获取低8位
	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x3d5
	in al, dx
	;将光标存入bx
	mov bx, ax
	;下面这行为在栈中获得待打印的字符
	mov ecx, [esp + 36]  ;pushad压入8*4=32字节
	;加上主调函数的返回地址，故esp + 36
	cmp cl, 0xd          ;CR是0x0d，LF是0x0a
	jz .is_carriage_return
	cmp cl, 0xa          
	jz .is_line_feed
	cmp cl, 0x8         ; BS的asc码是8
	jz .is_backspace
	jmp .put_other

.is_backspace:
	dec bx 
	shl bx, 1
	mov byte [gs:bx], 0x20
	inc bx
	mov byte [gs:bx], 0x07
	shr bx, 1   ;这里出了错，很烦，卡了很久
	jmp .set_cursor
.put_other:
	shl bx, 1
	mov [gs:bx], cl
	inc bx
	mov byte [gs:bx], 0x07
	shr bx, 1
	inc bx
	cmp bx, 2000
	jl .set_cursor
.is_line_feed:
.is_carriage_return:
	xor dx, dx
	mov ax, bx
	mov si, 80

	div si

	sub bx, dx
.is_carriage_return_end:
	add bx, 80
	cmp bx, 2000
.is_line_feed_end:
	jl .set_cursor
.roll_screen:
	cld
	mov ecx, 960
	mov esi, 0xc00b80a0
	mov edi, 0xc00b8000
	rep movsd

	mov ebx, 3840
	mov ecx, 80
.cls:
	mov word [gs:ebx], 0x0720
	add ebx, 2
	loop .cls
	mov bx, 1920
.set_cursor:
	mov dx, 0x3d4
	mov al, 0x0e
	out dx, al
	mov dx, 0x3d5
	mov al, bh
	out dx, al 
	
	mov dx, 0x3d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x3d5
	mov al, bl
	out dx, al
.put_char_done:
	popad
	ret


;-----------------------------------------------
;将小端字节序的数字转换为ascii码后，倒置
;----------------------------------------------
;输入：栈中参数为待打印的数字
;输出：在屏幕上打印十六进制的数字，并不会打印前缀0x
;--------------------------------------------------------
global put_int
put_int:
	pushad
	mov ebp, esp
	mov eax, [ebp + 4*9]
	mov edx, eax
	mov edi, 7
	mov ecx, 8
	mov ebx, put_int_buffer
;将32位数字按照十六进制的形式从低到高逐个处理
;共处理8个十六进制数字
.16based_4bits:
	and edx, 0x0000000f
	cmp edx, 9
	jg .is_A2F
	add edx, '0'
	jmp .store
.is_A2F:
	sub edx, 10
	add edx, 'A'
.store:
	mov [ebx + edi], dl
	dec edi
	shr eax, 4
	mov edx, eax
	loop .16based_4bits
.ready_to_print:
	inc edi
.skip_prefix_0:
	cmp edi, 8
	je .full0
.go_on_skip:
	mov cl, [put_int_buffer+edi]
	inc edi
	cmp cl, '0'
	je .skip_prefix_0
	dec edi
	jmp .put_each_num
.full0:
	mov cl, '0'
.put_each_num:
	push ecx
	call put_char
	add esp, 4
	inc edi
	mov cl, [put_int_buffer + edi]
	cmp edi, 8
	jl .put_each_num
	popad
	ret
global set_cursor
set_cursor:
	pushad
	mov bx, [esp+36]
	mov dx, 0x03d4
	mov al, 0x0e
	out dx, al
	mov dx, 0x03d5
	mov al, bh
	out dx, al

	mov dx, 0x03d4
	mov al, 0x0f
	out dx, al
	mov dx, 0x03d5
	mov al, bl
	out dx, al
	popad
	ret
