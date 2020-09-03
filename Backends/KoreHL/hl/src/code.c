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
		return "";
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
	case HMETHOD:
		{
			int i;
			int nargs = READ(); 
			t->fun = (hl_type_fun*)hl_zalloc(&r->code->alloc,sizeof(hl_type_fun));
			t->fun->nargs = nargs;
			t->fun->args = (hl_type**)hl_malloc(&r->code->alloc,sizeof(hl_type*)*nargs);
			for(i=0;i<nargs;i++)
				t->fun->args[i] = hl_get_type(r);
			t->fun->ret = hl_get_type(r);
		}
		break;
	case HOBJ:
	case HSTRUCT:
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
			t->tenum->nconstructs = UINDEX();
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
#define CHK_ERROR() if( r->error ) { if( c ) hl_free(&c->alloc); *error_msg = (char*)r->error; return NULL; }
#define EXIT(msg) { ERROR(msg); CHK_ERROR(); }
#define ALLOC(v,ptr,count) v = (ptr *)hl_zalloc(&c->alloc,(count)*sizeof(ptr))

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

hl_code *hl_code_read( const unsigned char *data, int size, char **error_msg ) {
	hl_reader _r = { data, size, 0, 0, NULL };	
	hl_reader *r = &_r;
	hl_code *c;
	hl_alloc alloc;
	int i;
	int flags;
	int max_version = 5;
	hl_alloc_init(&alloc);
	c = hl_zalloc(&alloc,sizeof(hl_code));
	c->alloc = alloc;
	hl_alloc_init(&c->falloc);
	if( READ() != 'H' || READ() != 'L' || READ() != 'B' )
		EXIT("Invalid HL bytecode header");
	r->code = c;
	c->version = READ();
	if( c->version <= 1 || c->version > max_version ) {
		printf("Found version %d while HL %d.%d supports up to %d\n",c->version,HL_VERSION>>16,(HL_VERSION>>8)&0xFF,max_version);
		EXIT("Unsupported bytecode version");
	}
	flags = UINDEX();
	c->nints = UINDEX();
	c->nfloats = UINDEX();
	c->nstrings = UINDEX();
	if( c->version >= 5 ) 
		c->nbytes = UINDEX();
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
	if( c->version >= 5 ) {
		int size = hl_read_i32(r);
		c->bytes = hl_malloc(&c->alloc,size);
		hl_read_bytes(r,c->bytes,size);
		ALLOC(c->bytes_pos,int,c->nbytes);
		CHK_ERROR();
		for(i=0;i<c->nbytes;i++)
			c->bytes_pos[i] = UINDEX();
		CHK_ERROR();
	}
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

static const unsigned int crc32_table[] =
{
  0x00000000, 0x04c11db7, 0x09823b6e, 0x0d4326d9,
  0x130476dc, 0x17c56b6b, 0x1a864db2, 0x1e475005,
  0x2608edb8, 0x22c9f00f, 0x2f8ad6d6, 0x2b4bcb61,
  0x350c9b64, 0x31cd86d3, 0x3c8ea00a, 0x384fbdbd,
  0x4c11db70, 0x48d0c6c7, 0x4593e01e, 0x4152fda9,
  0x5f15adac, 0x5bd4b01b, 0x569796c2, 0x52568b75,
  0x6a1936c8, 0x6ed82b7f, 0x639b0da6, 0x675a1011,
  0x791d4014, 0x7ddc5da3, 0x709f7b7a, 0x745e66cd,
  0x9823b6e0, 0x9ce2ab57, 0x91a18d8e, 0x95609039,
  0x8b27c03c, 0x8fe6dd8b, 0x82a5fb52, 0x8664e6e5,
  0xbe2b5b58, 0xbaea46ef, 0xb7a96036, 0xb3687d81,
  0xad2f2d84, 0xa9ee3033, 0xa4ad16ea, 0xa06c0b5d,
  0xd4326d90, 0xd0f37027, 0xddb056fe, 0xd9714b49,
  0xc7361b4c, 0xc3f706fb, 0xceb42022, 0xca753d95,
  0xf23a8028, 0xf6fb9d9f, 0xfbb8bb46, 0xff79a6f1,
  0xe13ef6f4, 0xe5ffeb43, 0xe8bccd9a, 0xec7dd02d,
  0x34867077, 0x30476dc0, 0x3d044b19, 0x39c556ae,
  0x278206ab, 0x23431b1c, 0x2e003dc5, 0x2ac12072,
  0x128e9dcf, 0x164f8078, 0x1b0ca6a1, 0x1fcdbb16,
  0x018aeb13, 0x054bf6a4, 0x0808d07d, 0x0cc9cdca,
  0x7897ab07, 0x7c56b6b0, 0x71159069, 0x75d48dde,
  0x6b93dddb, 0x6f52c06c, 0x6211e6b5, 0x66d0fb02,
  0x5e9f46bf, 0x5a5e5b08, 0x571d7dd1, 0x53dc6066,
  0x4d9b3063, 0x495a2dd4, 0x44190b0d, 0x40d816ba,
  0xaca5c697, 0xa864db20, 0xa527fdf9, 0xa1e6e04e,
  0xbfa1b04b, 0xbb60adfc, 0xb6238b25, 0xb2e29692,
  0x8aad2b2f, 0x8e6c3698, 0x832f1041, 0x87ee0df6,
  0x99a95df3, 0x9d684044, 0x902b669d, 0x94ea7b2a,
  0xe0b41de7, 0xe4750050, 0xe9362689, 0xedf73b3e,
  0xf3b06b3b, 0xf771768c, 0xfa325055, 0xfef34de2,
  0xc6bcf05f, 0xc27dede8, 0xcf3ecb31, 0xcbffd686,
  0xd5b88683, 0xd1799b34, 0xdc3abded, 0xd8fba05a,
  0x690ce0ee, 0x6dcdfd59, 0x608edb80, 0x644fc637,
  0x7a089632, 0x7ec98b85, 0x738aad5c, 0x774bb0eb,
  0x4f040d56, 0x4bc510e1, 0x46863638, 0x42472b8f,
  0x5c007b8a, 0x58c1663d, 0x558240e4, 0x51435d53,
  0x251d3b9e, 0x21dc2629, 0x2c9f00f0, 0x285e1d47,
  0x36194d42, 0x32d850f5, 0x3f9b762c, 0x3b5a6b9b,
  0x0315d626, 0x07d4cb91, 0x0a97ed48, 0x0e56f0ff,
  0x1011a0fa, 0x14d0bd4d, 0x19939b94, 0x1d528623,
  0xf12f560e, 0xf5ee4bb9, 0xf8ad6d60, 0xfc6c70d7,
  0xe22b20d2, 0xe6ea3d65, 0xeba91bbc, 0xef68060b,
  0xd727bbb6, 0xd3e6a601, 0xdea580d8, 0xda649d6f,
  0xc423cd6a, 0xc0e2d0dd, 0xcda1f604, 0xc960ebb3,
  0xbd3e8d7e, 0xb9ff90c9, 0xb4bcb610, 0xb07daba7,
  0xae3afba2, 0xaafbe615, 0xa7b8c0cc, 0xa379dd7b,
  0x9b3660c6, 0x9ff77d71, 0x92b45ba8, 0x9675461f,
  0x8832161a, 0x8cf30bad, 0x81b02d74, 0x857130c3,
  0x5d8a9099, 0x594b8d2e, 0x5408abf7, 0x50c9b640,
  0x4e8ee645, 0x4a4ffbf2, 0x470cdd2b, 0x43cdc09c,
  0x7b827d21, 0x7f436096, 0x7200464f, 0x76c15bf8,
  0x68860bfd, 0x6c47164a, 0x61043093, 0x65c52d24,
  0x119b4be9, 0x155a565e, 0x18197087, 0x1cd86d30,
  0x029f3d35, 0x065e2082, 0x0b1d065b, 0x0fdc1bec,
  0x3793a651, 0x3352bbe6, 0x3e119d3f, 0x3ad08088,
  0x2497d08d, 0x2056cd3a, 0x2d15ebe3, 0x29d4f654,
  0xc5a92679, 0xc1683bce, 0xcc2b1d17, 0xc8ea00a0,
  0xd6ad50a5, 0xd26c4d12, 0xdf2f6bcb, 0xdbee767c,
  0xe3a1cbc1, 0xe760d676, 0xea23f0af, 0xeee2ed18,
  0xf0a5bd1d, 0xf464a0aa, 0xf9278673, 0xfde69bc4,
  0x89b8fd09, 0x8d79e0be, 0x803ac667, 0x84fbdbd0,
  0x9abc8bd5, 0x9e7d9662, 0x933eb0bb, 0x97ffad0c,
  0xafb010b1, 0xab710d06, 0xa6322bdf, 0xa2f33668,
  0xbcb4666d, 0xb8757bda, 0xb5365d03, 0xb1f740b4
};

#define H(b) hash = (hash >> 8) ^ crc32_table[(hash ^ (b)) & 0xFF]
#define H32(i) { H(i&0xFF); H((i>>8)&0xFF); H((i>>16)&0xFF); H(((unsigned int)i)>>24); }
#define HFUN(idx) H32(h->functions_signs[h->functions_indexes[idx]]); 
#define HSTR(s) { const char *_c = s; while( *_c ) H(*_c++); }
#define HUSTR(s) { const uchar *_c = s; while( *_c ) H(*_c++); }
#define HTYPE(t) if( !isrec ) H32(hash_type_first(t,true))

// hash with only partial recursion
static int hash_type_first( hl_type *t, bool isrec ) {
	int hash = -1;
	int i;
	H(t->kind);
	switch( t->kind ) {
	case HFUN:
	case HMETHOD:
		H(t->fun->nargs);
		for(i=0;i<t->fun->nargs;i++)
			HTYPE(t->fun->args[i]);
		HTYPE(t->fun->ret);
		break;
	case HOBJ:
	case HSTRUCT:
		HUSTR(t->obj->name);
		H32(t->obj->nfields);
		H32(t->obj->nproto);
		for(i=0;i<t->obj->nfields;i++) {
			hl_obj_field *f = t->obj->fields + i;
			H32(f->hashed_name);
			HTYPE(f->t);
		}
		break;
	case HREF:
	case HNULL:
		HTYPE(t->tparam);
		break;
	case HVIRTUAL:
		H32(t->virt->nfields);
		for(i=0;i<t->virt->nfields;i++) {
			hl_obj_field *f = t->virt->fields + i;
			H32(f->hashed_name);
			HTYPE(f->t);
		}
		break;
	case HENUM:
		HUSTR(t->tenum->name);
		for(i=0;i<t->tenum->nconstructs;i++) {
			hl_enum_construct *c = t->tenum->constructs + i;
			int k;
			H(c->nparams);
			HUSTR(c->name);
			for(k=0;k<c->nparams;k++)
				HTYPE(c->params[k]);
		}
		break;
	case HABSTRACT:
		HUSTR(t->abs_name);
		break;
	default:
		break;
	}
	return hash;
}

#undef HTYPE
#define HTYPE(t) H32(h->types_hashes[t - h->code->types])

static int hash_type_rec( hl_code_hash *h, hl_type *t ) {
	int hash = -1;
	int i;
	switch( t->kind ) {
	case HFUN:
	case HMETHOD:
		for(i=0;i<t->fun->nargs;i++)
			HTYPE(t->fun->args[i]);
		HTYPE(t->fun->ret);
		break;
	case HOBJ:
	case HSTRUCT:
		for(i=0;i<t->obj->nfields;i++) {
			hl_obj_field *f = t->obj->fields + i;
			HTYPE(f->t);
		}
		break;
	case HREF:
	case HNULL:
		HTYPE(t->tparam);
		break;
	case HVIRTUAL:
		for(i=0;i<t->virt->nfields;i++) {
			hl_obj_field *f = t->virt->fields + i;
			HTYPE(f->t);
		}
		break;
	case HENUM:
		for(i=0;i<t->tenum->nconstructs;i++) {
			hl_enum_construct *c = t->tenum->constructs + i;
			int k;
			for(k=0;k<c->nparams;k++)
				HTYPE(c->params[k]);
		}
		break;
	default:
		break;
	}
	return hash;
}

static int hash_native( hl_code_hash *h, hl_native *n ) {
	int hash = -1;
	HSTR(n->lib);
	HSTR(n->name);
	HTYPE(n->t);
	return hash;
}

static int hash_fun_sign( hl_code_hash *h, hl_function *f ) {
	int hash = -1;
	HTYPE(f->type);
	if( f->obj ) {
		HUSTR(f->obj->name);
		HUSTR(f->field.name);
	} else if( f->field.ref ) {
		HUSTR(f->field.ref->obj->name);
		HUSTR(f->field.ref->field.name);
		H32(f->ref);
	}
	return hash;
}

static int hash_fun( hl_code_hash *h, hl_function *f ) {
	int hash = -1;
	hl_code *c = h->code;
	int i, k;
	for(i=0;i<f->nregs;i++)
		HTYPE(f->regs[i]);
	for(k=0;k<f->nops;k++) {
		hl_opcode *o = f->ops + k;
		H(o->op);
		switch( o->op ) {
		case OInt:
			H32(o->p1);
			H32(c->ints[o->p2]);
			break;
		case OFloat:
			H32(o->p1);
			H32( ((int*)c->floats)[o->p2<<1] );
			H32( ((int*)c->floats)[(o->p2<<1)|1] );
			break;
		case OString:
			H32(o->p1);
			HSTR(c->strings[o->p2]);
			break;
		//case OBytes:
		case OType:
			H32(o->p1);
			HTYPE(c->types + o->p2);
			break;
		case OCall0:
			H32(o->p1);
			HFUN(o->p2);
			break;
		case OCall1:
			H32(o->p1);
			HFUN(o->p2);
			H32(o->p3);
			break;
		case OCall2:
			H32(o->p1);
			HFUN(o->p2);
			H32(o->p3);
			H32((int)(int_val)o->extra);
			break;
		case OCall3:
			H32(o->p1);
			HFUN(o->p2);
			H32(o->p3);
			H32(o->extra[0]);
			H32(o->extra[1]);
			break;
		case OCall4:
			H32(o->p1);
			HFUN(o->p2);
			H32(o->p3);
			H32(o->extra[0]);
			H32(o->extra[1]);
			H32(o->extra[2]);
			break;
		case OCallN:
			H32(o->p1);
			HFUN(o->p2);
			H32(o->p3);
			for(i=0;i<o->p3;i++)
				H32(o->extra[i]);
			break;
		case OStaticClosure:
			H32(o->p1);
			HFUN(o->p2);
			break;
		case OInstanceClosure:
			H32(o->p1);
			HFUN(o->p2);
			H32(o->p3);
			break;
		case ODynGet:
			H32(o->p1);
			H32(o->p2);
			HSTR(c->strings[o->p3]);
			break;
		case ODynSet:
			H32(o->p1);
			HSTR(c->strings[o->p2]);
			H32(o->p3);
			break;
		default:
			switch( hl_op_nargs[o->op] ) {
			case 0:
				break;
			case 1:
				H32(o->p1);
				break;
			case 2:
				H32(o->p1);
				H32(o->p2);
				break;
			case 3:
				H32(o->p1);
				H32(o->p2);
				H32(o->p3);
				break;
			case 4:
				H32(o->p1);
				H32(o->p2);
				H32(o->p3);
				H32((int)(int_val)o->extra);
				break;
			case -1:
				switch( o->op ) {
				case OCallN:
				case OCallClosure:
				case OCallMethod:
				case OCallThis:
				case OMakeEnum:
					H32(o->p1);
					H32(o->p2);
					H32(o->p3);
					for(i=0;i<o->p3;i++)
						H32(o->extra[i]);
					break;
				case OSwitch:
					H32(o->p1);
					H32(o->p2);
					for(i=0;i<o->p2;i++)
						H32(o->extra[i]);
					H32(o->p3);
					break;
				default:
					printf("Don't know how to process opcode %d",o->op);
					break;
				}
				break;
			default:
				{
					int size = hl_op_nargs[o->op] - 3;
					H32(o->p1);
					H32(o->p2);
					H32(o->p3);
					for(i=0;i<size;i++)
						H32(o->extra[i]);
				}
				break;
			}
		}
	}
	return hash;
}

int hl_code_hash_type( hl_code_hash *h, hl_type *t ) {
	int hash = -1;
	HTYPE(t);
	return hash;
}

hl_code_hash *hl_code_hash_alloc( hl_code *c ) {
	int i;
	hl_code_hash *h = malloc(sizeof(hl_code_hash));
	memset(h,0,sizeof(hl_code_hash));
	h->code = c;

	h->functions_indexes = malloc(sizeof(int) * (c->nfunctions + c->nnatives));
	for(i=0;i<c->nfunctions;i++) {
		hl_function *f = c->functions + i;
		h->functions_indexes[f->findex] = i;
	}
	for(i=0;i<c->nnatives;i++) {
		hl_native *n = c->natives + i;
		h->functions_indexes[n->findex] = i + c->nfunctions;
	}

	h->types_hashes = malloc(sizeof(int) * c->ntypes);
	for(i=0;i<c->ntypes;i++)
		h->types_hashes[i] = hash_type_first(c->types + i, false);
	int *types_hashes = malloc(sizeof(int) * c->ntypes); // use a second buffer for order-indepedent
	for(i=0;i<c->ntypes;i++)
		types_hashes[i] = h->types_hashes[i] ^ hash_type_rec(h, c->types + i);
	free(h->types_hashes);
	h->types_hashes = types_hashes;

	h->globals_signs = malloc(sizeof(int) * c->nglobals);
	for(i=0;i<c->nglobals;i++)
		h->globals_signs[i] = i | 0x80000000;
	for(i=0;i<c->ntypes;i++) {
		hl_type *t = c->types + i;
		switch( t->kind ) {
		case HOBJ:
		case HSTRUCT:
			if( t->obj->global_value )
				h->globals_signs[(int)(int_val)t->obj->global_value - 1] = hl_code_hash_type(h,t); 
			break;
		case HENUM:
			if( t->tenum->global_value )
				h->globals_signs[(int)(int_val)t->tenum->global_value - 1] = hl_code_hash_type(h,t); 
			break;
		default:
			break;
		}
	}
	for(i=0;i<c->nconstants;i++) {
		hl_constant *k = c->constants + i;
		hl_type *t = c->globals[k->global];
		int hash = -1;
		int j;
		for(j=0;j<k->nfields;j++) {
			int index = k->fields[j];
			switch( t->obj->fields[j].t->kind ) {
			case HI32:
				H32(c->ints[index]);
				break;
			case HBYTES:
				HSTR(c->strings[index]);
				break;
			default:
				break;
			}
		}
		h->globals_signs[k->global] = hash;
	}

	// look into boot code to identify globals that are constant enum constructors
	// this is a bit hackish but we need them for remap and there's no metatada
	hl_function *f = c->functions + h->functions_indexes[c->entrypoint];
	for(i=4;i<f->nops;i++) {
		hl_opcode *op = f->ops + i;
		hl_type *t;
		switch( op->op ) {
		case OSetGlobal:
			t = c->globals[op->p1];
			if( t->kind == HENUM && f->ops[i-2].op == OGetArray && f->ops[i-3].op == OInt )
				h->globals_signs[op->p1] = c->ints[f->ops[i-3].p2];
			break;
		default:
			break;
		}
	}

	for(i=0;i<c->nglobals;i++)
		h->globals_signs[i] ^= hl_code_hash_type(h,c->globals[i]);
	return h;
}


void hl_code_hash_remap_globals( hl_code_hash *hnew, hl_code_hash *hold ) {
	hl_code *c = hnew->code;
	int i;
	int old_start = 0;

	int count = c->nglobals;
	int extra =	hold->code->nglobals - count;
	if( extra < 0 ) extra = 0;
	int *remap = malloc(sizeof(int) * count);

	for(i=0;i<count;i++) {
		int k;
		int h = hnew->globals_signs[i];
		remap[i] = -1;
		for(k=old_start;k<hold->code->nglobals;k++) {
			if( hold->globals_signs[k] == h ) {
				if( k == old_start ) old_start++;
				remap[i] = k;
				break;
			}
		}
	}

	// new globals
	for(i=0;i<count;i++)
		if( remap[i] == -1 )
			remap[i] = count + extra++;

	hl_type **nglobals;
	ALLOC(nglobals,hl_type*,count + extra);
	for(i=0;i<count;i++)
		nglobals[i] = &hlt_void;
	for(i=0;i<count;i++)
		nglobals[remap[i]] = c->globals[i];
	c->globals = nglobals;
	c->nglobals += extra;

	int *nsigns = malloc(sizeof(int) * (count+extra));
	for(i=0;i<count;i++)
		nsigns[i] = -1;
	for(i=0;i<count;i++)
		nsigns[remap[i]] = hnew->globals_signs[i];
	free(hnew->globals_signs);
	hnew->globals_signs = nsigns;

	for(i=0;i<c->ntypes;i++) {
		hl_type *t = c->types + i;
		switch( t->kind ) {
		case HSTRUCT:
		case HOBJ:
			if( t->obj->global_value )
				t->obj->global_value = (void*)(int_val)(remap[(int)(int_val)t->obj->global_value - 1] + 1);
			break;
		case HENUM:
			if( t->tenum->global_value )
				t->tenum->global_value = (void*)(int_val)(remap[(int)(int_val)t->tenum->global_value - 1] + 1);
			break;
		default:
			break;
		}
	}
	for(i=0;i<c->nconstants;i++)
		c->constants[i].global = remap[c->constants[i].global];

	for(i=0;i<c->nfunctions;i++) {
		hl_function *f = c->functions + i;
		int k;
		for(k=0;k<f->nops;k++) {
			hl_opcode *op = f->ops + k;
			switch( op->op ) {
			case OGetGlobal:
				op->p2 = remap[op->p2];
				break;
			case OSetGlobal:
				op->p1 = remap[op->p1];
				break;
			default:
				break;
			}
		}
	}

	free(remap);
}

void hl_code_hash_finalize( hl_code_hash *h ) {
	hl_code *c = h->code;
	int i;
	h->functions_signs = malloc(sizeof(int) * (c->nfunctions + c->nnatives));
	for(i=0;i<c->nfunctions;i++) {
		hl_function *f = c->functions + i;
		h->functions_signs[i] = hash_fun_sign(h, f);
	}
	for(i=0;i<c->nnatives;i++) {
		hl_native *n = c->natives + i;
		h->functions_signs[i + c->nfunctions] = hash_native(h,n);
	}
	h->functions_hashes = malloc(sizeof(int) * c->nfunctions);
	for(i=0;i<c->nfunctions;i++) {
		hl_function *f = c->functions + i;
		h->functions_hashes[i] = hash_fun(h,f);
	}
}

void hl_code_hash_free( hl_code_hash *h ) {
	free(h->functions_hashes);
	free(h->functions_indexes);
	free(h->functions_signs);
	free(h->globals_signs);
	free(h->types_hashes);
	free(h);
}

