#ifndef _KERNEL_MEMORY_H
#define _KERNEL_MEMORY_H
#include "stdint.h"
#include "bitmap.h"
#include "list.h"
//虚拟地址池，用于虚拟内存管理
struct virtual_addr {
	struct bitmap vaddr_bitmap; //虚拟地址用到的位图结构
	uint32_t vaddr_start;  //虚拟地址起始地址
};
//内存池标记，用于判断用哪个内存池
enum pool_flags{
	PF_KERNEL = 1,
	PF_USER = 2
};
//内存块

struct mem_block{
	struct list_elem free_elem;
};
//内存块描述符
struct mem_block_desc{
	uint32_t block_size;   //内存块大小
	uint32_t blocks_per_arena;  //本arena中可容纳此mem_block的数量
	struct list free_list;
};
#define PG_P_1  1
#define PG_P_0  0
#define PG_RW_R 0
#define PG_RW_W 2
#define PG_US_U 4
#define PG_US_S 0

extern struct pool kernel_pool, user_pool;
void mem_init(void);
void* get_kernel_pages(uint32_t pg_cnt);
void* malloc_page(enum pool_flags pf, uint32_t pg_cnt);
void malloc_init(void);
uint32_t* pte_ptr(uint32_t vaddr);
uint32_t* pde_ptr(uint32_t vaddr);
uint32_t addr_v2p(uint32_t vaddr);
void* get_a_page(enum pool_flags pf, uint32_t vaddr);
void* get_user_pages(uint32_t pg_cnt);
void block_desc_init(struct mem_block_desc* desc_array);
void* sys_malloc(uint32_t size);
void mfree_page(enum pool_flags pf, void* _vaddr, uint32_t pg_cnt);
void pfree(uint32_t pg_phy_addr);
void sys_free(void* ptr);
void* get_a_page_without_opvaddrbitmap(enum pool_flags pf, uint32_t vaddr);
void free_a_phy_page(uint32_t pg_phy_addr); 

#define DESC_CNT 7  //内存块描述符个数
#endif
