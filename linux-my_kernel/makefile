BUILD_DIR = ./build
ENTRY_POINT = 0xc0001500
AS = nasm
CC = gcc
LD = ld
LIB = -I lib/kernel/ -I lib/ -I kernel/ -I device/ -I lib/user -I thread/ -I userprog/ -I lib/user/ \
-I fs/
ASFLAGS = -f elf
CFLAGS = -m32 -mtune=i386 -Wall $(LIB) -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes
LDFLAGS = -m elf_i386 -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o $(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o \
$(BUILD_DIR)/print.o $(BUILD_DIR)/debug.o $(BUILD_DIR)/bitmap.o $(BUILD_DIR)/string.o $(BUILD_DIR)/memory.o \
$(BUILD_DIR)/thread.o $(BUILD_DIR)/switch.o $(BUILD_DIR)/list.o $(BUILD_DIR)/sync.o $(BUILD_DIR)/console.o \
$(BUILD_DIR)/keyboard.o $(BUILD_DIR)/ioqueue.o $(BUILD_DIR)/tss.o $(BUILD_DIR)/process.o $(BUILD_DIR)/syscall.o \
$(BUILD_DIR)/syscall-init.o $(BUILD_DIR)/stdio.o $(BUILD_DIR)/stdio-kernel.o $(BUILD_DIR)/ide.o \
$(BUILD_DIR)/fs.o $(BUILD_DIR)/file.o $(BUILD_DIR)/inode.o $(BUILD_DIR)/dir.o $(BUILD_DIR)/fork.o
AIM_DIR = /usr/local/share/doc/bochs
##################### c代码编译#############################
$(BUILD_DIR)/main.o: kernel/main.c lib/kernel/print.h  lib/kernel/init.h thread/thread.h device/console.h device/keyboard.h device/ioqueue.h \
lib/kernel/interrupt.h userprog/process.h userprog/syscall-init.h lib/user/syscall.h lib/kernel/memory.h \
lib/stdio.h lib/kernel/stdio-kernel.h fs/fs.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/init.o : kernel/init.c lib/kernel/init.h lib/kernel/print.h lib/stdint.h lib/kernel/interrupt.h device/timer.h \
lib/kernel/memory.h thread/thread.h device/console.h device/keyboard.h userprog/tss.h userprog/syscall-init.h \
lib/user/syscall.h userprog/process.h device/ide.h fs/fs.h lib/kernel/stdio-kernel.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/interrupt.o : kernel/interrupt.c lib/kernel/interrupt.h lib/kernel/print.h lib/stdint.h lib/kernel/global.h \
lib/kernel/io.h 
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/timer.o: device/timer.c device/timer.h lib/stdint.h lib/kernel/io.h lib/kernel/print.h thread/thread.h \
lib/kernel/interrupt.h lib/kernel/debug.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/debug.o : kernel/debug.c lib/kernel/debug.h lib/kernel/print.h lib/kernel/interrupt.h lib/stdint.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/bitmap.o : kernel/bitmap.c lib/stdint.h lib/kernel/debug.h lib/kernel/bitmap.h lib/kernel/interrupt.h \
lib/kernel/print.h lib/string.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/string.o : lib/string.c lib/string.h lib/kernel/global.h lib/kernel/debug.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/memory.o : kernel/memory.c lib/stdint.h lib/kernel/print.h lib/kernel/memory.h lib/kernel/bitmap.h lib/kernel/global.h lib/kernel/debug.h lib/string.h \
thread/sync.h  lib/kernel/interrupt.h 
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/thread.o : thread/thread.c lib/kernel/global.h lib/kernel/memory.h lib/string.h lib/stdint.h thread/thread.h \
fs/fs.h lib/kernel/interrupt.h lib/kernel/debug.h device/console.h userprog/process.h lib/stdio.h \
lib/kernel/print.h lib/kernel/memory.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/list.o : lib/kernel/list.c lib/kernel/list.h lib/kernel/interrupt.h lib/kernel/global.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/sync.o : thread/sync.c thread/sync.h lib/kernel/list.h lib/kernel/global.h lib/kernel/debug.h\
lib/kernel/interrupt.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/console.o : device/console.c device/console.h lib/kernel/print.h lib/stdint.h thread/sync.h thread/thread.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/keyboard.o : device/keyboard.c device/keyboard.h lib/kernel/print.h lib/kernel/interrupt.h lib/kernel/io.h lib/kernel/global.h \
device/ioqueue.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/ioqueue.o : device/ioqueue.c device/ioqueue.h lib/kernel/interrupt.h lib/kernel/global.h lib/kernel/debug.h	
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/tss.o : userprog/tss.c lib/stdint.h lib/kernel/print.h lib/kernel/global.h lib/string.h \
userprog/tss.h 
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/process.o : userprog/process.c userprog/process.h lib/kernel/debug.h userprog/tss.h lib/kernel/global.h lib/stdint.h lib/kernel/interrupt.h \
device/console.h lib/kernel/list.h lib/kernel/memory.h lib/string.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/syscall.o : lib/user/syscall.c lib/user/syscall.h lib/kernel/print.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/syscall-init.o : userprog/syscall-init.c lib/stdint.h lib/user/syscall.h thread/thread.h lib/kernel/print.h device/console.h lib/string.h lib/kernel/memory.h \
userprog/syscall-init.h fs/fs.h userprog/fork.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/stdio.o : lib/stdio.c lib/stdio.h lib/string.h lib/kernel/global.h lib/kernel/interrupt.h \
lib/user/syscall.h lib/kernel/print.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/stdio-kernel.o : lib/kernel/stdio-kernel.c lib/kernel/stdio-kernel.h lib/kernel/print.h lib/stdio.h lib/kernel/global.h device/console.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/ide.o : device/ide.c device/ide.h lib/kernel/debug.h lib/stdint.h lib/kernel/interrupt.h \
device/console.h lib/kernel/list.h lib/kernel/memory.h lib/string.h lib/kernel/io.h thread/sync.h lib/kernel/stdio-kernel.h lib/stdio.h \
 device/timer.h 
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/fs.o : fs/fs.c fs/fs.h fs/super_block.h fs/inode.h fs/dir.h lib/stdint.h lib/kernel/stdio-kernel.h \
lib/kernel/list.h lib/string.h device/ide.h lib/kernel/global.h lib/kernel/debug.h lib/kernel/memory.h \
device/console.h device/keyboard.h device/ioqueue.h fs/file.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/file.o : fs/file.c fs/file.h fs/fs.h fs/super_block.h fs/inode.h lib/kernel/stdio-kernel.h \
lib/kernel/memory.h lib/kernel/debug.h lib/kernel/interrupt.h lib/string.h thread/thread.h lib/kernel/global.h device/ioqueue.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/inode.o : fs/inode.c fs/inode.h fs/fs.h fs/file.h lib/kernel/global.h lib/kernel/debug.h \
lib/kernel/memory.h lib/kernel/interrupt.h lib/kernel/list.h lib/kernel/stdio-kernel.h lib/string.h \
fs/super_block.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/dir.o : fs/dir.c fs/dir.h lib/stdint.h fs/inode.h fs/file.h fs/fs.h lib/kernel/stdio-kernel.h \
lib/kernel/global.h lib/kernel/debug.h lib/kernel/memory.h lib/string.h lib/kernel/interrupt.h \
fs/super_block.h
	$(CC) $(CFLAGS) $< -o $@
$(BUILD_DIR)/fork.o : userproc/fork.c userproc/fork.h userproc/process.h lib/kernel/memory.h \
lib/kernel/interrupt.h lib/kernel/debug.h thread/thread.h lib/string.h fs/file.h
	$(CC) $(CFLAGS) $< -o $@
########################汇编代码编译#########################
$(BUILD_DIR)/kernel.o : kernel/kernel.asm 
	$(AS) $(ASFLAGS) $< -o $@
$(BUILD_DIR)/print.o : kernel/print.asm
	$(AS) $(ASFLAGS) $< -o $@
$(BUILD_DIR)/switch.o : thread/switch.asm
	$(AS) $(ASFLAGS) $< -o $@
#######################链接所有文件#############################
$(BUILD_DIR)/kernel.bin : $(OBJS)
	$(LD) $(LDFLAGS) $^ -o $@

.PHONY : mk_dir hd clean all
mk_dir:
	if [[ ! -d $(BUILD_DIR) ]]; then mkdir $(BUILD_DIR); fi
hd:
	dd if=$(BUILD_DIR)/kernel.bin of=$(AIM_DIR)/hd60M.in bs=512 count=200 seek=9 conv=notrunc
clean:
	cd $(BUILD_DIR) && rm -f ./*
build: $(BUILD_DIR)/kernel.bin
all:	mk_dir build hd
