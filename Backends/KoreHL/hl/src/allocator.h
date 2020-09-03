
typedef struct {
	int block_size;
	int max_blocks;
	int first_block;
	// mutable
	int next_block;
	int free_blocks;
	unsigned char *sizes;
	int sizes_ref;
	int sizes_ref2;
} gc_allocator_page_data;

