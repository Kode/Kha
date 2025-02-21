
typedef unsigned short fl_cursor;

typedef struct {
	fl_cursor pos;
	fl_cursor count;
} gc_fl;

typedef struct _gc_freelist {
	int current;
	int count;
	int size_bits;
	gc_fl *data;
} gc_freelist;

typedef struct {
	int block_size;
	int max_blocks;
	int first_block;
	bool need_flush;
	// mutable
	gc_freelist free;
	unsigned char *sizes;
	int sizes_ref;
	int sizes_ref2;
} gc_allocator_page_data;

