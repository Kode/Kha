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
#include "hl.h"

#ifdef _DEBUG
//#define OP_LOG
//#define JIT_DEBUG
#endif

typedef enum {
	Eax = 0,
	Ecx = 1,
	Edx = 2,
	Ebx = 3,
	Esp = 4,
	Ebp = 5,
	Esi = 6,
	Edi = 7,
#ifdef HL_64
	R8 = 8,
	R9 = 9,
	R10	= 10,
	R11	= 11,
	R12	= 12,
	R13	= 13,
	R14	= 14,
	R15	= 15,
#endif
	_LAST = 0xFF
} CpuReg;

typedef enum {
	MOV,
	PUSH,
	ADD,
	SUB,
	IMUL,	// only overflow flag changes compared to MUL
	DIV,
	IDIV,
	CDQ,
	POP,
	RET,
	CALL,
	AND,
	OR,
	XOR,
	CMP,
	TEST,
	NOP,
	SHL,
	SHR,
	SAR,
	INC,
	DEC,
	// SSE
	MOVSD,
	COMISD,
	ADDSD,
	SUBSD,
	MULSD,
	DIVSD,
	XORPD,
	CVTSI2SD,
	CVTSD2SI,
	// 8 bits
	MOV8,
	// --
	_CPU_LAST
} CpuOp;

#define JAlways		0
#define JOverflow	0x80
#define JULt		0x82
#define JUGte		0x83
#define JEq			0x84
#define JNeq		0x85
#define JULte		0x86
#define JUGt		0x87
#define JSLt		0x8C
#define JSGte		0x8D
#define JSLte		0x8E
#define JSGt		0x8F

#define JCarry		JLt
#define JZero		JEq
#define JNotZero	JNeq

#define B(bv)	*ctx->buf.b++ = bv
#define W(wv)	*ctx->buf.w++ = wv

#ifdef HL_64
#	define W64(wv)	*ctx->buf.w64++ = wv
#else
#	define W64(wv)	W(wv)
#endif

static int SIB_MULT[] = {-1, 0, 1, -1, 2, -1, -1, -1, 3};

#define MOD_RM(mod,reg,rm)		B(((mod) << 6) | (((reg)&7) << 3) | ((rm)&7))
#define SIB(mult,rmult,rbase)	B((SIB_MULT[mult]<<6) | (((rmult)&7)<<3) | ((rbase)&7))
#define IS_SBYTE(c)				( (c) >= -128 && (c) < 128 )

#define AddJump(how,local)		{ if( (how) == JAlways ) { B(0xE9); } else { B(0x0F); B(how); }; local = BUF_POS(); W(0); }
#define AddJump_small(how,local) { if( (how) == JAlways ) { B(0xEB); } else B(how - 0x10); local = BUF_POS() | 0x40000000; B(0); }
#ifdef OP_LOG
#	define XJump(how,local)		{ AddJump(how,local); printf("%s\n",(how) == JAlways ? "JUMP" : JUMP_NAMES[(how)&0x7F]); }
#	define XJump_small(how,local)		{ AddJump_small(how,local); printf("%s\n",(how) == JAlways ? "JUMP" : JUMP_NAMES[(how)&0x7F]); }
#else
#	define XJump(how,local)		AddJump(how,local)
#	define XJump_small(how,local)		AddJump_small(how,local)
#endif

#define MAX_OP_SIZE				64

#define TODO()					printf("TODO(jit.c:%d)\n",__LINE__)

#define BUF_POS()				((int)(ctx->buf.b - ctx->startBuf))
#define RTYPE(r)				r->t->kind

typedef struct jlist jlist;
struct jlist {
	int pos;
	int target;
	jlist *next;
};

typedef struct vreg vreg;

typedef enum {
	RCPU = 0,
	RFPU = 1,
	RSTACK = 2,
	RCONST = 3,
	RADDR = 4,
	RMEM = 5,
	RUNUSED = 6
} preg_kind;

typedef struct {
	preg_kind kind;
	int id;
	int lock;
	vreg *holds;
} preg;

struct vreg {
	int stackPos;
	int size;
	hl_type *t;
	preg *current;
	preg stack;
};

#define REG_AT(i)		(ctx->pregs + (i))

#ifdef HL_64
#	define RCPU_COUNT	14
#	define RFPU_COUNT	16
#	ifdef HL_WIN_CALL
#		define RCPU_SCRATCH_COUNT	7
#		define RFPU_SCRATCH_COUNT	6
static int RCPU_SCRATCH_REGS[] = { Eax, Ecx, Edx, R8, R9, R10, R11 };
static CpuReg CALL_REGS[] = { Ecx, Edx, R8, R9 };
#	else
#		define RCPU_SCRATCH_COUNT	9
#		define RFPU_SCRATCH_COUNT	16
static int RCPU_SCRATCH_REGS[] = { Eax, Ecx, Edx, Esi, Edi, R8, R9, R10, R11 };
static CpuReg CALL_REGS[] = { Edi, Esi, Edx, Ecx, R8, R9 };
#	endif
#else
#	define RCPU_COUNT	8
#	define RFPU_COUNT	8
#	define RCPU_SCRATCH_COUNT	3
#	define RFPU_SCRATCH_COUNT	8
static int RCPU_SCRATCH_REGS[] = { Eax, Ecx, Edx };
#endif

#define XMM(i)			((i) + RCPU_COUNT)
#define PXMM(i)			REG_AT(XMM(i))

#define PEAX			REG_AT(Eax)
#define PESP			REG_AT(Esp)
#define PEBP			REG_AT(Ebp)

#define REG_COUNT	(RCPU_COUNT + RFPU_COUNT)

#define ID2(a,b)	((a) | ((b)<<8))
#define R(id)		(ctx->vregs + (id))
#define ASSERT(i)	{ printf("JIT ERROR %d (jic.c line %d)\n",i,__LINE__); jit_exit(); }
#define IS_FLOAT(r)	((r)->t->kind == HF64)
#define RLOCK(r)		if( (r)->lock < ctx->currentPos ) (r)->lock = ctx->currentPos
#define RUNLOCK(r)		if( (r)->lock == ctx->currentPos ) (r)->lock = 0

#define BREAK()		B(0xCC)

static preg _unused = { RUNUSED, 0, 0, NULL };
static preg *UNUSED = &_unused;

struct jit_ctx {
	union {
		unsigned char *b;
		unsigned int *w;
		unsigned long long *w64;
		int *i;
		double *d;
	} buf;
	vreg *vregs;
	preg pregs[REG_COUNT];
	int *opsPos;
	int maxRegs;
	int maxOps;
	int bufSize;
	int totalRegsSize;
	int functionPos;
	int allocOffset;
	int currentPos;
	unsigned char *startBuf;
	hl_module *m;
	hl_function *f;
	jlist *jumps;
	jlist *calls;
	hl_alloc falloc; // cleared per-function
	hl_alloc galloc;
};

static void jit_exit() {
	exit(-1);
}

static preg *pmem( preg *r, CpuReg reg, int offset ) {
	r->kind = RMEM;
	r->id = 0 | (reg << 4) | (offset << 8);
	return r;
}

static preg *pmem2( preg *r, CpuReg reg, CpuReg reg2, int mult, int offset ) {
	r->kind = RMEM;
	r->id = mult | (reg << 4) | (reg2 << 8);
	r->holds = (void*)offset;
	return r;
}

#ifdef HL_64
static preg *pcodeaddr( preg *r, int offset ) {
	r->kind = RMEM;
	r->id = 15 | (offset << 4);
	return r;
}
#endif

static preg *pconst( preg *r, int c ) {
	r->kind = RCONST;
	r->holds = NULL;
	r->id = c;
	return r;
}

static preg *pconst64( preg *r, int_val c ) {
	r->kind = RCONST;
	r->id = 0xC064C064;
	r->holds = (vreg*)c;
	return r;
}

static preg *paddr( preg *r, void *p ) {
	r->kind = RADDR;
	r->holds = (vreg*)p;
	return r;
}

static void jit_buf( jit_ctx *ctx ) {
	if( BUF_POS() > ctx->bufSize - MAX_OP_SIZE ) {
		int nsize = ctx->bufSize * 4 / 3;
		unsigned char *nbuf;
		int curpos;
		if( nsize == 0 ) {
			int i;
			for(i=0;i<ctx->m->code->nfunctions;i++)
				nsize += ctx->m->code->functions[i].nops;
			nsize *= 4;
		}
		if( nsize < ctx->bufSize + MAX_OP_SIZE * 4 ) nsize = ctx->bufSize + MAX_OP_SIZE * 4;
		curpos = BUF_POS();
		nbuf = (unsigned char*)malloc(nsize);
		if( nbuf == NULL ) ASSERT(nsize);
		if( ctx->startBuf ) {
			memcpy(nbuf,ctx->startBuf,curpos);
			free(ctx->startBuf);
		}
		ctx->startBuf = nbuf;
		ctx->buf.b = nbuf + curpos;
		ctx->bufSize = nsize;
	}
}

static const char *KNAMES[] = { "cpu","fpu","stack","const","addr","mem","unused" };
#define ERRIF(c)	if( c ) { printf("%s(%s,%s)\n",f?f->name:"???",KNAMES[a->kind], KNAMES[b->kind]); ASSERT(0); }

typedef struct {
	const char *name;						// single operand
	int r_mem;		// r32 / r/m32				r32
	int mem_r;		// r/m32 / r32				r/m32
	int r_const;	// r32 / imm32				imm32
	int r_i8;		// r32 / imm8				imm8
	int mem_const;	// r/m32 / imm32			N/A
} opform;

#define RM(op,id) ((op) | (((id)+1)<<8))
#define GET_RM(op)	(((op) >> 8) & 15)
#define SBYTE(op) ((op) << 16)
#define LONG_OP(op)	((op) | 0x80000000)

