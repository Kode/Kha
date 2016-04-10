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

typedef struct {
	int findex;
	int nregs;
	int nops;
	hl_type *type;
	hl_type **regs;
	hl_opcode *ops;
} hl_function;

typedef struct {
	int version;
	int nints;
	int nfloats;
	int nstrings;
	int ntypes;
	int nglobals;
	int nnatives;
	int nfunctions;
	int entrypoint;
	int*		ints;
	double*		floats;
	char**		strings;
	char*		strings_data;
	int*		strings_lens;
	hl_type*	types;
	hl_type**	globals;
	hl_native*	natives;
	hl_function*functions;
	hl_alloc	alloc;
} hl_code;

typedef struct {
	hl_code *code;
	int codesize;
	int *globals_indexes;
	unsigned char *globals_data;
	void **functions_ptrs;
	int *functions_indexes;
	void *jit_code;
} hl_module;

typedef struct jit_ctx jit_ctx;

hl_code *hl_code_read( const unsigned char *data, int size );
void hl_code_free( hl_code *c );
const char* hl_op_name( int op );

hl_module *hl_module_alloc( hl_code *code );
int hl_module_init( hl_module *m );
void hl_module_free( hl_module *m );

void *hl_alloc_executable_memory( int size );
void hl_free_executable_memory( void *ptr, int size );

jit_ctx *hl_jit_alloc();
void hl_jit_free( jit_ctx *ctx );
void hl_jit_init( jit_ctx *ctx, hl_module *m );
int hl_jit_init_callback( jit_ctx *ctx );
int hl_jit_function( jit_ctx *ctx, hl_module *m, hl_function *f );
void *hl_jit_code( jit_ctx *ctx, hl_module *m, int *codesize );

