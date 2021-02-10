/*
 * Copyright (C)2005-2016 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */
#include <hl.h>
#include "opcodes.h"

typedef struct {
	const char *lib;
	const char *name;
	hl_type *t;
	int findex;
} hl_native;

typedef struct {
	hl_op op;
	int p1;
	int p2;
	int p3;
	int *extra;
} hl_opcode;

typedef struct hl_function hl_function;

struct hl_function {
	int findex;
	int nregs;
	int nops;
	int ref;
	hl_type *type;
	hl_type **regs;
	hl_opcode *ops;
	int *debug;

	hl_type_obj *obj;
	union {
		const uchar *name;
		hl_function *ref; // obj = NULL
	} field;
};

#define fun_obj(f) ((f)->obj ? (f)->obj : (f)->field.ref ? (f)->field.ref->obj : NULL)
#define fun_field_name(f) ((f)->obj ? (f)->field.name : (f)->field.ref ? (f)->field.ref->field.name : NULL)

typedef struct {
	int global;
	int nfields;
	int *fields;
} hl_constant;

typedef struct {
	int version;
	int nints;
	int nfloats;
	int nstrings;
	int nbytes;
	int ntypes;
	int nglobals;
	int nnatives;
	int nfunctions;
	int nconstants;
	int entrypoint;
	int ndebugfiles;
	bool hasdebug;
	int*		ints;
	double*		floats;
	char**		strings;
	int*		strings_lens;
	char*		bytes;
	int*		bytes_pos;
	char**		debugfiles;
	int*		debugfiles_lens;
	uchar**		ustrings;
	hl_type*	types;
	hl_type**	globals;
	hl_native*	natives;
	hl_function*functions;
	hl_constant*constants;
	hl_alloc	alloc;
	hl_alloc	falloc;
} hl_code;

typedef struct {
	void *offsets;
	int start;
	bool large;
} hl_debug_infos;

typedef struct jit_ctx jit_ctx;


typedef struct {
	hl_code *code;
	int *types_hashes;
	int *globals_signs;
	int *functions_signs;
	int *functions_hashes;
	int *functions_indexes;
} hl_code_hash;

typedef struct {
	hl_code *code;
	int codesize;
	int globals_size;
	int *globals_indexes;
	unsigned char *globals_data;
	void **functions_ptrs;
	int *functions_indexes;
	void *jit_code;
	hl_code_hash *hash;
	hl_debug_infos *jit_debug;
	jit_ctx *jit_ctx;
	hl_module_context ctx;
} hl_module;

hl_code *hl_code_read( const unsigned char *data, int size, char **error_msg );

hl_code_hash *hl_code_hash_alloc( hl_code *c );
void hl_code_hash_finalize( hl_code_hash *h );
void hl_code_hash_free( hl_code_hash *h );
void hl_code_free( hl_code *c );
int hl_code_hash_type( hl_code_hash *h, hl_type *t );
void hl_code_hash_remap_globals( hl_code_hash *hnew, hl_code_hash *hold );

const uchar *hl_get_ustring( hl_code *c, int index );
const char* hl_op_name( int op );

typedef unsigned char h_bool;
hl_module *hl_module_alloc( hl_code *code );
int hl_module_init( hl_module *m, h_bool hot_reload );
h_bool hl_module_patch( hl_module *m, hl_code *code );
void hl_module_free( hl_module *m );
h_bool hl_module_debug( hl_module *m, int port, h_bool wait );

void hl_profile_setup( int sample_count );
void hl_profile_end();

jit_ctx *hl_jit_alloc();
void hl_jit_free( jit_ctx *ctx, h_bool can_reset );
void hl_jit_reset( jit_ctx *ctx, hl_module *m );
void hl_jit_init( jit_ctx *ctx, hl_module *m );
int hl_jit_function( jit_ctx *ctx, hl_module *m, hl_function *f );
void *hl_jit_code( jit_ctx *ctx, hl_module *m, int *codesize, hl_debug_infos **debug, hl_module *previous );
void hl_jit_patch_method( void *old_fun, void **new_fun_table );