static opform OP_FORMS[_CPU_LAST] = {
	{ "MOV", 0x8B, 0x89, 0xB8, 0, RM(0xC7,0) },
	{ "PUSH", 0x50, RM(0xFF,6), 0x68, 0x6A },
	{ "ADD", 0x03, 0x01, RM(0x81,0), RM(0x83,0) },
	{ "SUB", 0x2B, 0x29, RM(0x81,5), RM(0x83,5) },
	{ "IMUL", LONG_OP(0x0FAF) },
	{ "DIV", RM(0xF7,6), RM(0xF7,6) },
	{ "IDIV", RM(0xF7,7), RM(0xF7,7) },
	{ "CDQ", 0x99 },
	{ "POP", 0x58, RM(0x8F,0) },
	{ "RET", 0xC3 },
	{ "CALL", RM(0xFF,2), RM(0xFF,2), 0xE8 },
	{ "AND", 0x23, 0x21, RM(0x81,4), RM(0x83,4) },
	{ "OR", 0x0B, 0x09, RM(0x81,1), RM(0x83,1) },
	{ "XOR", 0x33, 0x31, RM(0x81,6), RM(0x83,6) },
	{ "CMP", 0x3B, 0x39, RM(0x81,7), RM(0x83,7) },
	{ "TEST", 0x85, 0x85/*SWP?*/, RM(0xF7,0) },
	{ "NOP", 0x90 },
	{ "SHL", RM(0xD3,4), 0, 0, RM(0xC1,4) },
	{ "SHR", RM(0xD3,5), 0, 0, RM(0xC1,5) },
	{ "SAR", RM(0xD3,7), 0, 0, RM(0xC1,7) },
	{ "INC", IS_64 ? RM(0xFF,0) : 0x40, RM(0xFF,0) },
	{ "DEC", IS_64 ? RM(0xFF,1) : 0x48, RM(0xFF,1) },
	// SSE
	{ "MOVSD", 0xF20F10, 0xF20F11  },
	{ "COMISD", 0x660F2F },
	{ "ADDSD", 0xF20F58 },
	{ "SUBSD", 0xF20F5C },
	{ "MULSD", 0xF20F59 },
	{ "DIVSD", 0xF20F5E },
	{ "XORPD", 0x660F57 },
	{ "CVTSI2SD", 0xF20F2A },
	{ "CVTSD2SI", 0xF20F2D },
	// 8 bits,
	{ "MOV8", 0x8A, 0x88, 0, 0xB0, RM(0xC6,0) },
};

#ifdef OP_LOG

static const char *REG_NAMES[] = { "ax", "cx", "dx", "bx", "sp", "bp", "si", "di" }; 
static const char *JUMP_NAMES[] = { "JOVERFLOW", "J???", "JLT", "JGTE", "JEQ", "JNEQ", "JLTE", "JGT", "J?8", "J?9", "J?A", "J?B", "JSLT", "JSGTE", "JSLTE", "JSGT" };

static const char *preg_str( jit_ctx *ctx, preg *r, bool mode64 ) {
	static char buf[64];
	switch( r->kind ) {
	case RCPU:
		if( r->id < 8 )
			sprintf(buf,"%c%s",mode64?'r':'e',REG_NAMES[r->id]);
		else
			sprintf(buf,"r%d%s",r->id,mode64?"":"d");
		break;
	case RFPU:
		sprintf(buf,"xmm%d%s",r->id,mode64?"":"f");
		break;
	case RSTACK:
		{
			int sp = R(r->id)->stackPos;
			sprintf(buf,"@%d[%s%Xh]",r->id,sp < 0 ? "-" : "", sp < 0 ? -sp : sp);
		}
		break;
	case RCONST:
		{
			int_val v = r->holds ? (int_val)r->holds : r->id;
			sprintf(buf,"%s" _PTR_FMT "h",v < 0 ? "-" : "", v < 0 ? -v : v);
		}
		break;
	case RMEM:
		{
			int mult = r->id & 0xF;
			int regOrOffs = mult == 15 ? r->id >> 4 : r->id >> 8;  
			CpuReg reg = (r->id >> 4) & 0xF;
			if( mult == 15 ) {
				sprintf(buf,"%s ptr[%c%Xh]",mode64 ? "qword" : "dword", regOrOffs<0?'-':'+',regOrOffs<0?-regOrOffs:regOrOffs);
			} else if( mult == 0 ) {
				int off = regOrOffs;
				if( reg < 8 )
					sprintf(buf,"[%c%s %c %Xh]",mode64?'r':'e',REG_NAMES[reg], off < 0 ? '-' : '+', off < 0 ? -off : off);
				else
					sprintf(buf,"[r%d%s %c %Xh]",reg,mode64?"":"d",off < 0 ? '-' : '+', off < 0 ? -off : off);
			} else {
				return "TODO";
			}
		}
		break;
	case RADDR:
		sprintf(buf, "%s ptr[" _PTR_FMT "h]", mode64 ? "qword" : "dword", r->holds);
		break;
	default:
		return "???";
	}
	return buf;
}

static void log_op( jit_ctx *ctx, CpuOp o, preg *a, preg *b, bool mode64 ) {
	opform *f = &OP_FORMS[o];
	printf("@%d %s%s",ctx->currentPos-1, f->name,mode64?"64":"");
	if( a->kind != RUNUSED )
		printf(" %s",preg_str(ctx, a, mode64));
	if( b->kind != RUNUSED )
		printf(",%s",preg_str(ctx, b, mode64));
	printf("\n");
}

#endif

#ifdef HL_64
#	define REX()	if( r64 ) B(r64 | 0x40)
#else
#	define REX()
#endif

#define	OP(b)	if( (b) & 0xFF0000 ) {  B((b)>>16); if( r64 ) B(r64 | 0x40); B((b)>>8); B(b); } else { REX(); if( (b) < 0 ) B((b)>>8); B(b); }

static void op( jit_ctx *ctx, CpuOp o, preg *a, preg *b, bool mode64 ) {
	opform *f = &OP_FORMS[o];
	int r64 = mode64 && (o != PUSH && o != POP && o != CALL) ? 8 : 0;
#	ifdef OP_LOG
	log_op(ctx,o,a,b,mode64 && IS_64);
#	endif
	switch( ID2(a->kind,b->kind) ) {
	case ID2(RUNUSED,RUNUSED):
		ERRIF(f->r_mem == 0);
		OP(f->r_mem);
		break;
	case ID2(RCPU,RCPU):
	case ID2(RFPU,RFPU):
		ERRIF( f->r_mem == 0 );
		if( a->id > 7 ) r64 |= 4;
		if( b->id > 7 ) r64 |= 1;
		OP(f->r_mem);
		MOD_RM(3,a->id,b->id);
		break;
	case ID2(RCPU,RFPU):
	case ID2(RFPU,RCPU):
		ERRIF( (f->r_mem>>16) == 0 );
		if( a->id > 7 ) r64 |= 4;
		if( b->id > 7 ) r64 |= 1;
		OP(f->r_mem);
		MOD_RM(3,a->id,b->id);
		break;
	case ID2(RCPU,RUNUSED):
		ERRIF( f->r_mem == 0 );
		if( a->id > 7 ) r64 |= 1;
		if( GET_RM(f->r_mem) > 0 ) {
			OP(f->r_mem);
			MOD_RM(3, GET_RM(f->r_mem)-1, a->id); 
		} else
			OP(f->r_mem + (a->id&7));
		break;
	case ID2(RSTACK,RUNUSED):
		ERRIF( f->mem_r == 0 || GET_RM(f->mem_r) == 0 );
		{
			int stackPos = R(a->id)->stackPos;
			OP(f->mem_r);
			if( IS_SBYTE(stackPos) ) {
				MOD_RM(1,GET_RM(f->mem_r)-1,Ebp);
				B(stackPos);
			} else {
				MOD_RM(2,GET_RM(f->mem_r)-1,Ebp);
				W(stackPos);
			}
		}
		break;
	case ID2(RCPU,RCONST):
		ERRIF( f->r_const == 0 && f->r_i8 == 0 );
		if( a->id > 7 ) r64 |= 1;
		{
			int_val cval = b->holds ? (int_val)b->holds : b->id;
			// short byte form
			if( f->r_i8 && IS_SBYTE(cval) ) {
				OP(f->r_i8);
				MOD_RM(3,GET_RM(f->r_i8)-1,a->id);
				B((int)cval);
			} else if( GET_RM(f->r_const) > 0 ) {
				OP(f->r_const&0xFF);
				MOD_RM(3,GET_RM(f->r_const)-1,a->id);
				if( mode64 && IS_64 && o == MOV ) W64(cval); else W((int)cval);
			} else {
				ERRIF( f->r_const == 0);
				OP((f->r_const&0xFF) + (a->id&7));
				if( mode64 && IS_64&& o == MOV ) W64(cval); else W((int)cval);
			}
		}
		break;
	case ID2(RSTACK,RCPU):
	case ID2(RSTACK,RFPU):
		ERRIF( f->mem_r == 0 );
		if( b->id > 7 ) r64 |= 4;
		{
			int stackPos = R(a->id)->stackPos;
			OP(f->mem_r);
			if( IS_SBYTE(stackPos) ) {
				MOD_RM(1,b->id,Ebp);
				B(stackPos);
			} else {
				MOD_RM(2,b->id,Ebp);
				W(stackPos);
			}
		}
		break;
	case ID2(RCPU,RSTACK):
	case ID2(RFPU,RSTACK):
		ERRIF( f->r_mem == 0 );
		if( a->id > 7 ) r64 |= 4;
		{
			int stackPos = R(b->id)->stackPos;
			OP(f->r_mem);
			if( IS_SBYTE(stackPos) ) {
				MOD_RM(1,a->id,Ebp);
				B(stackPos);
			} else {
				MOD_RM(2,a->id,Ebp);
				W(stackPos);
			}
		}
		break;
	case ID2(RCONST,RUNUSED):
		ERRIF( f->r_const == 0 );
		{
			int_val cval = a->holds ? (int_val)a->holds : a->id;
			OP(f->r_const);
			if( mode64 && IS_64 ) W64(cval); else W((int)cval);
		}
		break;
	case ID2(RMEM,RUNUSED):
		ERRIF( f->mem_r == 0 );
		{
			int mult = a->id & 0xF;
			int regOrOffs = mult == 15 ? a->id >> 4 : a->id >> 8;  
			CpuReg reg = (a->id >> 4) & 0xF;
			if( mult == 15 ) {
				ERRIF(1);
			} else if( mult == 0 ) {
				if( reg > 7 ) r64 |= 1;
				OP(f->mem_r);
				if( regOrOffs == 0 && (reg&7) != Ebp ) {
					MOD_RM(0,GET_RM(f->mem_r)-1,reg);
					if( (reg&7) == Esp ) B(0x24);
				} else if( IS_SBYTE(regOrOffs) ) {
					MOD_RM(1,GET_RM(f->mem_r)-1,reg);
					if( (reg&7) == Esp ) B(0x24);
					B(regOrOffs);
				} else {
					MOD_RM(2,GET_RM(f->mem_r)-1,reg);
					if( (reg&7) == Esp ) B(0x24);
					W(regOrOffs);
				}
			} else {
				// [eax + ebx * M]
				ERRIF(1);
			}
		}
		break;
	case ID2(RCPU, RMEM):
	case ID2(RFPU, RMEM):
		ERRIF( f->r_mem == 0 );
		{
			int mult = b->id & 0xF;
			int regOrOffs = mult == 15 ? b->id >> 4 : b->id >> 8;  
			CpuReg reg = (b->id >> 4) & 0xF;
			if( mult == 15 ) {
				int pos;
				if( a->id > 7 ) r64 |= 4;
				OP(f->r_mem);
				MOD_RM(0,a->id,5);
				if( IS_64 ) {
					// offset wrt current code
					pos = BUF_POS() + 4;
					W(regOrOffs - pos);
				} else {
					ERRIF(1);
				}
			} else if( mult == 0 ) {
				if( a->id > 7 ) r64 |= 4;
				if( reg > 7 ) r64 |= 1;
				OP(f->r_mem);
				if( regOrOffs == 0 && (reg&7) != Ebp ) {
					MOD_RM(0,a->id,reg);
					if( (reg&7) == Esp ) B(0x24);
				} else if( IS_SBYTE(regOrOffs) ) {
					MOD_RM(1,a->id,reg);
					if( (reg&7) == Esp ) B(0x24);
					B(regOrOffs);
				} else {
					MOD_RM(2,a->id,reg);
					if( (reg&7) == Esp ) B(0x24);
					W(regOrOffs);
				}
			} else {
				int offset = (int)(int_val)b->holds;
				if( a->id > 7 ) r64 |= 4;
				if( reg > 7 ) r64 |= 1;
				if( regOrOffs > 7 ) r64 |= 2;
				OP(f->r_mem);
				MOD_RM(offset == 0 ? 0 : IS_SBYTE(offset) ? 1 : 2,a->id,4);
				SIB(mult,regOrOffs,reg);
				if( offset ) {
					if( IS_SBYTE(offset) ) B(offset); else W(offset);
				}
			}
		}
		break;
#	ifndef HL_64
	case ID2(RFPU,RADDR):
#	endif
	case ID2(RCPU,RADDR):
		ERRIF( f->r_mem == 0 );
		if( a->id > 7 ) r64 |= 4;
		OP(f->r_mem);
		MOD_RM(0,a->id,5);
		if( IS_64 )
			W64((int_val)b->holds);
		else
			W((int)(int_val)b->holds);
		break;
#	ifndef HL_64
	case ID2(RADDR,RFPU):
#	endif
	case ID2(RADDR,RCPU):
		ERRIF( f->mem_r == 0 );
		if( b->id > 7 ) r64 |= 4;
		OP(f->mem_r);
		MOD_RM(0,b->id,5);
		if( IS_64 )
			W64((int_val)a->holds);
		else
			W((int)(int_val)a->holds);
		break;
	case ID2(RMEM, RCPU):
	case ID2(RMEM, RFPU):
		ERRIF( f->mem_r == 0 );
		{
			int mult = a->id & 0xF;
			int regOrOffs = mult == 15 ? a->id >> 4 : a->id >> 8;  
			CpuReg reg = (a->id >> 4) & 0xF;
			if( mult == 15 ) {
				int pos;
				if( b->id > 7 ) r64 |= 4;
				OP(f->mem_r);
				MOD_RM(0,b->id,5);
				if( IS_64 ) {
					// offset wrt current code
					pos = BUF_POS() + 4;
					W(regOrOffs - pos);
				} else {
					ERRIF(1);
				}
			} else if( mult == 0 ) {
				if( b->id > 7 ) r64 |= 4;
				if( reg > 7 ) r64 |= 1;
				OP(f->mem_r);
				if( regOrOffs == 0 && (reg&7) != Ebp ) {
					MOD_RM(0,b->id,reg);
					if( (reg&7) == Esp ) B(0x24);
				} else if( IS_SBYTE(regOrOffs) ) {
					MOD_RM(1,b->id,reg);
					if( (reg&7) == Esp ) B(0x24);
					B(regOrOffs);
				} else {
					MOD_RM(2,b->id,reg);
					if( (reg&7) == Esp ) B(0x24);
					W(regOrOffs);
				}
			} else {
				int offset = (int)(int_val)a->holds;
				if( b->id > 7 ) r64 |= 4;
				if( reg > 7 ) r64 |= 1;
				if( regOrOffs > 7 ) r64 |= 2;
				OP(f->mem_r);
				MOD_RM(offset == 0 ? 0 : IS_SBYTE(offset) ? 1 : 2,b->id,4);
				SIB(mult,regOrOffs,reg);
				if( offset ) {
					if( IS_SBYTE(offset) ) B(offset); else W(offset);
				}
			}
		}
		break;
	default:
		ERRIF(1);
	}
}

