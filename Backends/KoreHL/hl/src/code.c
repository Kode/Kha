/*
 * Copyright (C)2015-2016 Haxe Foundation
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
#include "hlmodule.h"

#define OP(_,n) n,
#define OP_BEGIN static int hl_op_nargs[] = {
#define OP_END };
#include "opcodes.h"

#define OP(n,_) #n,
#define OP_BEGIN static const char *hl_op_names[] = {
#define OP_END };
#include "opcodes.h"

typedef struct {
	const unsigned char *b;
	int size;
	int pos;
	const char *error;
	hl_code *code;
} hl_reader;

#undef ERROR
#define READ() hl_read_b(r)
#define INDEX() hl_read_index(r)
#define UINDEX() hl_read_uindex(r)
#define ERROR(msg) if( !r->error ) { r->error = msg; hl_debug_break(); }
#define CHK_ERROR() if( r->error ) return

static unsigned char hl_read_b( hl_reader *r ) {
	if( r->pos >= r->size ) {
		ERROR("No more data");
		return 0;
	}
	return r->b[r->pos++];
}

static void hl_read_bytes( hl_reader *r, void *data, int size ) {
	if( size < 0 ) {
		ERROR("Invalid size");
		return;
	}
	if( r->pos + size > r->size ) {
		ERROR("No more data");
		return;
	}
	memcpy(data,r->b + r->pos, size);
	r->pos += size;
}

static double hl_read_double( hl_reader *r ) {
	double d = 0.;
	hl_read_bytes(r, &d, 8);
	return d;
}

static int hl_read_i32( hl_reader *r ) {
	unsigned char a, b, c, d;
	if( r->pos + 4 > r->size ) {
		ERROR("No more data");
		return 0;
	}
	a = r->b[r->pos++];
	b = r->b[r->pos++];
	c = r->b[r->pos++];
	d = r->b[r->pos++];
	return a | (b<<8) | (c<<16) | (d<<24);
}

static int hl_read_index( hl_reader *r ) {
	unsigned char b = READ();
	if( (b & 0x80) == 0 )
		return b & 0x7F;
	if( (b & 0x40) == 0 ) {
		int v = READ() | ((b & 31) << 8);
		return (b & 0x20) == 0 ? v : -v;
	}
	{
		int c = READ();
		int d = READ();
		int e = READ();
		int v = ((b & 31) << 24) | (c << 16) | (d << 8) | e;
		return (b & 0x20) == 0 ? v : -v;
	}
}

static int hl_read_uindex( hl_reader *r ) {
	int i = hl_read_index(r);
	if( i < 0 ) {
		ERROR("Negative index");
		return 0;
	}
	return i;
}

static hl_type *hl_get_type( hl_reader *r ) {
	int i = INDEX();
	if( i < 0 || i >= r->code->ntypes ) {
		ERROR("Invalid type index");
		i = 0;
	}
	return r->code->types + i;
}

static const char *hl_read_string( hl_reader *r ) {
	int i = INDEX();
	if( i < 0 || i >= r->code->nstrings ) {
		ERROR("Invalid string index");
		i = 0;
	}
	return r->code->strings[i];
}

const uchar *hl_get_ustring( hl_code *code, int index ) {
	uchar *str = code->ustrings[index];
	if( str == NULL ) {
		int size = hl_utf8_length((vbyte*)code->strings[index],0);
		str = hl_malloc(&code->alloc,(size+1)<<1);
		hl_from_utf8(str,size,code->strings[index]);
		code->ustrings[index] = str;
	}
	return str;
}

static const uchar *hl_read_ustring( hl_reader *r ) {
	int i = INDEX();
	if( i < 0 || i >= r->code->nstrings ) {
		ERROR("Invalid string index");
		i = 0;
	}
	return hl_get_ustring(r->code,i);
}

static void hl_read_type( hl_reader *r, hl_type *t ) {
	t->kind = READ();
	switch( (int)t->kind ) {
	case HFUN:
		{
			int i;
			int nargs = READ(); 
			t->fun = (hl_type_fun*)hl_malloc(&r->code->alloc,sizeof(hl_type_fun));
			t->fun->nargs = nargs;
			t->fun->args = (hl_type**)hl_malloc(&r->code->alloc,sizeof(hl_type*)*nargs);
			for(i=0;i<nargs;i++)
				t->fun->args[i] = hl_get_type(r);
			t->fun->ret = hl_get_type(r);
		}
		break;
	case HOBJ:
		{
			int i;
			const uchar *name = hl_read_ustring(r);
			int super = INDEX();
			int global = UINDEX();
			int nfields = UINDEX();
			int nproto = UINDEX();
			int nbindings = UINDEX();
			t->obj = (hl_type_obj*)hl_malloc(&r->code->alloc,sizeof(hl_type_obj));
			t->obj->name = name;
			t->obj->super = super < 0 ? NULL : r->code->types + super;
			t->obj->global_value = (void**)(int_val)global;
			t->obj->nfields = nfields;
			t->obj->nproto = nproto;
			t->obj->nbindings = nbindings;
			t->obj->fields = (hl_obj_field*)hl_malloc(&r->code->alloc,sizeof(hl_obj_field)*nfields);
			t->obj->proto = (hl_obj_proto*)hl_malloc(&r->code->alloc,sizeof(hl_obj_proto)*nproto);
			t->obj->bindings = (int*)hl_malloc(&r->code->alloc,sizeof(int)*nbindings*2);
			t->obj->rt = NULL;
			for(i=0;i<nfields;i++) {
				hl_obj_field *f = t->obj->fields + i;
				f->name = hl_read_ustring(r);
				f->hashed_name = hl_hash_gen(f->name,true);
				f->t = hl_get_type(r);
			}
			for(i=0;i<nproto;i++) {
				hl_obj_proto *p = t->obj->proto + i;
				p->name = hl_read_ustring(r);
				p->hashed_name = hl_hash_gen(p->name,true);
				p->findex = UINDEX();
				p->pindex = INDEX();
			}
			for(i=0;i<nbindings;i++) {
				t->obj->bindings[i<<1] = UINDEX();
				t->obj->bindings[(i<<1)|1] = UINDEX();
			}
		}
		break;
	case HREF:
		t->tparam = hl_get_type(r);
		break;
	case HVIRTUAL:
		{
			int i;
			int nfields = UINDEX();
			t->virt = (hl_type_virtual*)hl_malloc(&r->code->alloc,sizeof(hl_type_virtual));
			t->virt->nfields = nfields;
			t->virt->fields = (hl_obj_field*)hl_malloc(&r->code->alloc,sizeof(hl_obj_field)*nfields);
			for(i=0;i<nfields;i++) {
				hl_obj_field *f = t->virt->fields + i;
				f->name = hl_read_ustring(r);
				f->hashed_name = hl_hash_gen(f->name,true);
				f->t = hl_get_type(r);
			}
		}
		break;
	case HABSTRACT:
		t->abs_name = hl_read_ustring(r);
		break;
	case HENUM:
		{
			int i,j;
			t->tenum = hl_malloc(&r->code->alloc,sizeof(hl_type_enum));
			t->tenum->name = hl_read_ustring(r);
			t->tenum->global_value = (void**)(int_val)UINDEX();
			t->tenum->nconstructs = READ();
			t->tenum->constructs = (hl_enum_construct*)hl_malloc(&r->code->alloc, sizeof(hl_enum_construct)*t->tenum->nconstructs);
			for(i=0;i<t->tenum->nconstructs;i++) {
				hl_enum_construct *c = t->tenum->constructs + i;
				c->name = hl_read_ustring(r);
				c->nparams = UINDEX();
				c->params = (hl_type**)hl_malloc(&r->code->alloc,sizeof(hl_type*)*c->nparams);
				c->offsets = (int*)hl_malloc(&r->code->alloc,sizeof(int)*c->nparams);
				for(j=0;j<c->nparams;j++)
					c->params[j] = hl_get_type(r);
			}
		}
		break;
	case HNULL:
		t->tparam = hl_get_type(r);
		break;
	default:
		if( t->kind >= HLAST ) ERROR("Invalid type");
		break;
	}
}

static void hl_read_opcode( hl_reader *r, hl_function *f, hl_opcode *o ) {
	o->op = (hl_op)READ();
	if( o->op >= OLast ) {
		ERROR("Invalid opcode");
		return;
	}
	switch( hl_op_nargs[o->op] ) {
	case 0:
		break;
	case 1:
		o->p1 = INDEX();
		break;
	case 2:
		o->p1 = INDEX();
		o->p2 = INDEX();
		break;
	case 3:
		o->p1 = INDEX();
		o->p2 = INDEX();
		o->p3 = INDEX();
		break;
	case 4:
		o->p1 = INDEX();
		o->p2 = INDEX();
		o->p3 = INDEX();
		o->extra = (int*)(int_val)INDEX();
		break;
	case -1:
		switch( o->op ) {
		case OCallN:
		case OCallClosure:
		case OCallMethod:
		case OCallThis:
		case OMakeEnum:
			{
				int i;
				o->p1 = INDEX();
				o->p2 = INDEX();
				o->p3 = READ();
				o->extra = (int*)hl_malloc(&r->code->falloc,sizeof(int) * o->p3);
				for(i=0;i<o->p3;i++)
					o->extra[i] = INDEX();
			}
			break;
		case OSwitch:
			{
				int i;
				o->p1 = UINDEX();
				o->p2 = UINDEX();
				o->extra = (int*)hl_malloc(&r->code->falloc,sizeof(int) * o->p2);
				for(i=0;i<o->p2;i++)
					o->extra[i] = UINDEX();
				o->p3 = UINDEX();
			}
			break;
		default:
			ERROR("Don't know how to process opcode");
			break;
		}
		break;
	default:
		{
			int i, size = hl_op_nargs[o->op] - 3;
			o->p1 = INDEX();
			o->p2 = INDEX();
			o->p3 = INDEX();
			o->extra = (int*)hl_malloc(&r->code->falloc,sizeof(int) * size);
			for(i=0;i<size;i++)
				o->extra[i] = INDEX();
		}
		break;
	}
}

static void hl_read_function( hl_reader *r, hl_function *f ) {
	int i;
	f->type = hl_get_type(r);
	f->findex = UINDEX();
	f->nregs = UINDEX();
	f->nops = UINDEX();
	f->regs = (hl_type**)hl_malloc(&r->code->falloc, f->nregs * sizeof(hl_type*));
	for(i=0;i<f->nregs;i++)
		f->regs[i] = hl_get_type(r);
	CHK_ERROR();
	f->ops = (hl_opcode*)hl_malloc(&r->code->falloc, f->nops * sizeof(hl_opcode));
	for(i=0;i<f->nops;i++)
		hl_read_opcode(r, f, f->ops+i);
}

#undef CHK_ERROR
#define CHK_ERROR() if( r->error ) { if( c ) hl_free(&c->alloc); printf("%s\n", r->error); return NULL; }
#define EXIT(msg) { ERROR(msg); CHK_ERROR(); }
#define ALLOC(v,ptr,count) v = (ptr *)hl_zalloc(&c->alloc,count*sizeof(ptr))

const char *hl_op_name( int op ) {
	if( op < 0 || op >= OLast )
		return "UnknownOp";
	return hl_op_names[op];
}

static char **hl_read_strings( hl_reader *r, int nstrings, int **out_lens ) {
	int size = hl_read_i32(r);
	hl_code *c = r->code;
	char *sbase = (char*)hl_malloc(&c->alloc,sizeof(char) * size);
	char *sdata = sbase;
	char **strings;
	int *lens;
	int i;
	hl_read_bytes(r, sdata, size);
	ALLOC(strings, char*, nstrings);
	ALLOC(lens, int, nstrings);
	for(i=0;i<nstrings;i++) {
		int sz = UINDEX();
		strings[i] = sdata;
		lens[i] = sz;
		sdata += sz;
		if( sdata >= sbase + size || *sdata ) {
			ERROR("Invalid string");
			return NULL;
		}
		sdata++;
	}
	*out_lens = lens;
	return strings;
}

static int *hl_read_debug_infos( hl_reader *r, int nops ) {
	int curfile = -1, curline = 0;
	hl_code *code = r->code;
	int *debug = (int*)hl_malloc(&code->alloc, sizeof(int) * nops * 2);
	int i = 0;	
	while( i < nops ) {
		int c = READ();
		if( c & 1 ) {
			c >>= 1;
			curfile = (c << 8) | READ();
			if( curfile >= code->ndebugfiles )
				ERROR("Invalid debug file");
		} else if( c & 2 ) {
			int delta = c >> 6;
			int count = (c >> 2) & 15;
			if( i + count > nops )
				ERROR("Outside range");
			while( count-- ) {
				debug[i<<1] = curfile;
				debug[(i<<1)|1] = curline;
				i++;
			}
			curline += delta;
		} else if( c & 4 ) {
			curline += c >> 3;
			debug[i<<1] = curfile;
			debug[(i<<1)|1] = curline;
			i++;
		} else {
			unsigned char b2 = READ();
			unsigned char b3 = READ();
			curline = (c >> 3) | (b2 << 5) | (b3 << 13);
			debug[i<<1] = curfile;
			debug[(i<<1)|1] = curline;
			i++;
		}
	}
	return debug;
}

hl_code *hl_code_read( const unsigned char *data, int size ) {
	hl_reader _r = { data, size, 0, 0, NULL };	
	hl_reader *r = &_r;
	hl_code *c;
	hl_alloc alloc;
	int i;
	int flags;
	hl_alloc_init(&alloc);
	c = hl_zalloc(&alloc,sizeof(hl_code));
	c->alloc = alloc;
	hl_alloc_init(&c->falloc);
	if( READ() != 'H' || READ() != 'L' || READ() != 'B' )
		EXIT("Invalid header");
	r->code = c;
	c->version = READ();
	if( c->version <= 1 || c->version > 4 ) {
		printf("VER=%d\n",c->version);
		EXIT("Unsupported bytecode version");
	}
	flags = UINDEX();
	c->nints = UINDEX();
	c->nfloats = UINDEX();
	c->nstrings = UINDEX();
	c->ntypes = UINDEX();
	c->nglobals = UINDEX();
	c->nnatives = UINDEX();
	c->nfunctions = UINDEX();
	c->nconstants = c->version >= 4 ? UINDEX() : 0;
	c->entrypoint = UINDEX();	
	c->hasdebug = flags & 1;
	CHK_ERROR();
	ALLOC(c->ints, int, c->nints);
	for(i=0;i<c->nints;i++)
		c->ints[i] = hl_read_i32(r);
	CHK_ERROR();
	ALLOC(c->floats, double, c->nfloats);
	for(i=0;i<c->nfloats;i++)
		c->floats[i] = hl_read_double(r);
	CHK_ERROR();
	c->strings = hl_read_strings(r, c->nstrings, &c->strings_lens);
	ALLOC(c->ustrings,uchar*,c->nstrings);
	CHK_ERROR();
	if( c->hasdebug ) {
		c->ndebugfiles = UINDEX();
		c->debugfiles = hl_read_strings(r, c->ndebugfiles, &c->debugfiles_lens);
		CHK_ERROR();
	}
	ALLOC(c->types, hl_type, c->ntypes);
	for(i=0;i<c->ntypes;i++) {
		hl_read_type(r, c->types + i);
		CHK_ERROR();
	}
	ALLOC(c->globals, hl_type*, c->nglobals);
	for(i=0;i<c->nglobals;i++)
		c->globals[i] = hl_get_type(r);
	CHK_ERROR();
	ALLOC(c->natives, hl_native, c->nnatives);
	for(i=0;i<c->nnatives;i++) {
		hl_native *n = c->natives + i;
		n->lib = hl_read_string(r);
		n->name = hl_read_string(r);
		n->t = hl_get_type(r);
		n->findex = UINDEX();
	}
	CHK_ERROR();
	ALLOC(c->functions, hl_function, c->nfunctions);
	for(i=0;i<c->nfunctions;i++) {
		hl_read_function(r,c->functions+i);
		CHK_ERROR();
		if( c->hasdebug ) {
			c->functions[i].debug = hl_read_debug_infos(r,c->functions[i].nops);
			if( c->version >= 3 ) {
				// skip assigns (no need here)
				int nassigns = UINDEX();
				int j;
				for(j=0;j<nassigns;j++) {
					UINDEX();
					INDEX();
				}
			}
		}
	}
	CHK_ERROR();
	ALLOC(c->constants, hl_constant, c->nconstants);
	for (i = 0; i < c->nconstants; i++) {
		int j;
		hl_constant *k = c->constants + i;
		k->global = UINDEX();
		k->nfields = UINDEX();
		ALLOC(k->fields, int, k->nfields);
		for (j = 0; j < k->nfields; j++)
			k->fields[j] = UINDEX();
		CHK_ERROR();
	}
	return c;
}

void hl_code_free( hl_code *c ) {
	hl_free(&c->falloc);
}