static void op32( jit_ctx *ctx, CpuOp o, preg *a, preg *b ) {
	op(ctx,o,a,b,false);
}

static void op64( jit_ctx *ctx, CpuOp o, preg *a, preg *b ) {
#ifndef HL_64
	op(ctx,o,a,b,false);
#else
	op(ctx,o,a,b,true);
#endif
}

static void patch_jump( jit_ctx *ctx, int p ) {
	if( p == 0 ) return;
	if( p & 0x40000000 ) {
		int d;
		p &= 0x3FFFFFFF;
		d = BUF_POS() - (p + 1);
		if( d < -128 || d >= 128 ) ASSERT(d);
		*(char*)(ctx->startBuf + p) = (char)d;
	} else {
		*(int*)(ctx->startBuf + p) = BUF_POS() - (p + 4);
	}
}

static void patch_jump_to( jit_ctx *ctx, int p, int target ) {
	if( p == 0 ) return;
	if( p & 0x40000000 ) {
		int d;
		p &= 0x3FFFFFFF;
		d = target - (p + 1);
		if( d < -128 || d >= 128 ) ASSERT(d);
		*(char*)(ctx->startBuf + p) = (char)d;
	} else {
		*(int*)(ctx->startBuf + p) = target - (p + 4);
	}
}

static preg *alloc_reg( jit_ctx *ctx, preg_kind k ) {
	int i;
	preg *p;
	switch( k ) {
	case RCPU:
		{
			int off = ctx->allocOffset++;
			const int count = RCPU_SCRATCH_COUNT;
			for(i=0;i<count;i++) {
				int r = RCPU_SCRATCH_REGS[(i + off)%count];
				p = ctx->pregs + r;
				if( p->lock >= ctx->currentPos ) continue;
				if( p->holds == NULL ) {
					RLOCK(p);
					return p;
				}
			}
			for(i=0;i<count;i++) {
				preg *p = ctx->pregs + RCPU_SCRATCH_REGS[(i + off)%count];
				if( p->lock >= ctx->currentPos ) continue;
				if( p->holds ) {
					RLOCK(p);
					p->holds->current = NULL;
					p->holds = NULL;
					return p;
				}
			}
		}
		break;
	case RFPU:
		{
			int off = ctx->allocOffset++;
			const int count = RFPU_SCRATCH_COUNT;
			for(i=0;i<count;i++) {
				preg *p = PXMM((i + off)%count);
				if( p->lock >= ctx->currentPos ) continue;
				if( p->holds == NULL ) {
					RLOCK(p);
					return p;
				}
			}
			for(i=0;i<count;i++) {
				preg *p = PXMM((i + off)%count);
				if( p->lock >= ctx->currentPos ) continue;
				if( p->holds ) {
					RLOCK(p);
					p->holds->current = NULL;
					p->holds = NULL;
					return p;
				}
			}
		}
		break;
	default:
		ASSERT(k);
	}
	ASSERT(0); // out of registers !
	return NULL;
}

static preg *fetch( vreg *r ) {
	if( r->current )
		return r->current;
	return &r->stack;
}

static void scratch( preg *r ) {
	if( r && r->holds ) {
		r->holds->current = NULL;
		r->holds = NULL;
	}
}

static preg *copy( jit_ctx *ctx, preg *to, preg *from, int size );

static void load( jit_ctx *ctx, preg *r, vreg *v ) {
	preg *from = fetch(v);
	if( from == r || v->size == 0 ) return;
	if( r->holds ) r->holds->current = NULL;
	r->holds = v;
	v->current = r;
	copy(ctx,r,from,v->size);
}

static preg *alloc_fpu( jit_ctx *ctx, vreg *r, bool andLoad ) {
	preg *p = fetch(r);
	if( p->kind != RFPU ) {
		if( r->size != 8 ) ASSERT(r->size);
		p = alloc_reg(ctx, RFPU);
		if( andLoad )
			load(ctx,p,r);
		else {
			if( r->current )
				r->current->holds = NULL;
			r->current = p;
			p->holds = r;
		}
	}
	return p;
}

static preg *alloc_cpu( jit_ctx *ctx, vreg *r, bool andLoad ) {
	preg *p = fetch(r);
	if( p->kind != RCPU ) {
#		ifndef HL_64
		if( r->size > 4 ) ASSERT(r->size);
#		endif
		p = alloc_reg(ctx, RCPU);
		if( andLoad )
			load(ctx,p,r);
		else {
			if( r->current )
				r->current->holds = NULL;
			r->current = p;
			p->holds = r;
		}
	}
	return p;
}

static preg *copy( jit_ctx *ctx, preg *to, preg *from, int size ) {
	if( size == 0 || to == from ) return to;
	switch( ID2(to->kind,from->kind) ) {
	case ID2(RMEM,RCPU):
	case ID2(RSTACK,RCPU):
	case ID2(RCPU,RSTACK):
	case ID2(RCPU,RMEM):
	case ID2(RCPU,RCPU):
#	ifndef HL_64
	case ID2(RCPU,RADDR):
	case ID2(RADDR,RCPU):
#	endif
		switch( size ) {
		case 1:
			op32(ctx,MOV8,to,from);
			break;
		case 4:
			op32(ctx,MOV,to,from);
			break;
		case 8:
			if( IS_64 ) {
				op64(ctx,MOV,to,from);
				break;
			}
		default:
			ASSERT(size);
		}
		return to->kind == RCPU ? to : from;
	case ID2(RFPU,RFPU):
	case ID2(RMEM,RFPU):
	case ID2(RSTACK,RFPU):
	case ID2(RFPU,RMEM):
	case ID2(RFPU,RSTACK):
		switch( size ) {
		case 8:
			op64(ctx,MOVSD,to,from);
			break;
		default:
			ASSERT(size);
		}
		return to->kind == RFPU ? to : from;
	case ID2(RMEM,RSTACK):
		{
			vreg *rfrom = R(from->id);
			if( IS_FLOAT(rfrom) )
				return copy(ctx,to,alloc_fpu(ctx,rfrom,true),size);
			return copy(ctx,to,alloc_cpu(ctx,rfrom,true),size);
		}
	case ID2(RMEM,RMEM):
	case ID2(RSTACK,RMEM):
	case ID2(RSTACK,RSTACK):
#	ifndef HL_64
	case ID2(RMEM,RADDR):
	case ID2(RSTACK,RADDR):
#	endif
		{
			preg *tmp;
			if( size == 8 && !IS_64 ) {
				tmp = alloc_reg(ctx, RFPU);
				op64(ctx,MOVSD,tmp,from);
			} else {
				tmp = alloc_reg(ctx, RCPU);
				copy(ctx,tmp,from,size);
			}
			return copy(ctx,to,tmp,size);
		}
#	ifdef HL_64
	case ID2(RCPU,RADDR):
	case ID2(RMEM,RADDR):
	case ID2(RSTACK,RADDR):
		{
			preg p;
			preg *tmp = alloc_reg(ctx, RCPU);
			op64(ctx,MOV,tmp,pconst64(&p,(int_val)from->holds));
			return copy(ctx,to,pmem(&p,tmp->id,0),size);
		}
	case ID2(RADDR,RCPU):
	case ID2(RADDR,RMEM):
	case ID2(RADDR,RSTACK):
		{
			preg p;
			preg *tmp = alloc_reg(ctx, RCPU);
			op64(ctx,MOV,tmp,pconst64(&p,(int_val)to->holds));
			return copy(ctx,pmem(&p,tmp->id,0),from,size);
		}
#	endif
	default:
		break;
	}
	printf("copy(%s,%s)\n",KNAMES[to->kind], KNAMES[from->kind]);
	ASSERT(0);
	return NULL;
}

static void store( jit_ctx *ctx, vreg *r, preg *v, bool bind ) {
	if( r->current && r->current != v ) {
		r->current->holds = NULL;
		r->current = NULL;
	}
	v = copy(ctx,&r->stack,v,r->size);
	if( bind && r->current != v && (v->kind == RCPU || v->kind == RFPU) ) {
		scratch(v);
		r->current = v;
		v->holds = r;
	}
}

static void op_mov( jit_ctx *ctx, vreg *to, vreg *from ) {
	preg *r = fetch(from);
	store(ctx, to, r, true);
}

static void copy_to( jit_ctx *ctx, vreg *to, preg *from ) {
	store(ctx,to,from,true);
}

static void copy_from( jit_ctx *ctx, preg *to, vreg *from ) {
	copy(ctx,to,fetch(from),from->size);
}

static void store_const( jit_ctx *ctx, vreg *r, int c ) {
	preg p;
	if( r->size > 4 )
		ASSERT(r->size);
	if( c == 0 )
		op32(ctx,XOR,alloc_cpu(ctx,r,false),alloc_cpu(ctx,r,false));
	else
		op32(ctx,MOV,alloc_cpu(ctx,r,false),pconst(&p,c));
	store(ctx,r,r->current,false);
}

static void discard_regs( jit_ctx *ctx, bool native_call ) {
	int i;
	for(i=0;i<RCPU_SCRATCH_COUNT;i++) {
		preg *r = ctx->pregs + RCPU_SCRATCH_REGS[i];
		if( r->holds ) {
			r->holds->current = NULL;
			r->holds = NULL;
		}
	}
	for(i=0;i<RFPU_COUNT;i++) {
		preg *r = ctx->pregs + (i + RCPU_COUNT);
		if( r->holds ) {
			r->holds->current = NULL;
			r->holds = NULL;
		}
	}
}

static int pad_stack( jit_ctx *ctx, int size ) {
	int total = size + ctx->totalRegsSize + HL_WSIZE * 2; // EIP+EBP
	if( total & 15 ) {
		int pad = 16 - (total & 15);
		preg p;
		if( pad ) op64(ctx,SUB,PESP,pconst(&p,pad));
		size += pad;
	}
	return size;
}

static int prepare_call_args( jit_ctx *ctx, int count, int *args, vreg *vregs, bool isNative ) {
	int i;
	int stackRegs = count;
	int size = 0, paddedSize;
	preg p;
#ifdef HL_64
	if( isNative ) {
		for(i=0;i<count;i++) {
			vreg *v = vregs + args[i];
			preg *vr = fetch(v);
			preg *r = REG_AT(CALL_REGS[i]);
#			ifdef HL_WIN_CALL
			if( i == 4 ) break;
#			else
			// TODO : when more than 6 args
#			endif
			if( vr != r ) {
				copy(ctx,r,vr,v->size);
				scratch(r);
			}
			RLOCK(r);
		}
		stackRegs = count - i;
	}
#endif
	for(i=count - stackRegs;i<count;i++) {
		vreg *r = vregs + args[i];
		size += hl_pad_size(size,r->t);
		size += r->size;
	}
	paddedSize = pad_stack(ctx,size + ctx->totalRegsSize) - ctx->totalRegsSize;
	size = paddedSize - size;
	for(i=0;i<stackRegs;i++) {
		// RTL
		vreg *r = vregs + args[count - (i + 1)];
		int pad;
		size += r->size;
		pad = hl_pad_size(size,r->t);
		if( (i & 7) == 0 ) jit_buf(ctx);
		if( pad ) {
			op64(ctx,SUB,PESP,pconst(&p,pad));
			size += pad;
		}
		switch( r->size ) {
		case 4:
			if( !IS_64 )
				op32(ctx,PUSH,fetch(r),UNUSED);
			else {
				// pseudo push32 (not available)
				op64(ctx,SUB,PESP,pconst(&p,4));
				op32(ctx,MOV,pmem(&p,Esp,0),alloc_cpu(ctx,r,true));
			}
			break;
		case 8:
			if( fetch(r)->kind == RFPU ) {
				op64(ctx,SUB,PESP,pconst(&p,8));
				op64(ctx,MOVSD,pmem(&p,Esp,0),fetch(r));
			} else if( IS_64 )
				op64(ctx,PUSH,fetch(r),UNUSED);
			else if( r->stack.kind == RSTACK ) {
				scratch(r->current);
				r->stackPos += 4;
				op32(ctx,PUSH,&r->stack,UNUSED);
				r->stackPos -= 4;
				op32(ctx,PUSH,&r->stack,UNUSED);
			} else
				ASSERT(0);
			break;
		default:
			ASSERT(r->size);
		}
	}
	return paddedSize;
}

static void call_native( jit_ctx *ctx, void *nativeFun, int size ) {
	preg p;
#	if defined(HL_WIN_CALL) && defined(HL_64)
	// MSVC requires 32bytes of free space here
	op64(ctx,SUB,PESP,pconst(&p,32));
	size += 32;
#	endif
	// native function, already resolved
	op64(ctx,MOV,PEAX,pconst64(&p,(int_val)nativeFun));
	op64(ctx,CALL,PEAX,UNUSED);
	discard_regs(ctx, true);
	op64(ctx,ADD,PESP,pconst(&p,size));
}

static void op_call_fun( jit_ctx *ctx, vreg *dst, int findex, int count, int *args ) {
	int fid = findex < 0 ? -1 : ctx->m->functions_indexes[findex];
	int isNative = fid >= ctx->m->code->nfunctions;
	int size = prepare_call_args(ctx,count,args,ctx->vregs,isNative);
	preg p;
	if( fid < 0 ) {
		ASSERT(fid);
	} else if( isNative ) {
		call_native(ctx,ctx->m->functions_ptrs[findex],size);
		size = 0;
	} else {
		int cpos = BUF_POS();
		if( ctx->m->functions_ptrs[findex] ) {
			// already compiled
			op32(ctx,CALL,pconst(&p,(int)(int_val)ctx->m->functions_ptrs[findex] - (cpos + 5)), UNUSED);
		} else if( ctx->m->code->functions + fid == ctx->f ) {
			// our current function
			op32(ctx,CALL,pconst(&p, ctx->functionPos - (cpos + 5)), UNUSED);
		} else {
			// stage for later
			jlist *j = (jlist*)hl_malloc(&ctx->galloc,sizeof(jlist));
			j->pos = cpos;
			j->target = findex;
			j->next = ctx->calls;
			ctx->calls = j;
			op32(ctx,CALL,pconst(&p,0),UNUSED);
		}
		discard_regs(ctx, false);
	}
	if( size ) op64(ctx,ADD,PESP,pconst(&p,size));
	store(ctx, dst, IS_FLOAT(dst) ? PXMM(0) : PEAX, true);
}

static void op_call_closure( jit_ctx *ctx, vreg *dst, vreg *f, int nargs, int *rargs ) {
	/*
		We don't know in avance what is the size of the first argument of the closure, so we need 
		a dynamic check here.
		
		Note : sizes != 4/8 and closures of natives functions are directly handled into the compiler
		by creating a trampoline function.
	*/
	preg p;
	preg *r = alloc_cpu(ctx, f, true);
	preg *tmp;
	int i, has_param, double_param, end1, end2;
	tmp = alloc_reg(ctx, RCPU);
	// read bits
	op32(ctx,MOV,tmp,pmem(&p,(CpuReg)r->id,HL_WSIZE*2));
	op32(ctx,CMP,tmp,pconst(&p,0));
	XJump(JNeq,has_param);
	{
		// no argument call
		int size = prepare_call_args(ctx,nargs,rargs,ctx->vregs,false);
		op64(ctx,CALL,pmem(&p,(CpuReg)r->id,HL_WSIZE),UNUSED);
		if( size ) op64(ctx,ADD,PESP,pconst(&p,size));
		XJump(JAlways,end1);
	}
	patch_jump(ctx,has_param);
	op32(ctx,CMP,tmp,pconst(&p,1));
	XJump(JNeq,double_param);
	{
		// int32 argument call
		int *args;
		vreg *vargs;
		int size;

		// load our first arg into a fake vreg
		vreg fake;
		hl_type ti32;
		ti32.kind = HI32;
		fake.size = 4;
		fake.t = &ti32;
		fake.current = alloc_reg(ctx,RCPU);
		op32(ctx,MOV,fake.current,pmem(&p,(CpuReg)r->id,HL_WSIZE*2 + 8));

		// prepare the args
		vargs = (vreg*)hl_malloc(&ctx->falloc,sizeof(vreg)*(nargs+1));
		args = (int*)hl_malloc(&ctx->falloc,sizeof(int)*(nargs+1));
		vargs[0] = fake;
		args[0] = 0;
		for(i=0;i<nargs;i++) {
			vargs[i+1] = ctx->vregs[rargs[i]];
			args[i+1] = i + 1;
		}

		// call
		size = prepare_call_args(ctx,nargs+1,args,vargs,false);
		op64(ctx,CALL,pmem(&p,(CpuReg)r->id,HL_WSIZE),UNUSED);
		op64(ctx,ADD,PESP,pconst(&p,size));
		XJump(JAlways,end2);
	}
	patch_jump(ctx,double_param);
	{
		// int64 argument call
		int *args;
		vreg *vargs;
		int size;

		// load our first arg into a fake vreg
		vreg fake;
		hl_type ti64;
		ti64.kind = HF64;
		fake.size = 8;
		fake.t = &ti64;
		fake.current = alloc_reg(ctx,RFPU);

		op64(ctx,MOVSD,fake.current,pmem(&p,(CpuReg)r->id,HL_WSIZE*2 + 8));

		// prepare the args
		vargs = (vreg*)hl_malloc(&ctx->falloc,sizeof(vreg)*(nargs+1));
		args = (int*)hl_malloc(&ctx->falloc,sizeof(int)*(nargs+1));
		vargs[0] = fake;
		args[0] = 0;
		for(i=0;i<nargs;i++) {
			vargs[i+1] = ctx->vregs[rargs[i]];
			args[i+1] = i + 1;
		}

		// call
		size = prepare_call_args(ctx,nargs+1,args,vargs,false);
		op64(ctx,CALL,pmem(&p,(CpuReg)r->id,HL_WSIZE),UNUSED);
		op64(ctx,ADD,PESP,pconst(&p,size));
	}
	patch_jump(ctx,end1);
	patch_jump(ctx,end2);
	discard_regs(ctx, false);
	store(ctx, dst, IS_FLOAT(dst) ? PXMM(0) : PEAX, true);
}

static void op_enter( jit_ctx *ctx ) {
	preg p;
	op64(ctx, PUSH, PEBP, UNUSED);
	op64(ctx, MOV, PEBP, PESP);
	if( ctx->totalRegsSize ) op64(ctx, SUB, PESP, pconst(&p,ctx->totalRegsSize));
}

static void op_ret( jit_ctx *ctx, vreg *r ) {
	preg p;
	load(ctx, IS_FLOAT(r) ? PXMM(0) : PEAX, r);
	if( ctx->totalRegsSize ) op64(ctx, ADD, PESP, pconst(&p, ctx->totalRegsSize));
	op64(ctx, POP, PEBP, UNUSED);
	op64(ctx, RET, UNUSED, UNUSED);
}

static preg *op_binop( jit_ctx *ctx, vreg *dst, vreg *a, vreg *b, hl_opcode *op ) {
	preg *pa = fetch(a), *pb = fetch(b), *out = NULL;
	CpuOp o;
	if( IS_FLOAT(a) ) {
		switch( op->op ) {
		case OAdd: o = ADDSD; break;
		case OSub: o = SUBSD; break;
		case OMul: o = MULSD; break;
		case OSDiv: o = DIVSD; break;
		case OSGte:
		case OSLt:
		case OJSLt:
		case OJSGte:
		case OJEq:
		case OJNeq:
			o = COMISD;
			break;
		default:
			printf("%s\n", hl_op_name(op->op));
			ASSERT(op->op);
		}
	} else {
		switch( op->op ) {
		case OAdd: o = ADD; break;
		case OSub: o = SUB; break;
		case OMul: o = IMUL; break;
		case OAnd: o = AND; break;
		case OOr: o = OR; break;
		case OXor: o = XOR; break;
		case OShl:
		case OUShr: 
		case OSShr:
			if( !b->current || b->current->kind != RCPU || b->current->id != Ecx ) {
				scratch(REG_AT(Ecx));
				op32(ctx,MOV,REG_AT(Ecx),pb);
				RLOCK(REG_AT(Ecx));
				pa = fetch(a);
			}
			if( pa->kind != RCPU ) {
				pa = alloc_reg(ctx, RCPU);
				op32(ctx,MOV,pa,fetch(a));
			}
			op32(ctx,op->op == OShl ? SHL : (op->op == OUShr ? SHR : SAR), pa, UNUSED);
			if( dst ) store(ctx, dst, pa, true);
			return pa;
		case OSDiv:
		case OUDiv:
			{
				preg *r = alloc_cpu(ctx,b,true);
				int jz, jend;
				// integer div 0 => 0
				op32(ctx,TEST,r,r);
				XJump_small(JNotZero,jz);
				op32(ctx,XOR,PEAX,PEAX);
				XJump_small(JAlways,jend);
				patch_jump(ctx,jz);
				if( pa->kind != RCPU || pa->id != Eax ) {
					scratch(PEAX);
					load(ctx,PEAX,a);
				}
				scratch(REG_AT(Edx));
				if( op->op == OUDiv )
					op32(ctx, XOR, REG_AT(Edx), REG_AT(Edx));
				else
					op32(ctx, CDQ, UNUSED, UNUSED); // sign-extend Eax into Eax:Edx
				op32(ctx, op->op == OUDiv ? DIV : IDIV, pb, UNUSED);
				patch_jump(ctx, jend);
			}
			if( dst ) store(ctx, dst, PEAX, true);
			return PEAX;
		case OSGte:
		case OSLt:
		case OJSLt:
		case OJSGte:
		case OUGte:
		case OULt:
		case OJULt:
		case OJUGte:
		case OJEq:
		case OJNeq:
		case OEq:
		case ONotEq:
			o = CMP;
			break;
		default:
			printf("%s\n", hl_op_name(op->op));
			ASSERT(op->op);
		}
	}
	switch( RTYPE(a) ) {
	case HI32:
#	ifndef HL_64
	case HDYNOBJ:
	case HVIRTUAL:
	case HOBJ:
	case HFUN:
	case HBYTES:
#	endif
		switch( ID2(pa->kind, pb->kind) ) {
		case ID2(RCPU,RCPU):
		case ID2(RCPU,RSTACK):
			op32(ctx, o, pa, pb);
			scratch(pa);
			out = pa;
			break;
		case ID2(RSTACK,RCPU):
			if( dst == a ) {
				op32(ctx, o, pa, pb);
				dst = NULL;
				out = pa;
			} else {
				alloc_cpu(ctx,a, true);
				return op_binop(ctx,dst,a,b,op);
			}
			break;
		case ID2(RSTACK,RSTACK):
			alloc_cpu(ctx, a, true);
			return op_binop(ctx, dst, a, b, op);
		default:
			printf("%s(%d,%d)\n", hl_op_name(op->op), pa->kind, pb->kind);
			ASSERT(ID2(pa->kind, pb->kind));
		}
		if( dst ) store(ctx, dst, out, true);
		return out;
#	ifdef HL_64
	case HOBJ:
	case HDYNOBJ:
	case HVIRTUAL:
	case HFUN:
	case HBYTES:
		switch( ID2(pa->kind, pb->kind) ) {
		case ID2(RCPU,RCPU):
		case ID2(RCPU,RSTACK):
			op64(ctx, o, pa, pb);
			scratch(pa);
			out = pa;
			break;
		case ID2(RSTACK,RCPU):
			if( dst == a ) {
				op64(ctx, o, pa, pb);
				dst = NULL;
				out = pa;
			} else {
				alloc_cpu(ctx,a, true);
				return op_binop(ctx,dst,a,b,op);
			}
			break;
		case ID2(RSTACK,RSTACK):
			alloc_cpu(ctx, a, true);
			return op_binop(ctx, dst, a, b, op);
		default:
			printf("%s(%d,%d)\n", hl_op_name(op->op), pa->kind, pb->kind);
			ASSERT(ID2(pa->kind, pb->kind));
		}
		if( dst ) store(ctx, dst, out, true);
		return out;
#	endif
	case HF64:
		pa = alloc_fpu(ctx, a, true);
		pb = alloc_fpu(ctx, b, true);
		switch( ID2(pa->kind, pb->kind) ) {
		case ID2(RFPU,RFPU):
			op64(ctx,o,pa,pb);
			scratch(pa);
			out = pa;
			break;
		default:
			printf("%s(%d,%d)\n", hl_op_name(op->op), pa->kind, pb->kind);
			ASSERT(ID2(pa->kind, pb->kind));
		}
		if( dst ) store(ctx, dst, out, true);
		return out;
	default:
		ASSERT(RTYPE(a));
	}
	return NULL;
}

static int do_jump( jit_ctx *ctx, hl_op op, bool isFloat ) {
	int j;
	switch( op ) {
	case OJAlways:
		XJump(JAlways,j);
		break;
	case OSGte:
	case OJSGte:
		XJump(isFloat ? JUGte : JSGte,j);
		break;
	case OUGte:
	case OJUGte:
		XJump(JUGte,j);
		break;
	case OSLt:
	case OJSLt:
		XJump(isFloat ? JULt : JSLt,j);
		break;
	case OULt:
	case OJULt:
		XJump(JULt,j);
		break;
	case OEq:
	case OJEq:
		XJump(JEq,j);
		break;
	case ONotEq:
	case OJNeq:
		XJump(JNeq,j);
		break;
	default:
		j = 0;
		printf("Unknown JUMP %d\n",op);
		break;
	}
	return j;
}

static void op_cmp( jit_ctx *ctx, hl_opcode *op ) {
	int p, e;
	op_binop(ctx,NULL,R(op->p2),R(op->p3),op);
	p = do_jump(ctx,op->op,IS_FLOAT(R(op->p2)));
	store_const(ctx, R(op->p1), 0);
	e = do_jump(ctx,OJAlways,false);
	patch_jump(ctx,p);
	store_const(ctx, R(op->p1), 1);
	patch_jump(ctx,e);
}

static void register_jump( jit_ctx *ctx, int pos, int target ) {
	jlist *j = (jlist*)hl_malloc(&ctx->falloc, sizeof(jlist));
	j->pos = pos;
	j->target = target;
	j->next = ctx->jumps;
	ctx->jumps = j;
	if( target != 0 && ctx->opsPos[target] == 0 )
		ctx->opsPos[target] = -1;
}

static void call_native_consts( jit_ctx *ctx, void *nativeFun, int_val *args, int nargs ) {
	int size = pad_stack(ctx, IS_64 ? 0 : HL_WSIZE*nargs);
	preg p;
	int i;
#	ifdef HL_64
	for(i=0;i<nargs;i++)
		op64(ctx, MOV, REG_AT(CALL_REGS[i]), pconst64(&p, args[i]));
#	else
	for(i=nargs-1;i>=0;i--)
		op32(ctx, PUSH, pconst64(&p, args[i]), UNUSED);
#	endif
	call_native(ctx, nativeFun, size);
}

jit_ctx *hl_jit_alloc() {
	int i;
	jit_ctx *ctx = (jit_ctx*)malloc(sizeof(jit_ctx));
	if( ctx == NULL ) return NULL;
	memset(ctx,0,sizeof(jit_ctx));
	hl_alloc_init(&ctx->falloc);
	hl_alloc_init(&ctx->galloc);
	for(i=0;i<RCPU_COUNT;i++) {
		preg *r = REG_AT(i);
		r->id = i;
		r->kind = RCPU;
	}
	for(i=0;i<RFPU_COUNT;i++) {
		preg *r = REG_AT(i + RCPU_COUNT);
		r->id = i;
		r->kind = RFPU;
	}
	return ctx;
}

void hl_jit_free( jit_ctx *ctx ) {
	free(ctx->vregs);
	free(ctx->opsPos);
	free(ctx->startBuf);
	hl_free(&ctx->falloc);
	hl_free(&ctx->galloc);
	free(ctx);
}

void hl_jit_init( jit_ctx *ctx, hl_module *m ) {
	int i;
	ctx->m = m;
	for(i=0;i<m->code->nfloats;i++) {
		jit_buf(ctx);
		*ctx->buf.d++ = m->code->floats[i];
	}
	while( BUF_POS() & 15 )
		op32(ctx, NOP, UNUSED, UNUSED);
}

int hl_jit_init_callback( jit_ctx *ctx ) {
	/*
		create the function that will be called by hl_callback.
		it will make sure to prepare the stack according to HL calling convention (cdecl)
	*/
#	ifndef HL_64
	CpuReg R8 = Eax;
#	endif
	int pos = BUF_POS();
	int jstart, jcall, jloop;
	preg p;

	jit_buf(ctx);
	op64(ctx,PUSH,PEBP,UNUSED);
	op64(ctx,MOV,PEBP,PESP);

	// make sure the stack is aligned on 16 bytes
	// the amount of push we will do afterwards is guaranteed to be a multiple of 16bytes by hl_callback
	// in 64 bits, we already have EIP+EBP so it's aligned
#	ifndef HL_64
#		ifdef HL_VCC
			// VCC does not guarantee us an aligned stack...
			op64(ctx,MOV,PEAX,PESP);
			op64(ctx,AND,PEAX,pconst(&p,15));
			op64(ctx,SUB,PESP,PEAX);
#		else
			op64(ctx,SUB,PESP,pconst(&p,8));
#		endif
#	endif

	if( !IS_64 ) {
		// mov stack to regs (as x86_64)
		op64(ctx,MOV,REG_AT(Ecx),pmem(&p,Ebp,HL_WSIZE*2));
		op64(ctx,MOV,REG_AT(Edx),pmem(&p,Ebp,HL_WSIZE*3));
		op64(ctx,MOV,REG_AT(R8),pmem(&p,Ebp,HL_WSIZE*4));
	}


	XJump(JAlways,jstart);
	jloop = BUF_POS();
	op64(ctx,PUSH,pmem(&p,Edx,0),UNUSED);
	op64(ctx,ADD,REG_AT(Edx),pconst(&p,HL_WSIZE));
	op64(ctx,SUB,REG_AT(R8),pconst(&p,1));
	
	patch_jump(ctx, jstart);
	op64(ctx,CMP,REG_AT(R8),pconst(&p,0));
	XJump(JNeq,jcall);
	patch_jump_to(ctx, jcall, jloop);

	op64(ctx,CALL,REG_AT(Ecx),UNUSED);

	// cleanup and ret
	op64(ctx,MOV,PESP,PEBP);
	op64(ctx,POP,PEBP, UNUSED);
	op64(ctx,RET,UNUSED,UNUSED);

	jit_buf(ctx);
	while( BUF_POS() & 15 )
		op32(ctx, NOP, UNUSED, UNUSED);
	return pos;
}

int hl_jit_function( jit_ctx *ctx, hl_module *m, hl_function *f ) {
	int i, size = 0, opCount;
	int codePos = BUF_POS();
	int nargs = f->type->fun->nargs;
	preg p;
	ctx->f = f;
	ctx->allocOffset = 0;
	if( f->nregs > ctx->maxRegs ) {
		free(ctx->vregs);
		ctx->vregs = (vreg*)malloc(sizeof(vreg) * f->nregs);
		if( ctx->vregs == NULL ) {
			ctx->maxRegs = 0;
			return -1;
		}
		ctx->maxRegs = f->nregs;
	}
	if( f->nops > ctx->maxOps ) {
		free(ctx->opsPos);
		ctx->opsPos = (int*)malloc(sizeof(int) * (f->nops + 1));
		if( ctx->opsPos == NULL ) {
			ctx->maxOps = 0;
			return -1;
		}
		ctx->maxOps = f->nops;
	}
	memset(ctx->opsPos,0,(f->nops+1)*sizeof(int));
	for(i=0;i<f->nregs;i++) {
		vreg *r = R(i);
		r->t = f->regs[i];
		r->size = hl_type_size(r->t);
		r->current = NULL;
		r->stack.holds = NULL;
		r->stack.id = i;
		r->stack.kind = RSTACK;
	}
	size = 0;
	for(i=0;i<nargs;i++) {
		vreg *r = R(i);
		size += hl_pad_size(size,r->t);
		r->stackPos = size + HL_WSIZE * 2;
		size += r->size;
	}
	size = 0;
	for(i=nargs;i<f->nregs;i++) {
		vreg *r = R(i);
		size += r->size;
		size += hl_pad_size(size,r->t);
		r->stackPos = -size;
	}
	ctx->totalRegsSize = size;
	jit_buf(ctx);
	ctx->functionPos = BUF_POS();
	op_enter(ctx);
	ctx->opsPos[0] = 0;
	for(opCount=0;opCount<f->nops;opCount++) {
		int jump;
		hl_opcode *o = f->ops + opCount;
		vreg *dst = R(o->p1);
		vreg *ra = R(o->p2);
		vreg *rb = R(o->p3);
		ctx->currentPos = opCount + 1;
		jit_buf(ctx);
#		ifdef JIT_DEBUG
		{
			int uid = opCount + (f->findex<<16);
			op32(ctx, PUSH, pconst(&p,uid), UNUSED);
			op64(ctx, ADD, PESP, pconst(&p,HL_WSIZE));
		}
#		endif
		switch( o->op ) {
		case OMov:
		case OUnsafeCast:
			op_mov(ctx, dst, ra);
			break;
		case OInt:
			store_const(ctx, dst, m->code->ints[o->p2]);
			break;
		case OBool:
			store_const(ctx, dst, o->p2);
			break;
		case OGetGlobal:
			{
				void *addr = m->globals_data + m->globals_indexes[o->p2];
				copy_to(ctx, dst, paddr(&p,addr));
			}
			break;
		case OSetGlobal:
			{
				void *addr = m->globals_data + m->globals_indexes[o->p1];
				copy_from(ctx, paddr(&p,addr), ra);
			}
			break;
		case OCall3:
			{
				int args[3] = { o->p3, o->extra[0], o->extra[1] };
				op_call_fun(ctx, dst, o->p2, 3, args);
			}
			break;
		case OCall4:
			{
				int args[4] = { o->p3, o->extra[0], o->extra[1], o->extra[2] };
				op_call_fun(ctx, dst, o->p2, 4, args);
			}
			break;
		case OCallN:
			op_call_fun(ctx, dst, o->p2, o->p3, o->extra);
			break;
		case OCall0:
			op_call_fun(ctx, dst, o->p2, 0, NULL);
			break;
		case OCall1:
			op_call_fun(ctx, dst, o->p2, 1, &o->p3);
			break;
		case OCall2:
			{
				int args[2] = { o->p3, (int)(int_val)o->extra };
				op_call_fun(ctx, dst, o->p2, 2, args);
			}
			break;
		case OSub:
		case OAdd:
		case OMul:
		case OSDiv:
		case OUDiv:
		case OShl:
		case OSShr:
		case OUShr:
		case OAnd:
		case OOr:
		case OXor:
			op_binop(ctx, dst, ra, rb, o);
			break;
		case ONeg:
			{
				if( IS_FLOAT(ra) ) {
					preg *pa = alloc_reg(ctx,RFPU);
					preg *pb = alloc_fpu(ctx,ra,true);
					op64(ctx,XORPD,pa,pa);
					op64(ctx,SUBSD,pa,pb);
					store(ctx,dst,pa,true);
				} else {
					preg *pa = alloc_reg(ctx,RCPU);
					preg *pb = alloc_cpu(ctx,ra,true);
					op32(ctx,XOR,pa,pa);
					op32(ctx,SUB,pa,pb);
					store(ctx,dst,pa,true);
				}
			}
			break;
		case ONot:
			{
				preg *v = alloc_cpu(ctx,ra,true);
				op32(ctx,XOR,v,pconst(&p,1));
				store(ctx,dst,v,true);
			}
			break;
		case OEq:
		case ONotEq:
		case OSGte:
		case OSLt:
		case OUGte:
		case OULt:
			op_cmp(ctx, o);
			break;
		case OJFalse:
		case OJTrue:
		case OJNotNull:
		case OJNull:
			{
				preg *r = alloc_cpu(ctx, dst, true);
				op32(ctx, TEST, r, r);
				XJump( o->op == OJFalse || o->op == OJNull ? JZero : JNotZero,jump);
				register_jump(ctx,jump,(opCount + 1) + o->p2);
			}
			break;
		case OJEq:
		case OJNeq:
		case OJSLt:
		case OJSGte:
		case OJULt:
		case OJUGte:
			op_binop(ctx, NULL, dst, ra, o);
			jump = do_jump(ctx,o->op, IS_FLOAT(dst));
			register_jump(ctx,jump,(opCount + 1) + o->p3);
			break;
		case OJAlways:
			jump = do_jump(ctx,o->op,false);
			register_jump(ctx,jump,(opCount + 1) + o->p1);
			break;
		case OToDyn:
			{
				int_val rt = (int_val)ra->t;
				call_native_consts(ctx, hl_alloc_dynamic, &rt, 1);
				// copy value to dynamic
				if( IS_FLOAT(ra) && !IS_64 ) {
					preg *tmp = REG_AT(RCPU_SCRATCH_REGS[1]);
					op64(ctx,MOV,tmp,&ra->stack);
					op64(ctx,MOV,pmem(&p,Eax,8),tmp);
					ra->stackPos += 4;
					op64(ctx,MOV,tmp,&ra->stack);
					op64(ctx,MOV,pmem(&p,Eax,12),tmp);
					ra->stackPos -= 4;
				} else {
					preg *tmp = REG_AT(RCPU_SCRATCH_REGS[1]);
					op64(ctx,MOV,tmp,&ra->stack);
					op64(ctx,MOV,pmem(&p,Eax,8),tmp);
				}
				store(ctx, dst, PEAX, true);
			}
			break;
		case OToFloat:
			{
				preg *r = alloc_cpu(ctx,ra,true);
				preg *w = alloc_fpu(ctx,dst,false);
				op32(ctx,CVTSI2SD,w,r);
				store(ctx, dst, w, true);
			}
			break;
		case OToInt:
			{
				preg *r = alloc_fpu(ctx,ra,true);
				preg *w = alloc_cpu(ctx,dst,false);
				op32(ctx,CVTSD2SI,w,r);
				store(ctx, dst, w, true);
			}
			break;
		case ORet:
			op_ret(ctx, dst);
			break;
		case OIncr:
			{
				preg *v = fetch(dst);
				if( IS_FLOAT(dst) ) {
					ASSERT(0);
				} else {
					op32(ctx,INC,v,UNUSED);
					if( v->kind != RSTACK ) store(ctx, dst, v, false);
				}
			}
			break;
		case ODecr:
			{
				preg *v = fetch(dst);
				if( IS_FLOAT(dst) ) {
					ASSERT(0);
				} else {
					op32(ctx,DEC,v,UNUSED);
					if( v->kind != RSTACK ) store(ctx, dst, v, false);
				}
			}
			break;
		case OFloat:
			{
				if( dst->size != 8 ) ASSERT(dst->size);
				if( m->code->floats[o->p2] == 0 ) {
					preg *f = alloc_fpu(ctx,dst,false);
					op64(ctx,XORPD,f,f);
				} else {
#					ifdef HL_64
					op64(ctx,MOVSD,alloc_fpu(ctx,dst,false),pcodeaddr(&p,o->p2 * 8));
#					else
					op64(ctx,MOVSD,alloc_fpu(ctx,dst,false),paddr(&p,m->code->floats + o->p2));
#					endif
				}
				store(ctx,dst,dst->current,false); 
			}
			break;
		case OString:
			{
				op64(ctx,MOV,alloc_cpu(ctx, dst, false),pconst64(&p,(int_val)m->code->strings[o->p2]));
				store(ctx,dst,dst->current,false);
			}
			break;
		case ONull:
			{
				op64(ctx,XOR,alloc_cpu(ctx, dst, false),alloc_cpu(ctx, dst, false));
				store(ctx,dst,dst->current,false);
			}
			break;
		case ONew:
			switch( dst->t->kind ) {
			case HOBJ:
				{
					int_val args[2] = { (int_val)m, (int_val)dst->t };
					call_native_consts(ctx, hl_alloc_obj, args, 2);
					store(ctx, dst, PEAX, true);
					break;
				}
			case HDYNOBJ:
				{
					int_val args[1] = { (int_val)dst->t };
					call_native_consts(ctx, hl_alloc_dynobj, args, 1);
					store(ctx, dst, PEAX, true);
					break;
				}
			default:
				ASSERT(dst->t->kind);
			}
			break;
		case OGetFunction:
			{
				int_val args[2] = { (int_val)m, (int_val)o->p2 };
				call_native_consts(ctx, hl_alloc_closure_void, args, 2);
				store(ctx, dst, PEAX, true);
			}
			break;
		case OClosure:
			{
				vreg *arg = rb;
#				ifdef HL_64
				if( arg->size == 4 ) {
					TODO();
				} else {
					int size = pad_stack(ctx, 0);
					if( arg->current && arg->current->kind == RFPU ) scratch(arg->current);
					op64(ctx,MOV,REG_AT(CALL_REGS[2]),fetch(arg));
					op64(ctx,MOV,REG_AT(CALL_REGS[0]),pconst64(&p,(int_val)m));
					op64(ctx,MOV,REG_AT(CALL_REGS[1]),pconst64(&p,(int_val)o->p2));
					call_native(ctx,hl_alloc_closure_i64,size);
				}
#				else
				if( arg->size == 8 ) {
					TODO();
				} else {
					int size = pad_stack(ctx, HL_WSIZE*2 + 4);
					op64(ctx,PUSH,fetch(arg),UNUSED);
					op64(ctx,PUSH,pconst(&p,o->p2),UNUSED);
					op64(ctx,PUSH,pconst(&p,(int)m),UNUSED);
					call_native(ctx,hl_alloc_closure_i32,size);
				}
#				endif
				discard_regs(ctx,true);
				store(ctx, dst, PEAX, true);
			}
			break;
		case OCallClosure:
			op_call_closure(ctx,dst,ra,o->p3,o->extra);
			break;
		case OField:
			{
				switch( ra->t->kind ) {
				case HOBJ:
					{
						hl_runtime_obj *rt = hl_get_obj_rt(m, ra->t);
						preg *rr = alloc_cpu(ctx,ra, true);
						copy_to(ctx,dst,pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p3]));
					}
					break;
				case HVIRTUAL:
					{
						preg *rr = alloc_cpu(ctx,ra,true);
						preg *ridx = alloc_reg(ctx, RCPU);
						preg *ridx2 = IS_64 ? alloc_reg(ctx,RCPU) : ridx;
						preg *rtmp = alloc_reg(ctx, RCPU);
						// fetch index table
						op64(ctx, MOV, ridx, pmem(&p, rr->id, 0));
						// fetch index itself
#						ifdef HL_64
						op64(ctx, XOR, ridx2, ridx2);
#						endif
						op32(ctx, MOV, ridx2, pmem(&p, ridx->id, o->p3 * sizeof(int) + HL_WSIZE));
						// fetch fields table
						op64(ctx, MOV, rtmp, pmem(&p, rr->id, HL_WSIZE*2));
						// add index
						op64(ctx, ADD, rtmp, ridx2);
						RUNLOCK(ridx);
						// fetch field data
						copy_to(ctx,dst, pmem(&p, rtmp->id, 0));
					}
					break;
				default:
					ASSERT(ra->t->kind);
					break;
				}
			}
			break;
		case OSetField:
			{
				switch( dst->t->kind ) {
				case HOBJ:
					{
						hl_runtime_obj *rt = hl_get_obj_rt(m, dst->t);
						preg *rr = alloc_cpu(ctx, dst, true);
						copy_from(ctx, pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p2]), rb);
					}
					break;
				case HVIRTUAL:
					{
						preg *rr = alloc_cpu(ctx,dst,true);
						preg *ridx = alloc_reg(ctx, RCPU);
						preg *ridx2 = IS_64 ? alloc_reg(ctx,RCPU) : ridx;
						preg *rtmp = alloc_reg(ctx, RCPU);
						// fetch index table
						op64(ctx, MOV, ridx, pmem(&p, rr->id, 0));
						// fetch index itself
#						ifdef HL_64
						op64(ctx, XOR, ridx2, ridx2);
#						endif
						op32(ctx, MOV, ridx2, pmem(&p, ridx->id, o->p2 * sizeof(int) + HL_WSIZE));
						// fetch fields table
						op64(ctx, MOV, rtmp, pmem(&p, rr->id, HL_WSIZE*2));
						// add index
						op64(ctx, ADD, rtmp, ridx2);
						RUNLOCK(ridx);
						// fetch field data
						copy_from(ctx,pmem(&p, rtmp->id, 0), rb);
					}
					break;
				default:
					ASSERT(dst->t->kind);
					break;
				}
			}
			break;
		case OGetThis:
			{
				vreg *r = R(0);
				hl_runtime_obj *rt = hl_get_obj_rt(m, r->t);
				preg *rr = alloc_cpu(ctx,r, true);
				copy_to(ctx,dst,pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p2]));
			}
			break;
		case OSetThis:
			{
				vreg *r = R(0);
				hl_runtime_obj *rt = hl_get_obj_rt(m, r->t);
				preg *rr = alloc_cpu(ctx, r, true);
				copy_from(ctx, pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p1]), ra);
			}
			break;
		case OCallThis:
			{
				int nargs = o->p3 + 1;
				int *args = (int*)hl_malloc(&ctx->falloc,sizeof(int) * nargs);
				int size;
				preg *r = alloc_cpu(ctx, R(0), true);
				preg *tmp;
				tmp = alloc_reg(ctx, RCPU);
				op64(ctx,MOV,tmp,pmem(&p,r->id,0)); // read proto
				args[0] = 0;
				for(i=1;i<nargs;i++)
					args[i] = o->extra[i-1];
				size = prepare_call_args(ctx,nargs,args,ctx->vregs,false);
				op64(ctx,CALL,pmem(&p,tmp->id,(o->p2 + 1)*HL_WSIZE),UNUSED);
				discard_regs(ctx, false);
				op64(ctx,ADD,PESP,pconst(&p,size));
				store(ctx, dst, IS_FLOAT(dst) ? PXMM(0) : PEAX, true);
			}
			break;
		case OCallMethod:
			{
				int size;
				preg *r = alloc_cpu(ctx, R(o->extra[0]), true);
				preg *tmp;
				tmp = alloc_reg(ctx, RCPU);
				op64(ctx,MOV,tmp,pmem(&p,r->id,0)); // read proto
				size = prepare_call_args(ctx,o->p3,o->extra,ctx->vregs,false);
				op64(ctx,CALL,pmem(&p,tmp->id,(o->p2 + 1)*HL_WSIZE),UNUSED);
				discard_regs(ctx, false);
				op64(ctx,ADD,PESP,pconst(&p,size));
				store(ctx, dst, IS_FLOAT(dst) ? PXMM(0) : PEAX, true);
			}
			break;
		case OMethod:
			switch( ra->t->kind ) {
			case HVIRTUAL:
				{
#					ifdef HL_64
					int size = pad_stack(ctx, 0);
					op64(ctx,MOV,REG_AT(CALL_REGS[0]),fetch(ra));
					op32(ctx,MOV,REG_AT(CALL_REGS[1]),pconst(&p,o->p3));
#					else
					int size = pad_stack(ctx, HL_WSIZE + 4);
					op32(ctx,PUSH,pconst(&p,o->p3),UNUSED);
					op32(ctx,PUSH,fetch(ra),UNUSED);
#					endif
					call_native(ctx,hl_fetch_virtual_method,size);
					store(ctx,dst,PEAX,true);
				}
				break;
			default:
				ASSERT(ra->t->kind);
			}
			break;
		case OThrow:
			{
				int size = prepare_call_args(ctx,1,&o->p1,ctx->vregs,true);
				call_native(ctx,hl_throw,size);
			}
			break;
		case OError:
			{
#				ifdef HL_64
				int size = pad_stack(ctx, 0);
				op64(ctx,MOV,REG_AT(CALL_REGS[0]),pconst64(&p,(int_val)m->code->strings[o->p1]));
#				else
				int size = pad_stack(ctx, HL_WSIZE);
				op32(ctx,PUSH,pconst(&p,(int)(int_val)m->code->strings[o->p1]), UNUSED);
#				endif
				call_native(ctx,hl_error_msg,size);
			}
			break;
		case OLabel:
			// NOP for now
			discard_regs(ctx,false);
			break;
		case OGetI32:
			{
				preg *base = alloc_cpu(ctx, ra, true);
				preg *offset = alloc_cpu(ctx, rb, true);
				store(ctx, dst, pmem2(&p,base->id,offset->id,1,0), false);
			}
			break;
		case OSetI8:
			{
				preg *base = alloc_cpu(ctx, dst, true);
				preg *offset = alloc_cpu(ctx, ra, true);
				preg *value = alloc_cpu(ctx, rb, true);
				op32(ctx,MOV8,pmem2(&p,base->id,offset->id,1,0),value);
			}
			break;
		case OSetI32:
			{
				preg *base = alloc_cpu(ctx, dst, true);
				preg *offset = alloc_cpu(ctx, ra, true);
				preg *value = alloc_cpu(ctx, rb, true);
				op32(ctx,MOV,pmem2(&p,base->id,offset->id,1,0),value);
			}
			break;
		case OType:
			{
				op64(ctx,MOV,alloc_cpu(ctx, dst, false),pconst64(&p,(int_val)(m->code->types + o->p2)));
				store(ctx,dst,dst->current,false);
			}
			break;
		case OGetArray:
			{
				op64(ctx,MOV,alloc_cpu(ctx,dst,false),pmem2(&p,alloc_cpu(ctx,ra,true)->id,alloc_cpu(ctx,rb,true)->id,HL_WSIZE,sizeof(varray)));
				store(ctx,dst,dst->current,false);
			}
			break;
		case OSetArray:
			{
				op64(ctx,MOV,pmem2(&p,alloc_cpu(ctx,dst,true)->id,alloc_cpu(ctx,ra,true)->id,HL_WSIZE,sizeof(varray)),alloc_cpu(ctx,rb,true));
			}
			break;
		case OArraySize:
			{
				op32(ctx,MOV,alloc_cpu(ctx,dst,false),pmem(&p,alloc_cpu(ctx,ra,true)->id,HL_WSIZE));
				store(ctx,dst,dst->current,false);
			}
			break;
		case ORef:
			{
				scratch(ra->current);
				op64(ctx,MOV,alloc_cpu(ctx,dst,false),REG_AT(Ebp));
				if( ra->stackPos < 0 )
					op64(ctx,SUB,dst->current,pconst(&p,-ra->stackPos));
				else
					op64(ctx,ADD,dst->current,pconst(&p,ra->stackPos));
				store(ctx,dst,dst->current,false);
			}
			break;
		case OToVirtual:
			{
#				ifdef HL_64
				int size = pad_stack(ctx, 0);
				op64(ctx,MOV,REG_AT(CALL_REGS[1]),fetch(ra));
				op64(ctx,MOV,REG_AT(CALL_REGS[0]),pconst64(&p,(int_val)dst->t));
#				else
				int size = pad_stack(ctx, HL_WSIZE*2);
				op32(ctx,PUSH,fetch(ra),UNUSED);
				op32(ctx,PUSH,pconst(&p,(int)(int_val)dst->t),UNUSED);
#				endif
				if( ra->t->kind == HOBJ ) hl_get_obj_rt(ctx->m, ra->t); // ensure it's initialized
				call_native(ctx,hl_to_virtual,size);
				store(ctx,dst,PEAX,true);
			}
			break;
		case OUnVirtual:
			{
				preg *v = alloc_cpu(ctx,ra,true);
				int jnz, jend;
				op64(ctx,TEST,v,v);
				XJump_small(JNotZero,jnz);
				op64(ctx,XOR,alloc_cpu(ctx, dst, false),alloc_cpu(ctx, dst, false));
				XJump_small(JAlways,jend);
				patch_jump(ctx,jnz);
				op64(ctx,MOV,alloc_cpu(ctx, dst, false),pmem(&p,v->id,HL_WSIZE));
				patch_jump(ctx,jend);
				store(ctx,dst,dst->current,false);
			}
			break;
		case ODynGet:
			{
				int hfield = hl_hash(m->code->strings[o->p3],false);
#				ifdef HL_64
				int size = pad_stack(ctx, 0);
				op64(ctx,MOV,REG_AT(CALL_REGS[0]),fetch(ra));
				op64(ctx,MOV,REG_AT(CALL_REGS[1]),pconst(&p,hfield));
				op64(ctx,MOV,REG_AT(CALL_REGS[2]),pconst64(&p,(int_val)dst->t));
#				else
				int size = pad_stack(ctx, HL_WSIZE*3);
				op32(ctx,PUSH,pconst(&p,(int)dst->t),UNUSED);
				op32(ctx,PUSH,pconst(&p,hfield),UNUSED);
				op32(ctx,PUSH,fetch(ra),UNUSED);
#				endif
				if( dst->size == 8 ) {
					call_native(ctx,hl_dyn_get64,size);
#					ifdef HL_64
					store(ctx,dst,PEAX,true);
#					else
					scratch(dst->current);
					// mov Eax:Edx into dst
					op32(ctx,MOV,&dst->stack,PEAX);
					dst->stackPos += 4;
					op32(ctx,MOV,&dst->stack,REG_AT(Edx));
					dst->stackPos -= 4;
#					endif
				} else {
					call_native(ctx,hl_dyn_get32,size);
					store(ctx,dst,PEAX,true);
				}
			}
			break;
		case ODynSet:
			{
				int hfield = hl_hash(m->code->strings[o->p2],true);
#				ifdef HL_64
				int size = pad_stack(ctx, 0);
				op64(ctx,MOV,REG_AT(CALL_REGS[0]),fetch(dst));
				scratch(REG_AT(CALL_REGS[0]));
				op64(ctx,MOV,REG_AT(CALL_REGS[3]),fetch(rb));
				op64(ctx,MOV,REG_AT(CALL_REGS[1]),pconst(&p,hfield));
				op64(ctx,MOV,REG_AT(CALL_REGS[2]),pconst64(&p,(int_val)rb->t));
#				else
				int size = pad_stack(ctx, HL_WSIZE*3 + rb->size);
				if( rb->size == 8 ) {
					BREAK();
					//op32(ctx,PUSH,fetch(rb),UNUSED);
				} else {
					op32(ctx,PUSH,fetch(rb),UNUSED);
				}
				op32(ctx,PUSH,pconst(&p,(int)rb->t), UNUSED);
				op32(ctx,PUSH,pconst(&p,hfield),UNUSED);
				op32(ctx,PUSH,fetch(dst),UNUSED);
#				endif
				if( rb->size == 8 )
					call_native(ctx,hl_dyn_set64,size);
				else
					call_native(ctx,hl_dyn_set32,size);
			}
			break;
		default:
			printf("Don't know how to jit %s\n",hl_op_name(o->op));
			break;
		}
		// we are landing at this position, assume we have lost our registers
		if( ctx->opsPos[opCount+1] == -1 )
			discard_regs(ctx,true);
		ctx->opsPos[opCount+1] = BUF_POS();
	}
	// patch jumps
	{
		jlist *j = ctx->jumps;
		while( j ) {
			*(int*)(ctx->startBuf + j->pos) = ctx->opsPos[j->target] - (j->pos + 4);
			j = j->next;
		}
		ctx->jumps = NULL;
	}
	// add nops padding
	while( BUF_POS() & 15 )
		op32(ctx, NOP, UNUSED, UNUSED);
	// clear regs
	for(i=0;i<REG_COUNT;i++) {
		preg *r = REG_AT(i);
		r->holds = NULL;
		r->lock = 0;
	}
	// reset tmp allocator
	hl_free(&ctx->falloc);
	return codePos;
}

void *hl_jit_code( jit_ctx *ctx, hl_module *m, int *codesize ) {
	jlist *c;
	int size = BUF_POS();
	unsigned char *code;
	if( size & 4095 ) size += 4096 - (size&4095);
	code = (unsigned char*)hl_alloc_executable_memory(size);
	if( code == NULL ) return NULL;
	memcpy(code,ctx->startBuf,BUF_POS());
	*codesize = size;
	// patch calls
	c = ctx->calls;
	while( c ) {
		int fpos = (int)(int_val)m->functions_ptrs[c->target];
		*(int*)(code + c->pos + 1) = fpos - (c->pos + 5);
		c = c->next;
	}
	return code;
}

