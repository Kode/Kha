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
#ifdef _MSC_VER
#pragma warning(disable:4820)
#endif
#include <math.h>
#include <hlmodule.h>

#ifdef __arm__
#	error "JIT does not support ARM processors, only x86 and x86-64 are supported, please use HashLink/C native compilation instead"
#endif

#ifdef HL_DEBUG
#	define JIT_DEBUG
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
	LEA,
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
	JMP,
	// FPU
	FSTP,
	FSTP32,
	FLD,
	FLD32,
	FLDCW,
	// SSE
	MOVSD,
	MOVSS,
	COMISD,
	COMISS,
	ADDSD,
	SUBSD,
	MULSD,
	DIVSD,
	ADDSS,
	SUBSS,
	MULSS,
	DIVSS,
	XORPD,
	CVTSI2SD,
	CVTSI2SS,
	CVTSD2SI,
	CVTSD2SS,
	CVTSS2SD,
	CVTSS2SI,
	STMXCSR,
	LDMXCSR,
	// 8-16 bits
	MOV8,
	CMP8,
	TEST8,
	MOV16,
	CMP16,
	TEST16,
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
#define JParity		0x8A
#define JNParity	0x8B
#define JSLt		0x8C
#define JSGte		0x8D
#define JSLte		0x8E
#define JSGt		0x8F

#define JCarry		JLt
#define JZero		JEq
#define JNotZero	JNeq

#define B(bv)	*ctx->buf.b++ = (unsigned char)(bv)
#define W(wv)	*ctx->buf.w++ = wv

#ifdef HL_64
#	define W64(wv)	*ctx->buf.w64++ = wv
#else
#	define W64(wv)	W(wv)
#endif

static const int SIB_MULT[] = {-1, 0, 1, -1, 2, -1, -1, -1, 3};

#define MOD_RM(mod,reg,rm)		B(((mod) << 6) | (((reg)&7) << 3) | ((rm)&7))
#define SIB(mult,rmult,rbase)	B((SIB_MULT[mult]<<6) | (((rmult)&7)<<3) | ((rbase)&7))
#define IS_SBYTE(c)				( (c) >= -128 && (c) < 128 )

#define AddJump(how,local)		{ if( (how) == JAlways ) { B(0xE9); } else { B(0x0F); B(how); }; local = BUF_POS(); W(0); }
#define AddJump_small(how,local) { if( (how) == JAlways ) { B(0xEB); } else B(how - 0x10); local = BUF_POS() | 0x40000000; B(0); }
#define XJump(how,local)		AddJump(how,local)
#define XJump_small(how,local)		AddJump_small(how,local)

#define MAX_OP_SIZE				256

#define BUF_POS()				((int)(ctx->buf.b - ctx->startBuf))
#define RTYPE(r)				r->t->kind

#ifdef HL_64
#	define RESERVE_ADDRESS	0x8000000000000000
#else
#	define RESERVE_ADDRESS	0x80000000
#endif

#if defined(HL_WIN_CALL) && defined(HL_64)
#	define IS_WINCALL64 1
#else
#	define IS_WINCALL64 0
#endif

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
	RUNUSED = 6,
	RCPU_CALL = 1 | 8,
	RCPU_8BITS = 1 | 16
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
#	define RCPU_COUNT	16
#	define RFPU_COUNT	16
#	ifdef HL_WIN_CALL
#		define CALL_NREGS			4
#		define RCPU_SCRATCH_COUNT	7
#		define RFPU_SCRATCH_COUNT	6
static const int RCPU_SCRATCH_REGS[] = { Eax, Ecx, Edx, R8, R9, R10, R11 };
static const CpuReg CALL_REGS[] = { Ecx, Edx, R8, R9 };
#	else
#		define CALL_NREGS			6 // TODO : XMM6+XMM7 are FPU reg parameters
#		define RCPU_SCRATCH_COUNT	9
#		define RFPU_SCRATCH_COUNT	16
static const int RCPU_SCRATCH_REGS[] = { Eax, Ecx, Edx, Esi, Edi, R8, R9, R10, R11 };
static const CpuReg CALL_REGS[] = { Edi, Esi, Edx, Ecx, R8, R9 };
#	endif
#else
#	define CALL_NREGS	0
#	define RCPU_COUNT	8
#	define RFPU_COUNT	8
#	define RCPU_SCRATCH_COUNT	3
#	define RFPU_SCRATCH_COUNT	8
static const int RCPU_SCRATCH_REGS[] = { Eax, Ecx, Edx };
#endif

#define XMM(i)			((i) + RCPU_COUNT)
#define PXMM(i)			REG_AT(XMM(i))
#define REG_IS_FPU(i)	((i) >= RCPU_COUNT)

#define PEAX			REG_AT(Eax)
#define PESP			REG_AT(Esp)
#define PEBP			REG_AT(Ebp)

#define REG_COUNT	(RCPU_COUNT + RFPU_COUNT)

#define ID2(a,b)	((a) | ((b)<<8))
#define R(id)		(ctx->vregs + (id))
#define ASSERT(i)	{ printf("JIT ERROR %d (jit.c line %d)\n",i,(int)__LINE__); jit_exit(); }
#define IS_FLOAT(r)	((r)->t->kind == HF64 || (r)->t->kind == HF32)
#define RLOCK(r)		if( (r)->lock < ctx->currentPos ) (r)->lock = ctx->currentPos
#define RUNLOCK(r)		if( (r)->lock == ctx->currentPos ) (r)->lock = 0

#define BREAK()		B(0xCC)

#if defined(HL_64) && defined(HL_VCC)
#	define JIT_CUSTOM_LONGJUMP
#endif

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
	vreg *savedRegs[REG_COUNT];
	int savedLocks[REG_COUNT];
	int *opsPos;
	int maxRegs;
	int maxOps;
	int bufSize;
	int totalRegsSize;
	int functionPos;
	int allocOffset;
	int currentPos;
	int nativeArgsCount;
	unsigned char *startBuf;
	hl_module *m;
	hl_function *f;
	jlist *jumps;
	jlist *calls;
	jlist *switchs;
	hl_alloc falloc; // cleared per-function
	hl_alloc galloc;
	vclosure *closure_list;
	hl_debug_infos *debug;
	int c2hl;
	int hl2c;
	int longjump;
	void *static_functions[8];
};

#define jit_exit() { hl_debug_break(); exit(-1); }
#define jit_error(msg)	_jit_error(ctx,msg,__LINE__)
static void _jit_error( jit_ctx *ctx, const char *msg, int line );
static void on_jit_error( const char *msg, int_val line );

static preg *pmem( preg *r, CpuReg reg, int offset ) {
	r->kind = RMEM;
	r->id = 0 | (reg << 4) | (offset << 8);
	return r;
}

static preg *pmem2( preg *r, CpuReg reg, CpuReg reg2, int mult, int offset ) {
	r->kind = RMEM;
	r->id = mult | (reg << 4) | (reg2 << 8);
	r->holds = (void*)(int_val)offset;
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
#ifdef HL_64
	if( (c&0xFFFFFFFF) == c )
		return pconst(r,(int)c);
	r->kind = RCONST;
	r->id = 0xC064C064;
	r->holds = (vreg*)c;
	return r;
#else
	return pconst(r,(int)c);
#endif
}

#ifndef HL_64
// it is not possible to access direct 64 bit address in x86-64
static preg *paddr( preg *r, void *p ) {
	r->kind = RADDR;
	r->holds = (vreg*)p;
	return r;
}
#endif

static void save_regs( jit_ctx *ctx ) {
	int i;
	for(i=0;i<REG_COUNT;i++) {
		ctx->savedRegs[i] = ctx->pregs[i].holds;
		ctx->savedLocks[i] = ctx->pregs[i].lock;
	}
}

static void restore_regs( jit_ctx *ctx ) {
	int i;
	for(i=0;i<ctx->maxRegs;i++)
		ctx->vregs[i].current = NULL;
	for(i=0;i<REG_COUNT;i++) {
		vreg *r = ctx->savedRegs[i];
		preg *p = ctx->pregs + i;
		p->holds = r;
		p->lock = ctx->savedLocks[i];
		if( r ) r->current = p;
	}
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

#define FLAG_LONGOP	0x80000000
#define FLAG_16B	0x40000000

#define RM(op,id) ((op) | (((id)+1)<<8))
#define GET_RM(op)	(((op) >> ((op) < 0 ? 24 : 8)) & 15)
#define SBYTE(op) ((op) << 16)
#define LONG_OP(op)	((op) | FLAG_LONGOP)
#define OP16(op)	LONG_OP((op) | FLAG_16B)
#define LONG_RM(op,id)	LONG_OP(op | (((id) + 1) << 24))

static opform OP_FORMS[_CPU_LAST] = {
	{ "MOV", 0x8B, 0x89, 0xB8, 0, RM(0xC7,0) },
	{ "LEA", 0x8D },
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
	{ "JMP", RM(0xFF,4) },
	// FPU
	{ "FSTP", 0, RM(0xDD,3) },
	{ "FSTP32", 0, RM(0xD9,3) },
	{ "FLD", 0, RM(0xDD,0) },
	{ "FLD32", 0, RM(0xD9,0) },
	{ "FLDCW", 0, RM(0xD9, 5) },
	// SSE
	{ "MOVSD", 0xF20F10, 0xF20F11  },
	{ "MOVSS", 0xF30F10, 0xF30F11  },
	{ "COMISD", 0x660F2F },
	{ "COMISS", LONG_OP(0x0F2F) },
	{ "ADDSD", 0xF20F58 },
	{ "SUBSD", 0xF20F5C },
	{ "MULSD", 0xF20F59 },
	{ "DIVSD", 0xF20F5E },
	{ "ADDSS", 0xF30F58 },
	{ "SUBSS", 0xF30F5C },
	{ "MULSS", 0xF30F59 },
	{ "DIVSS", 0xF30F5E },
	{ "XORPD", 0x660F57 },
	{ "CVTSI2SD", 0xF20F2A },
	{ "CVTSI2SS", 0xF30F2A },
	{ "CVTSD2SI", 0xF20F2D },
	{ "CVTSD2SS", 0xF20F5A },
	{ "CVTSS2SD", 0xF30F5A },
	{ "CVTSS2SI", 0xF30F2D },
	{ "STMXCSR", 0, LONG_RM(0x0FAE,3) },
	{ "LDMXCSR", 0, LONG_RM(0x0FAE,2) },
	// 8 bits,
	{ "MOV8", 0x8A, 0x88, 0, 0xB0, RM(0xC6,0) },
	{ "CMP8", 0x3A, 0x38, 0, RM(0x80,7) },
	{ "TEST8", 0x84, 0x84, RM(0xF6,0) },
	{ "MOV16", OP16(0x8B), OP16(0x89), OP16(0xB8) },
	{ "CMP16", OP16(0x3B), OP16(0x39) },
	{ "TEST16", OP16(0x85) },
};

#ifdef HL_64
#	define REX()	if( r64 ) B(r64 | 0x40)
#else
#	define REX()
#endif

#define	OP(b)	\
	if( (b) & 0xFF0000 ) { \
		B((b)>>16); \
		if( r64 ) B(r64 | 0x40); /* also in 32 bits mode */ \
		B((b)>>8); \
		B(b); \
	} else { \
		if( (b) & FLAG_16B ) { \
			B(0x66); \
			REX(); \
		} else {\
			REX(); \
			if( (b) & FLAG_LONGOP ) B((b)>>8); \
		}\
		B(b); \
	}

static bool is_reg8( preg *a ) {
	return a->kind == RSTACK || a->kind == RMEM || a->kind == RCONST || (a->kind == RCPU && a->id != Esi && a->id != Edi);
}

static void op( jit_ctx *ctx, CpuOp o, preg *a, preg *b, bool mode64 ) {
	opform *f = &OP_FORMS[o];
	int r64 = mode64 && (o != PUSH && o != POP && o != CALL) ? 8 : 0;
	switch( o ) {
	case CMP8:
	case TEST8:
	case MOV8:
		if( !is_reg8(a) || !is_reg8(b) )
			ASSERT(0);
		break;
	default:
		break;
	}
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
				if( mode64 && IS_64 && o == MOV ) W64(cval); else W((int)cval);
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
			W((int)cval);
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
	if( ctx->debug && ctx->f && o == CALL ) {
		preg p;
		op(ctx,MOV,pmem(&p,Esp,-HL_WSIZE),PEBP,true); // erase EIP (clean stack report)
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

static int stack_size( hl_type *t ) {
	switch( t->kind ) {
	case HUI8:
	case HUI16:
	case HBOOL:
#	ifdef HL_64
	case HI32:
	case HF32:
#	endif
		return sizeof(int_val);
	default:
		return hl_type_size(t);
	}
}

static int call_reg_index( int reg ) {
#	ifdef HL_64
	int i;
	for(i=0;i<CALL_NREGS;i++)
		if( CALL_REGS[i] == reg )
			return i;
#	endif
	return -1;
}

static bool is_call_reg( preg *p ) {
#	ifdef HL_64
	int i;
	if( p->kind == RFPU )
		return p->id < CALL_NREGS;
	for(i=0;i<CALL_NREGS;i++)
		if( p->kind == RCPU && p->id == CALL_REGS[i] )
			return true;
	return false;
#	else
	return false;
#	endif
}

static preg *alloc_reg( jit_ctx *ctx, preg_kind k ) {
	int i;
	preg *p;
	switch( k ) {
	case RCPU:
	case RCPU_CALL:
	case RCPU_8BITS:
		{
			int off = ctx->allocOffset++;
			const int count = RCPU_SCRATCH_COUNT;
			for(i=0;i<count;i++) {
				int r = RCPU_SCRATCH_REGS[(i + off)%count];
				p = ctx->pregs + r;
				if( p->lock >= ctx->currentPos ) continue;
				if( k == RCPU_CALL && is_call_reg(p) ) continue;
				if( k == RCPU_8BITS && !is_reg8(p) ) continue;
				if( p->holds == NULL ) {
					RLOCK(p);
					return p;
				}
			}
			for(i=0;i<count;i++) {
				preg *p = ctx->pregs + RCPU_SCRATCH_REGS[(i + off)%count];
				if( p->lock >= ctx->currentPos ) continue;
				if( k == RCPU_CALL && is_call_reg(p) ) continue;
				if( k == RCPU_8BITS && !is_reg8(p) ) continue;
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
		r->lock = 0;
	}
}

static preg *copy( jit_ctx *ctx, preg *to, preg *from, int size );

static void load( jit_ctx *ctx, preg *r, vreg *v ) {
	preg *from = fetch(v);
	if( from == r || v->size == 0 ) return;
	if( r->holds ) r->holds->current = NULL;
	if( v->current ) {
		v->current->holds = NULL;
		from = r;
	}
	r->holds = v;
	v->current = r;
	copy(ctx,r,from,v->size);
}

static preg *alloc_fpu( jit_ctx *ctx, vreg *r, bool andLoad ) {
	preg *p = fetch(r);
	if( p->kind != RFPU ) {
		if( !IS_FLOAT(r) && (IS_64 || r->t->kind != HI64) ) ASSERT(r->t->kind);
		p = alloc_reg(ctx, RFPU);
		if( andLoad )
			load(ctx,p,r);
		else {
			if( r->current )
				r->current->holds = NULL;
			r->current = p;
			p->holds = r;
		}
	} else
		RLOCK(p);
	return p;
}

static void reg_bind( vreg *r, preg *p ) {
	if( r->current )
		r->current->holds = NULL;
	r->current = p;
	p->holds = r;
}

static preg *alloc_cpu( jit_ctx *ctx, vreg *r, bool andLoad ) {
	preg *p = fetch(r);
	if( p->kind != RCPU ) {
#		ifndef HL_64
		if( r->t->kind == HI64 ) return alloc_fpu(ctx,r,andLoad);
		if( r->size > 4 ) ASSERT(r->size);
#		endif
		p = alloc_reg(ctx, RCPU);
		if( andLoad )
			load(ctx,p,r);
		else
			reg_bind(r,p);
	} else
		RLOCK(p);
	return p;
}

// allocate a register that is not a call parameter
static preg *alloc_cpu_call( jit_ctx *ctx, vreg *r ) {
	preg *p = fetch(r);
	if( p->kind != RCPU ) {
#		ifndef HL_64
		if( r->t->kind == HI64 ) return alloc_fpu(ctx,r,true);
		if( r->size > 4 ) ASSERT(r->size);
#		endif
		p = alloc_reg(ctx, RCPU_CALL);
		load(ctx,p,r);
	} else if( is_call_reg(p) ) {
		preg *p2 = alloc_reg(ctx, RCPU_CALL);
		op64(ctx,MOV,p2,p);
		scratch(p);
		reg_bind(r,p2);
		return p2;
	} else
		RLOCK(p);
	return p;
}

static preg *fetch32( jit_ctx *ctx, vreg *r ) {
	if( r->current )
		return r->current;
	// make sure that the register is correctly erased
	if( r->size < 4 ) {
		preg *p = alloc_cpu(ctx, r, true);
		RUNLOCK(p);
		return p;
	}
	return fetch(r);
}

// make sure higher bits are zeroes 
static preg *alloc_cpu64( jit_ctx *ctx, vreg *r, bool andLoad ) {
#	ifndef HL_64
	return alloc_cpu(ctx,r,andLoad);
#	else
	preg *p = fetch(r);
	if( !andLoad ) ASSERT(0);
	if( p->kind != RCPU ) {
		p = alloc_reg(ctx, RCPU);
		op64(ctx,XOR,p,p);
		load(ctx,p,r);
	} else {
		// remove higher bits
		preg tmp;
		op64(ctx,SHL,p,pconst(&tmp,32));
		op64(ctx,SHR,p,pconst(&tmp,32));
		RLOCK(p);
	}
	return p;
#	endif
}

// make sure the register can be used with 8 bits access
static preg *alloc_cpu8( jit_ctx *ctx, vreg *r, bool andLoad ) {
	preg *p = fetch(r);
	if( p->kind != RCPU ) {
		p = alloc_reg(ctx, RCPU_8BITS);
		load(ctx,p,r);
	} else if( !is_reg8(p) ) {
		preg *p2 = alloc_reg(ctx, RCPU_8BITS);
		op64(ctx,MOV,p2,p);
		scratch(p);
		reg_bind(r,p2);
		return p2;
	} else
		RLOCK(p);
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
			if( to->kind == RCPU ) {
				op64(ctx,XOR,to,to);
				if( !is_reg8(to) ) {
					preg p;
					op32(ctx,MOV16,to,from);
					op32(ctx,SHL,to,pconst(&p,24));
					op32(ctx,SHR,to,pconst(&p,24));
					break;
				}
			} else if( !is_reg8(from) ) {
				preg *r = alloc_reg(ctx, RCPU_CALL);				
				op32(ctx, MOV, r, from);
				RUNLOCK(r);
				op32(ctx,MOV8,to,r);
				return from;
			}
			op32(ctx,MOV8,to,from);
			break;
		case 2:
			if( to->kind == RCPU )
				op64(ctx,XOR,to,to);
			op32(ctx,MOV16,to,from);
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
		case 4:
			op32(ctx,MOVSS,to,from);
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
	case ID2(RADDR,RSTACK):
#	endif
		{
			preg *tmp;
			if( size == 8 && (!IS_64 || (to->kind == RSTACK && IS_FLOAT(R(to->id))) || (from->kind == RSTACK && IS_FLOAT(R(from->id)))) ) {
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

static void store_result( jit_ctx *ctx, vreg *r ) {
	switch( r->t->kind ) {
#	ifndef HL_64
	case HF64:
		scratch(r->current);
		op64(ctx,FSTP,&r->stack,UNUSED);
		break;
	case HF32:
		scratch(r->current);
		op64(ctx,FSTP32,&r->stack,UNUSED);
		break;
#	endif
	default:
		store(ctx,r,IS_FLOAT(r) ? REG_AT(XMM(0)) : PEAX,true);
		break;
	}
}

static void op_mov( jit_ctx *ctx, vreg *to, vreg *from ) {
	preg *r = fetch(from);
	if( from->t->kind == HF32 && r->kind != RFPU )
		r = alloc_fpu(ctx,from,true);
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
		preg *r = ctx->pregs + XMM(i);
		if( r->holds ) {
			r->holds->current = NULL;
			r->holds = NULL;
		}
	}
}

static int pad_before_call( jit_ctx *ctx, int size ) {
	int total = size + ctx->totalRegsSize + HL_WSIZE * 2; // EIP+EBP
	if( total & 15 ) {
		int pad = 16 - (total & 15);
		preg p;
		if( pad ) op64(ctx,SUB,PESP,pconst(&p,pad));
		size += pad;
	}
	return size;
}

static void push_reg( jit_ctx *ctx, vreg *r ) {
	preg p;
	switch( stack_size(r->t) ) {
	case 1:
		op64(ctx,SUB,PESP,pconst(&p,1));
		op32(ctx,MOV8,pmem(&p,Esp,0),alloc_cpu8(ctx,r,true));
		break;
	case 2:
		op64(ctx,SUB,PESP,pconst(&p,2));
		op32(ctx,MOV16,pmem(&p,Esp,0),alloc_cpu(ctx,r,true));
		break;
	case 4:
		if( r->size < 4 )
			alloc_cpu(ctx,r,true); // force fetch (higher bits set to 0)
		if( !IS_64 ) {
			if( r->current != NULL && r->current->kind == RFPU ) scratch(r->current);
			op32(ctx,PUSH,fetch(r),UNUSED);
		} else {
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

static int begin_native_call( jit_ctx *ctx, int nargs ) {
	ctx->nativeArgsCount = nargs;
	return pad_before_call(ctx, nargs > CALL_NREGS ? (nargs - CALL_NREGS) * HL_WSIZE : 0);
}

static preg *alloc_native_arg( jit_ctx *ctx ) {
#	ifdef HL_64
	int rid = ctx->nativeArgsCount - 1;
	preg *r = rid < CALL_NREGS ? REG_AT(CALL_REGS[rid]) : alloc_reg(ctx,RCPU_CALL);
	scratch(r);
	return r;
#	else
	return alloc_reg(ctx, RCPU);
#	endif
}

static void set_native_arg( jit_ctx *ctx, preg *r ) {
	if( r->kind == RSTACK ) {
		vreg *v = ctx->vregs + r->id;
		if( v->size < 4 )
			r = fetch32(ctx, v);
	}
#	ifdef HL_64
	if( r->kind == RFPU ) ASSERT(0);
	int rid = --ctx->nativeArgsCount;
	preg *target;
	if( rid >= CALL_NREGS ) {
		op64(ctx,PUSH,r,UNUSED);
		return;
	}
	target = REG_AT(CALL_REGS[rid]);
	if( target != r ) {
		op64(ctx, MOV, target, r);
		scratch(target);
	}
#	else
	op32(ctx,PUSH,r,UNUSED);
#	endif
}

static void set_native_arg_fpu( jit_ctx *ctx, preg *r, bool isf32 ) {
#	ifdef HL_64
	if( r->kind == RCPU ) ASSERT(0);
	// can only be used if last argument !!
	ctx->nativeArgsCount--;
	preg *target = REG_AT(XMM(IS_WINCALL64 ? ctx->nativeArgsCount : 0));
	if( target != r ) {
		op64(ctx, isf32 ? MOVSS : MOVSD, target, r);
		scratch(target);
	}
#	else
	op32(ctx,PUSH,r,UNUSED);
#	endif
}

typedef struct {
	int nextCpu;
	int nextFpu;
	int mapped[REG_COUNT];
} call_regs;

static int select_call_reg( call_regs *regs, hl_type *t, int id ) {
#	ifndef HL_64
	return -1;
#else
	bool isFloat = t->kind == HF32 || t->kind == HF64;
#	ifdef HL_WIN_CALL
	int index = regs->nextCpu++;
#	else
	int index = isFloat ? regs->nextFpu++ : regs->nextCpu++;
#	endif
	if( index >= CALL_NREGS )
		return -1;
	int reg = isFloat ? XMM(index) : CALL_REGS[index];
	regs->mapped[reg] = id + 1;
	return reg;
#endif
}

static int mapped_reg( call_regs *regs, int id ) {
#	ifndef HL_64
	return -1;
#else
	int i;
	for(i=0;i<CALL_NREGS;i++) {
		int r = CALL_REGS[i];
		if( regs->mapped[r] == id + 1 ) return r;
		r = XMM(i);
		if( regs->mapped[r] == id + 1 ) return r;
	}
	return -1;
#endif
}

static int prepare_call_args( jit_ctx *ctx, int count, int *args, vreg *vregs, int extraSize ) {
	int i;
	int size = extraSize, paddedSize;
	call_regs ctmp = {0};
	for(i=0;i<count;i++) {
		vreg *r = vregs + args[i];
		int cr = select_call_reg(&ctmp, r->t, i);
		if( cr >= 0 ) {
			preg *c = REG_AT(cr);
			preg *cur = fetch(r);
			if( cur != c ) {
				copy(ctx,c,cur,r->size);
				scratch(c);
			}
			RLOCK(c);
			continue;
		}
		size += stack_size(r->t);
	}
	paddedSize = pad_before_call(ctx,size);
	for(i=0;i<count;i++) {
		// RTL
		int j = count - (i + 1);
		vreg *r = vregs + args[j];
		if( (i & 7) == 0 ) jit_buf(ctx);
		if( mapped_reg(&ctmp,j) >= 0 ) continue;
		push_reg(ctx,r);
		if( r->current ) RUNLOCK(r->current);
	}
	return paddedSize;
}

static void op_call( jit_ctx *ctx, preg *r, int size ) {
	preg p;
#	ifdef JIT_DEBUG
	if( IS_64 && size >= 0 ) {
		int jchk;
		op32(ctx,TEST,PESP,pconst(&p,15));
		XJump(JZero,jchk);
		BREAK(); // unaligned ESP
		patch_jump(ctx, jchk);
	}
#	endif
	if( IS_WINCALL64 ) {
		// MSVC requires 32bytes of free space here
		op64(ctx,SUB,PESP,pconst(&p,32));
		if( size >= 0 ) size += 32;
	}
	op32(ctx, CALL, r, UNUSED);
	if( size > 0 ) op64(ctx,ADD,PESP,pconst(&p,size));
}

static void call_native( jit_ctx *ctx, void *nativeFun, int size ) {
	bool isExc = nativeFun == hl_assert || nativeFun == hl_throw || nativeFun == on_jit_error;
	preg p;
	// native function, already resolved
	op64(ctx,MOV,PEAX,pconst64(&p,(int_val)nativeFun));
	op_call(ctx,PEAX, isExc ? -1 : size);
	if( isExc )
		return;
	discard_regs(ctx, true);
}

static void op_call_fun( jit_ctx *ctx, vreg *dst, int findex, int count, int *args ) {
	int fid = findex < 0 ? -1 : ctx->m->functions_indexes[findex];
	bool isNative = fid >= ctx->m->code->nfunctions;
	int size = prepare_call_args(ctx,count,args,ctx->vregs,0);
	preg p;
	if( fid < 0 ) {
		ASSERT(fid);
	} else if( isNative ) {
		call_native(ctx,ctx->m->functions_ptrs[findex],size);
	} else {
		int cpos = BUF_POS() + (IS_WINCALL64 ? 4 : 0);
#		ifdef JIT_DEBUG
		if( IS_64 ) cpos += 13; // ESP CHECK
#		endif
		if( ctx->m->functions_ptrs[findex] ) {
			// already compiled
			op_call(ctx,pconst(&p,(int)(int_val)ctx->m->functions_ptrs[findex] - (cpos + 5)), size);
		} else if( ctx->m->code->functions + fid == ctx->f ) {
			// our current function
			op_call(ctx,pconst(&p, ctx->functionPos - (cpos + 5)), size);
		} else {
			// stage for later
			jlist *j = (jlist*)hl_malloc(&ctx->galloc,sizeof(jlist));
			j->pos = cpos;
			j->target = findex;
			j->next = ctx->calls;
			ctx->calls = j;
			op_call(ctx,pconst(&p,0), size);
		}
		discard_regs(ctx, false);
	}
	if( dst )
		store_result(ctx,dst);
}

static void op_enter( jit_ctx *ctx ) {
	preg p;
	op64(ctx, PUSH, PEBP, UNUSED);
	op64(ctx, MOV, PEBP, PESP);
	if( ctx->totalRegsSize ) op64(ctx, SUB, PESP, pconst(&p,ctx->totalRegsSize));
}

static void op_ret( jit_ctx *ctx, vreg *r ) {
	preg p;
	switch( r->t->kind ) {
	case HF32:
#		ifdef HL_64
		op64(ctx, MOVSS, PXMM(0), fetch(r));
#		else
		op64(ctx,FLD32,&r->stack,UNUSED);
#		endif
		break;
	case HF64:
#		ifdef HL_64
		op64(ctx, MOVSD, PXMM(0), fetch(r));
#		else
		op64(ctx,FLD,&r->stack,UNUSED);
#		endif
		break;
	default:
		if( r->size < 4 && !r->current )
			fetch32(ctx, r);
		if( r->current != PEAX )
			op64(ctx,MOV,PEAX,fetch(r));
		break;
	}
	if( ctx->totalRegsSize ) op64(ctx, ADD, PESP, pconst(&p, ctx->totalRegsSize));
#	ifdef JIT_DEBUG
	{
		int jeq;
		op64(ctx, CMP, PESP, PEBP);
		XJump_small(JEq,jeq);
		jit_error("invalid ESP");
		patch_jump(ctx,jeq);
	}
#	endif
	op64(ctx, POP, PEBP, UNUSED);
	op64(ctx, RET, UNUSED, UNUSED);
}

static void call_native_consts( jit_ctx *ctx, void *nativeFun, int_val *args, int nargs ) {
	int size = pad_before_call(ctx, IS_64 ? 0 : HL_WSIZE*nargs);
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

static void on_jit_error( const char *msg, int_val line ) {
	char buf[256];
	int iline = (int)line;
	sprintf(buf,"%s (line %d)",msg,iline);
#ifdef HL_WIN
	MessageBoxA(NULL,buf,"JIT ERROR",MB_OK);
#else
	printf("JIT ERROR : %s\n",buf);
#endif
	hl_debug_break();
	hl_throw(NULL);
}

static void _jit_error( jit_ctx *ctx, const char *msg, int line ) {
	int_val args[2] = { (int_val)msg, (int_val)line };
	call_native_consts(ctx,on_jit_error,args,2);
}


static preg *op_binop( jit_ctx *ctx, vreg *dst, vreg *a, vreg *b, hl_opcode *op ) {
	preg *pa = fetch(a), *pb = fetch(b), *out = NULL;
	CpuOp o;
	if( IS_FLOAT(a) ) {
		bool isf32 = a->t->kind == HF32;
		switch( op->op ) {
		case OAdd: o = isf32 ? ADDSS : ADDSD; break;
		case OSub: o = isf32 ? SUBSS : SUBSD; break;
		case OMul: o = isf32 ? MULSS : MULSD; break;
		case OSDiv: o = isf32 ? DIVSS : DIVSD; break;
		case OJSLt:
		case OJSGte:
		case OJSLte:
		case OJSGt:
		case OJEq:
		case OJNotEq:
		case OJNotLt:
		case OJNotGte:
			o = isf32 ? COMISS : COMISD;
			break;
		case OSMod:
			{
				int args[] = { a->stack.id, b->stack.id };
				int size = prepare_call_args(ctx,2,args,ctx->vregs,0);
				void *mod_fun;
				if( isf32 ) mod_fun = fmodf; else mod_fun = fmod;
				call_native(ctx,mod_fun,size);
				store_result(ctx,dst);
				return fetch(dst);
			}
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
			} else
				RLOCK(b->current);
			if( pa->kind != RCPU ) {
				pa = alloc_reg(ctx, RCPU);
				op32(ctx,MOV,pa,fetch(a));
			}
			op32(ctx,op->op == OShl ? SHL : (op->op == OUShr ? SHR : SAR), pa, UNUSED);
			if( dst ) store(ctx, dst, pa, true);
			return pa;
		case OSDiv:
		case OUDiv:
		case OSMod:
		case OUMod:
			{
				preg *out = op->op == OSMod || op->op == OUMod ? REG_AT(Edx) : PEAX;
				preg *r;
				int jz, jend;
				if( pa->kind == RCPU && pa->id == Eax ) RLOCK(pa);
				r = alloc_cpu(ctx,b,true);
				// integer div 0 => 0
				op32(ctx,TEST,r,r);
				XJump_small(JNotZero,jz);
				op32(ctx,XOR,out,out);
				XJump_small(JAlways,jend);
				patch_jump(ctx,jz);
				pa = fetch(a);
				if( pa->kind != RCPU || pa->id != Eax ) {
					scratch(PEAX);
					scratch(pa);
					load(ctx,PEAX,a);
				}
				scratch(REG_AT(Edx));
				scratch(REG_AT(Eax));
				if( op->op == OUDiv || op->op == OUMod )
					op32(ctx, XOR, REG_AT(Edx), REG_AT(Edx));
				else
					op32(ctx, CDQ, UNUSED, UNUSED); // sign-extend Eax into Eax:Edx
				op32(ctx, op->op == OUDiv || op->op == OUMod ? DIV : IDIV, fetch(b), UNUSED);
				patch_jump(ctx, jend);
				if( dst ) store(ctx, dst, out, true);
				return out;
			}
		case OJSLt:
		case OJSGte:
		case OJSLte:
		case OJSGt:
		case OJULt:
		case OJUGte:
		case OJEq:
		case OJNotEq:
			switch( a->t->kind ) {
			case HUI8:
			case HBOOL:
				o = CMP8;
				break;
			case HUI16:
				o = CMP16;
				break;
			default:
				o = CMP;
				break;
			}
			break;
		default:
			printf("%s\n", hl_op_name(op->op));
			ASSERT(op->op);
		}
	}
	switch( RTYPE(a) ) {
	case HI32:
	case HUI8:
	case HUI16:
	case HBOOL:
#	ifndef HL_64
	case HDYNOBJ:
	case HVIRTUAL:
	case HOBJ:
	case HSTRUCT:
	case HFUN:
	case HMETHOD:
	case HBYTES:
	case HNULL:
	case HENUM:
	case HDYN:
	case HTYPE:
	case HABSTRACT:
#	endif
		switch( ID2(pa->kind, pb->kind) ) {
		case ID2(RCPU,RCPU):
		case ID2(RCPU,RSTACK):
			op32(ctx, o, pa, pb);
			scratch(pa);
			out = pa;
			break;
		case ID2(RSTACK,RCPU):
			if( dst == a && o != IMUL ) {
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
	case HSTRUCT:
	case HDYNOBJ:
	case HVIRTUAL:
	case HFUN:
	case HMETHOD:
	case HBYTES:
	case HNULL:
	case HENUM:
	case HDYN:
	case HTYPE:
	case HABSTRACT:
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
	case HF32:
		pa = alloc_fpu(ctx, a, true);
		pb = alloc_fpu(ctx, b, true);
		switch( ID2(pa->kind, pb->kind) ) {
		case ID2(RFPU,RFPU):
			op64(ctx,o,pa,pb);
			if( o == COMISD && op->op != OJSGt ) {
				int jnotnan;
				XJump_small(JNParity,jnotnan);
				switch( op->op ) {
				case OJSLt:
				case OJNotLt:
					{
						preg *r = alloc_reg(ctx,RCPU);
						// set CF=0, ZF=1
						op64(ctx,XOR,r,r);
						RUNLOCK(r);
						break;
					}
				case OJSGte:
				case OJNotGte:
					{
						preg *r = alloc_reg(ctx,RCPU);
						// set ZF=0, CF=1
						op64(ctx,XOR,r,r);
						op64(ctx,CMP,r,PESP);
						RUNLOCK(r);
						break;
					}
					break;
				case OJNotEq:
				case OJEq:
					// set ZF=0, CF=?
				case OJSLte:
					// set ZF=0, CF=0
					op64(ctx,TEST,PESP,PESP);
					break;
				default:
					ASSERT(op->op);
				}
				patch_jump(ctx,jnotnan);
			}
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
	case OJSGte:
		XJump(isFloat ? JUGte : JSGte,j);
		break;
	case OJSGt:
		XJump(isFloat ? JUGt : JSGt,j);
		break;
	case OJUGte:
		XJump(JUGte,j);
		break;
	case OJSLt:
		XJump(isFloat ? JULt : JSLt,j);
		break;
	case OJSLte:
		XJump(isFloat ? JULte : JSLte,j);
		break;
	case OJULt:
		XJump(JULt,j);
		break;
	case OJEq:
		XJump(JEq,j);
		break;
	case OJNotEq:
		XJump(JNeq,j);
		break;
	case OJNotLt:
		XJump(JUGte,j);
		break;
	case OJNotGte:
		XJump(JULt,j);
		break;
	default:
		j = 0;
		printf("Unknown JUMP %d\n",op);
		break;
	}
	return j;
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

#define HDYN_VALUE 8

static void dyn_value_compare( jit_ctx *ctx, preg *a, preg *b, hl_type *t ) {
	preg p;
	switch( t->kind ) {
	case HUI8:
	case HBOOL:
		op32(ctx,MOV8,a,pmem(&p,a->id,HDYN_VALUE));
		op32(ctx,MOV8,b,pmem(&p,b->id,HDYN_VALUE));
		op64(ctx,CMP8,a,b);
		break;
	case HUI16:
		op32(ctx,MOV16,a,pmem(&p,a->id,HDYN_VALUE));
		op32(ctx,MOV16,b,pmem(&p,b->id,HDYN_VALUE));
		op64(ctx,CMP16,a,b);
		break;
	case HI32:
		op32(ctx,MOV,a,pmem(&p,a->id,HDYN_VALUE));
		op32(ctx,MOV,b,pmem(&p,b->id,HDYN_VALUE));
		op64(ctx,CMP,a,b);
		break;
	case HF32:
		{
			preg *fa = alloc_reg(ctx, RFPU);
			preg *fb = alloc_reg(ctx, RFPU);
			op64(ctx,MOVSS,fa,pmem(&p,a->id,HDYN_VALUE));
			op64(ctx,MOVSS,fb,pmem(&p,b->id,HDYN_VALUE));
			op64(ctx,COMISD,fa,fb);
		}
		break;
	case HF64:
		{
			preg *fa = alloc_reg(ctx, RFPU);
			preg *fb = alloc_reg(ctx, RFPU);
			op64(ctx,MOVSD,fa,pmem(&p,a->id,HDYN_VALUE));
			op64(ctx,MOVSD,fb,pmem(&p,b->id,HDYN_VALUE));
			op64(ctx,COMISD,fa,fb);
		}
		break;
	default:
		// ptr comparison
		op64(ctx,MOV,a,pmem(&p,a->id,HDYN_VALUE));
		op64(ctx,MOV,b,pmem(&p,b->id,HDYN_VALUE));
		op64(ctx,CMP,a,b);
		break;
	}
}

static void op_jump( jit_ctx *ctx, vreg *a, vreg *b, hl_opcode *op, int targetPos ) {
	if( a->t->kind == HDYN || b->t->kind == HDYN || a->t->kind == HFUN || b->t->kind == HFUN ) {
		int args[] = { a->stack.id, b->stack.id };
		int size = prepare_call_args(ctx,2,args,ctx->vregs,0);
		call_native(ctx,hl_dyn_compare,size);
		if( op->op == OJSGt || op->op == OJSGte ) {
			preg p;
			int jinvalid;
			op32(ctx,CMP,PEAX,pconst(&p,hl_invalid_comparison));
			XJump_small(JEq,jinvalid);
			op32(ctx,TEST,PEAX,PEAX);
			register_jump(ctx,do_jump(ctx,op->op, IS_FLOAT(a)),targetPos);
			patch_jump(ctx,jinvalid);
			return;
		}
		op32(ctx,TEST,PEAX,PEAX);
	} else switch( a->t->kind ) {
	case HTYPE:
		{
			int args[] = { a->stack.id, b->stack.id };
			int size = prepare_call_args(ctx,2,args,ctx->vregs,0);
			preg p;
			call_native(ctx,hl_same_type,size);
			op64(ctx,CMP8,PEAX,pconst(&p,1));
		}
		break;
	case HNULL:
		{
			preg *pa = hl_type_size(a->t->tparam) == 1 ? alloc_cpu8(ctx,a,true) : alloc_cpu(ctx,a,true);
			preg *pb = hl_type_size(b->t->tparam) == 1 ? alloc_cpu8(ctx,b,true) : alloc_cpu(ctx,b,true);
			if( op->op == OJEq ) {
				// if( a == b || (a && b && a->v == b->v) ) goto
				int ja, jb;
				// if( a != b && (!a || !b || a->v != b->v) ) goto
				op64(ctx,CMP,pa,pb);
				register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,ja);
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jb);
				dyn_value_compare(ctx,pa,pb,a->t->tparam);
				register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
				scratch(pa);
				scratch(pb);
				patch_jump(ctx,ja);
				patch_jump(ctx,jb);
			} else if( op->op == OJNotEq ) {
				int jeq, jcmp;
				// if( a != b && (!a || !b || a->v != b->v) ) goto
				op64(ctx,CMP,pa,pb);
				XJump_small(JEq,jeq);
				op64(ctx,TEST,pa,pa);
				register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
				op64(ctx,TEST,pb,pb);
				register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
				dyn_value_compare(ctx,pa,pb,a->t->tparam);
				XJump_small(JZero,jcmp);
				scratch(pa);
				scratch(pb);
				register_jump(ctx,do_jump(ctx,OJNotEq,false),targetPos);
				patch_jump(ctx,jcmp);
				patch_jump(ctx,jeq);
			} else
				ASSERT(op->op);
			return;
		}
	case HVIRTUAL:
		{
			preg p;
			preg *pa = alloc_cpu(ctx,a,true);
			preg *pb = alloc_cpu(ctx,b,true);
			int ja,jb,jav,jbv,jvalue;
			if( b->t->kind == HOBJ ) {
				if( op->op == OJEq ) {
					// if( a ? (b && a->value == b) : (b == NULL) ) goto
					op64(ctx,TEST,pa,pa);
					XJump_small(JZero,ja);
					op64(ctx,TEST,pb,pb);
					XJump_small(JZero,jb);
					op64(ctx,MOV,pa,pmem(&p,pa->id,HL_WSIZE));
					op64(ctx,CMP,pa,pb);
					XJump_small(JAlways,jvalue);
					patch_jump(ctx,ja);
					op64(ctx,TEST,pb,pb);
					patch_jump(ctx,jvalue);
					register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
					patch_jump(ctx,jb);
				} else if( op->op == OJNotEq ) {
					// if( a ? (b == NULL || a->value != b) : (b != NULL) ) goto
					op64(ctx,TEST,pa,pa);
					XJump_small(JZero,ja);
					op64(ctx,TEST,pb,pb);
					register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
					op64(ctx,MOV,pa,pmem(&p,pa->id,HL_WSIZE));
					op64(ctx,CMP,pa,pb);
					XJump_small(JAlways,jvalue);
					patch_jump(ctx,ja);
					op64(ctx,TEST,pb,pb);
					patch_jump(ctx,jvalue);
					register_jump(ctx,do_jump(ctx,OJNotEq,false),targetPos);
				} else
					ASSERT(op->op);
				scratch(pa);
				return;
			}
			op64(ctx,CMP,pa,pb);
			if( op->op == OJEq ) {
				// if( a == b || (a && b && a->value && b->value && a->value == b->value) ) goto
				register_jump(ctx,do_jump(ctx,OJEq, false),targetPos);
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,ja);
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jb);
				op64(ctx,MOV,pa,pmem(&p,pa->id,HL_WSIZE));
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,jav);
				op64(ctx,MOV,pb,pmem(&p,pb->id,HL_WSIZE));
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jbv);
				op64(ctx,CMP,pa,pb);
				XJump_small(JNeq,jvalue);
				register_jump(ctx,do_jump(ctx,OJEq, false),targetPos);
				patch_jump(ctx,ja);
				patch_jump(ctx,jb);
				patch_jump(ctx,jav);
				patch_jump(ctx,jbv);
				patch_jump(ctx,jvalue);
			} else if( op->op == OJNotEq ) {
				int jnext;
				// if( a != b && (!a || !b || !a->value || !b->value || a->value != b->value) ) goto
				XJump_small(JEq,jnext);
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,ja);
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jb);
				op64(ctx,MOV,pa,pmem(&p,pa->id,HL_WSIZE));
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,jav);
				op64(ctx,MOV,pb,pmem(&p,pb->id,HL_WSIZE));
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jbv);
				op64(ctx,CMP,pa,pb);
				XJump_small(JEq,jvalue);
				patch_jump(ctx,ja);
				patch_jump(ctx,jb);
				patch_jump(ctx,jav);
				patch_jump(ctx,jbv);
				register_jump(ctx,do_jump(ctx,OJAlways, false),targetPos);
				patch_jump(ctx,jnext);
				patch_jump(ctx,jvalue);
			} else
				ASSERT(op->op);
			scratch(pa);
			scratch(pb);
			return;
		}
		break;
	case HOBJ:
	case HSTRUCT:
		if( b->t->kind == HVIRTUAL ) {
			op_jump(ctx,b,a,op,targetPos); // inverse
			return;
		}
		if( hl_get_obj_rt(a->t)->compareFun ) {
			preg *pa = alloc_cpu(ctx,a,true);
			preg *pb = alloc_cpu(ctx,b,true);
			preg p;
			int jeq, ja, jb, jcmp;
			int args[] = { a->stack.id, b->stack.id };
			switch( op->op ) {
			case OJEq:
				// if( a == b || (a && b && cmp(a,b) == 0) ) goto
				op64(ctx,CMP,pa,pb);
				XJump_small(JEq,jeq);
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,ja);
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jb);
				op_call_fun(ctx,NULL,(int)(int_val)a->t->obj->rt->compareFun,2,args);
				op32(ctx,TEST,PEAX,PEAX);
				XJump_small(JNotZero,jcmp);
				patch_jump(ctx,jeq);
				register_jump(ctx,do_jump(ctx,OJAlways,false),targetPos);
				patch_jump(ctx,ja);
				patch_jump(ctx,jb);
				patch_jump(ctx,jcmp);
				break;
			case OJNotEq:
				// if( a != b && (!a || !b || cmp(a,b) != 0) ) goto
				op64(ctx,CMP,pa,pb);
				XJump_small(JEq,jeq);
				op64(ctx,TEST,pa,pa);
				register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);
				op64(ctx,TEST,pb,pb);
				register_jump(ctx,do_jump(ctx,OJEq,false),targetPos);

				op_call_fun(ctx,NULL,(int)(int_val)a->t->obj->rt->compareFun,2,args);
				op32(ctx,TEST,PEAX,PEAX);
				XJump_small(JZero,jcmp);

				register_jump(ctx,do_jump(ctx,OJNotEq,false),targetPos);
				patch_jump(ctx,jcmp);
				patch_jump(ctx,jeq);
				break;
			default:
				// if( a && b && cmp(a,b) ?? 0 ) goto
				op64(ctx,TEST,pa,pa);
				XJump_small(JZero,ja);
				op64(ctx,TEST,pb,pb);
				XJump_small(JZero,jb);
				op_call_fun(ctx,NULL,(int)(int_val)a->t->obj->rt->compareFun,2,args);
				op32(ctx,CMP,PEAX,pconst(&p,0));
				register_jump(ctx,do_jump(ctx,op->op,false),targetPos);
				patch_jump(ctx,ja);
				patch_jump(ctx,jb);
				break;
			}
			return;
		}
		// fallthrough
	default:
		// make sure we have valid 8 bits registers
		if( a->size == 1 ) alloc_cpu8(ctx,a,true);
		if( b->size == 1 ) alloc_cpu8(ctx,b,true);
		op_binop(ctx,NULL,a,b,op);
		break;
	}
	register_jump(ctx,do_jump(ctx,op->op, IS_FLOAT(a)),targetPos);
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
		preg *r = REG_AT(XMM(i));
		r->id = i;
		r->kind = RFPU;
	}
	return ctx;
}

void hl_jit_free( jit_ctx *ctx, h_bool can_reset ) {
	free(ctx->vregs);
	free(ctx->opsPos);
	free(ctx->startBuf);
	ctx->maxRegs = 0;
	ctx->vregs = NULL;
	ctx->maxOps = 0;
	ctx->opsPos = NULL;
	ctx->startBuf = NULL;
	ctx->bufSize = 0;
	ctx->buf.b = NULL;
	ctx->calls = NULL;
	ctx->switchs = NULL;
	ctx->closure_list = NULL;
	hl_free(&ctx->falloc);
	hl_free(&ctx->galloc);
	if( !can_reset ) free(ctx);
}

static void jit_nops( jit_ctx *ctx ) {
	while( BUF_POS() & 15 )
		op32(ctx, NOP, UNUSED, UNUSED);
}

#define MAX_ARGS 16

static void *call_jit_c2hl = NULL;
static void *call_jit_hl2c = NULL;

static void *callback_c2hl( void **f, hl_type *t, void **args, vdynamic *ret ) {
	/*
		prepare stack and regs according to prepare_call_args, but by reading runtime type information
		from the function type. The stack and regs will be setup by the trampoline function.
	*/
	unsigned char stack[MAX_ARGS * 8];
	call_regs cregs = {0};
	if( t->fun->nargs > MAX_ARGS )
		hl_error("Too many arguments for dynamic call");
	int i, size = 0, pad = 0, pos = 0;
	for(i=0;i<t->fun->nargs;i++) {
		hl_type *at = t->fun->args[i];
		int creg = select_call_reg(&cregs,at,i);
		if( creg >= 0 )
			continue;
		size += stack_size(at);
	}
	pad = (-size) & 15;
	size += pad;
	pos = 0;
	for(i=0;i<t->fun->nargs;i++) {
		// RTL
		hl_type *at = t->fun->args[i];
		void *v = args[i];
		int creg = mapped_reg(&cregs,i);
		void *store;
		if( creg >= 0 ) {
			if( REG_IS_FPU(creg) ) {
				store = stack + size + CALL_NREGS * HL_WSIZE + (creg - XMM(0)) * sizeof(double);
			} else {
				store = stack + size + call_reg_index(creg) * HL_WSIZE;
			}
			switch( at->kind ) {
			case HBOOL:
			case HUI8:
				*(int_val*)store = *(unsigned char*)v;
				break;
			case HUI16:
				*(int_val*)store = *(unsigned short*)v;
				break;
			case HI32:
				*(int_val*)store = *(int*)v;
				break;
			case HF32:
				{
					double d = (double)*(float*)v;
					*(double*)store = d;
				}
				break;
			case HF64:
				*(double*)store = *(double*)v;
				break;
			case HI64:
				*(int64*)store = *(int64*)v;
				break;
			default:
				*(void**)store = v;
				break;
			}
		} else {
			int tsize = stack_size(at);
			store = stack + pos;
			pos += tsize;
			switch( at->kind ) {
			case HBOOL:
			case HUI8:
				*(int*)store = *(unsigned char*)v;
				break;
			case HUI16:
				*(int*)store = *(unsigned short*)v;
				break;
			case HI32:
			case HF32:
				*(int*)store = *(int*)v;
				break;
			case HF64:
				*(double*)store = *(double*)v;
				break;
			case HI64:
				*(int64*)store = *(int64*)v;
				break;
			default:
				*(void**)store = v;
				break;
			}
		}
	}
	pos += pad;
	pos >>= IS_64 ? 3 : 2;
	switch( t->fun->ret->kind ) {
	case HUI8:
	case HUI16:
	case HI32:
	case HBOOL:
		ret->v.i = ((int (*)(void *, void *, void *))call_jit_c2hl)(*f, (void**)&stack + pos, &stack);
		return &ret->v.i;
	case HF32:
		ret->v.f = ((float (*)(void *, void *, void *))call_jit_c2hl)(*f, (void**)&stack + pos, &stack);
		return &ret->v.f;
	case HF64:
		ret->v.d = ((double (*)(void *, void *, void *))call_jit_c2hl)(*f, (void**)&stack + pos, &stack);
		return &ret->v.d;
	default:
		return ((void *(*)(void *, void *, void *))call_jit_c2hl)(*f, (void**)&stack + pos, &stack);
	}
}

static void jit_c2hl( jit_ctx *ctx ) {
	//	create the function that will be called by callback_c2hl
	//	it will make sure to prepare the stack/regs according to native calling conventions
	int jeq, jloop, jstart;
	preg *fptr, *stack, *stend;
	preg p;

	op64(ctx,PUSH,PEBP,UNUSED);
	op64(ctx,MOV,PEBP,PESP);

#	ifdef HL_64
	
	fptr = REG_AT(R10);
	stack = PEAX;
	stend = REG_AT(R11);
	op64(ctx, MOV, fptr, REG_AT(CALL_REGS[0]));
	op64(ctx, MOV, stack, REG_AT(CALL_REGS[1]));
	op64(ctx, MOV, stend, REG_AT(CALL_REGS[2]));

	// set native call regs
	int i;
	for(i=0;i<CALL_NREGS;i++)
		op64(ctx,MOV,REG_AT(CALL_REGS[i]),pmem(&p,stack->id,i*HL_WSIZE));
	for(i=0;i<CALL_NREGS;i++)
		op64(ctx,MOVSD,REG_AT(XMM(i)),pmem(&p,stack->id,(i+CALL_NREGS)*HL_WSIZE));

#	else

	// make sure the stack is aligned on 16 bytes
	// the amount of push we will do afterwards is guaranteed to be a multiple of 16bytes by hl_callback
#	ifdef HL_VCC
	// VCC does not guarantee us an aligned stack...
	op64(ctx,MOV,PEAX,PESP);
	op64(ctx,AND,PEAX,pconst(&p,15));
	op64(ctx,SUB,PESP,PEAX);
#	else
	op64(ctx,SUB,PESP,pconst(&p,8));
#	endif

	// mov arguments to regs
	fptr = REG_AT(Eax);
	stack = REG_AT(Edx);
	stend = REG_AT(Ecx);
	op64(ctx,MOV,fptr,pmem(&p,Ebp,HL_WSIZE*2));
	op64(ctx,MOV,stack,pmem(&p,Ebp,HL_WSIZE*3));
	op64(ctx,MOV,stend,pmem(&p,Ebp,HL_WSIZE*4));

#	endif

	// push stack args
	jstart = BUF_POS();
	op64(ctx,CMP,stack,stend);
	XJump(JEq,jeq);
	op64(ctx,SUB,stack,pconst(&p,HL_WSIZE));
	op64(ctx,PUSH,pmem(&p,stack->id,0),UNUSED);
	XJump(JAlways,jloop);
	patch_jump(ctx,jeq);
	patch_jump_to(ctx, jloop, jstart);

	op_call(ctx,fptr,0);

	// cleanup and ret
	op64(ctx,MOV,PESP,PEBP);
	op64(ctx,POP,PEBP, UNUSED);
	op64(ctx,RET,UNUSED,UNUSED);
}

static vdynamic *jit_wrapper_call( vclosure_wrapper *c, char *stack_args, void **regs ) {
	vdynamic *args[MAX_ARGS];
	int i;
	int nargs = c->cl.t->fun->nargs;
	call_regs cregs = {0};
	if( nargs > MAX_ARGS )
		hl_error("Too many arguments for wrapped call");
	cregs.nextCpu++; // skip fptr in HL64 - was passed as arg0
	for(i=0;i<nargs;i++) {
		hl_type *t = c->cl.t->fun->args[i];
		int creg = select_call_reg(&cregs,t,i);
		if( creg < 0 ) {
			args[i] = hl_is_dynamic(t) ? *(vdynamic**)stack_args : hl_make_dyn(stack_args,t);
			stack_args += stack_size(t);
		} else if( hl_is_dynamic(t) ) {
			args[i] = *(vdynamic**)(regs + call_reg_index(creg));
		} else if( t->kind == HF32 || t->kind == HF64 ) {
			args[i] = hl_make_dyn(regs + CALL_NREGS + creg - XMM(0),&hlt_f64);
		} else {
			args[i] = hl_make_dyn(regs + call_reg_index(creg),t);
		}
	}
	return hl_dyn_call(c->wrappedFun,args,nargs);
}

static void *jit_wrapper_ptr( vclosure_wrapper *c, char *stack_args, void **regs ) {
	vdynamic *ret = jit_wrapper_call(c, stack_args, regs);
	hl_type *tret = c->cl.t->fun->ret;
	switch( tret->kind ) {
	case HVOID:
		return NULL;
	case HUI8:
	case HUI16:
	case HI32:
	case HBOOL:
		return (void*)(int_val)hl_dyn_casti(&ret,&hlt_dyn,tret);
	default:
		return hl_dyn_castp(&ret,&hlt_dyn,tret);
	}
}

static double jit_wrapper_d( vclosure_wrapper *c, char *stack_args, void **regs ) {
	vdynamic *ret = jit_wrapper_call(c, stack_args, regs);
	return hl_dyn_castd(&ret,&hlt_dyn);
}

static void jit_hl2c( jit_ctx *ctx ) {
	// create a function that is called with a vclosure_wrapper* and native args
	// and pack and pass the args to callback_hl2c
	preg p;
	int jfloat1, jfloat2, jexit;
	hl_type_fun *ft = NULL;
	int size;
#	ifdef HL_64
	preg *cl = REG_AT(CALL_REGS[0]);
	preg *tmp = REG_AT(CALL_REGS[1]);
#	else
	preg *cl = REG_AT(Ecx);
	preg *tmp = REG_AT(Edx);
#	endif

	op64(ctx,PUSH,PEBP,UNUSED);
	op64(ctx,MOV,PEBP,PESP);

#	ifdef HL_64
	// push registers
	int i;
	op64(ctx,SUB,PESP,pconst(&p,CALL_NREGS*8));
	for(i=0;i<CALL_NREGS;i++)
		op64(ctx,MOVSD,pmem(&p,Esp,i*8),REG_AT(XMM(i)));
	for(i=0;i<CALL_NREGS;i++)
		op64(ctx,PUSH,REG_AT(CALL_REGS[CALL_NREGS - 1 - i]),UNUSED);
#	endif

	// opcodes for:
	//		switch( arg0->t->fun->ret->kind ) {
	//		case HF32: case HF64: return jit_wrapper_d(arg0,&args);
	//		default: return jit_wrapper_ptr(arg0,&args);
	//		}
	if( !IS_64 ) 
		op64(ctx,MOV,cl,pmem(&p,Ebp,HL_WSIZE*2)); // load arg0
	op64(ctx,MOV,tmp,pmem(&p,cl->id,0)); // ->t
	op64(ctx,MOV,tmp,pmem(&p,tmp->id,HL_WSIZE)); // ->fun
	op64(ctx,MOV,tmp,pmem(&p,tmp->id,(int)(int_val)&ft->ret)); // ->ret
	op32(ctx,MOV,tmp,pmem(&p,tmp->id,0)); // -> kind

	op32(ctx,CMP,tmp,pconst(&p,HF64));
	XJump_small(JEq,jfloat1);
	op32(ctx,CMP,tmp,pconst(&p,HF32));
	XJump_small(JEq,jfloat2);

	// 64 bits : ESP + EIP (+WIN64PAD) 
	// 32 bits : ESP + EIP + PARAM0
	int args_pos = IS_64 ? ((IS_WINCALL64 ? 32 : 0) + HL_WSIZE * 2) : (HL_WSIZE*3);

	size = begin_native_call(ctx,3);
	op64(ctx, LEA, tmp, pmem(&p,Ebp,-HL_WSIZE*CALL_NREGS*2));
	set_native_arg(ctx, tmp);
	op64(ctx, LEA, tmp, pmem(&p,Ebp,args_pos));
	set_native_arg(ctx, tmp);
	set_native_arg(ctx, cl);
	call_native(ctx, jit_wrapper_ptr, size);
	XJump_small(JAlways, jexit);

	patch_jump(ctx,jfloat1);
	patch_jump(ctx,jfloat2);
	size = begin_native_call(ctx,3);
	op64(ctx, LEA, tmp, pmem(&p,Ebp,-HL_WSIZE*CALL_NREGS*2));
	set_native_arg(ctx, tmp);
	op64(ctx, LEA, tmp, pmem(&p,Ebp,args_pos));
	set_native_arg(ctx, tmp);
	set_native_arg(ctx, cl);
	call_native(ctx, jit_wrapper_d, size);

	patch_jump(ctx,jexit);
	op64(ctx,MOV,PESP,PEBP);
	op64(ctx,POP,PEBP, UNUSED);
	op64(ctx,RET,UNUSED,UNUSED);
}

#ifdef JIT_CUSTOM_LONGJUMP
// Win64 debug CRT performs a Rtl stack check in debug mode, preventing from
// using longjump. This in an alternate implementation that follows the native
// setjump storage.
//
// Another more reliable way of handling this would be to use RtlAddFunctionTable
// but this would require complex creation of unwind info
static void jit_longjump( jit_ctx *ctx ) {
	preg *buf = REG_AT(CALL_REGS[0]);
	preg *ret = REG_AT(CALL_REGS[1]);
	preg p;
	int i;
	op64(ctx,MOV,PEAX,ret); // return value
	op64(ctx,MOV,REG_AT(Edx),pmem(&p,buf->id,0x0));
	op64(ctx,MOV,REG_AT(Ebx),pmem(&p,buf->id,0x8));
	op64(ctx,MOV,REG_AT(Esp),pmem(&p,buf->id,0x10));
	op64(ctx,MOV,REG_AT(Ebp),pmem(&p,buf->id,0x18));
	op64(ctx,MOV,REG_AT(Esi),pmem(&p,buf->id,0x20));
	op64(ctx,MOV,REG_AT(Edi),pmem(&p,buf->id,0x28));
	op64(ctx,MOV,REG_AT(R12),pmem(&p,buf->id,0x30));
	op64(ctx,MOV,REG_AT(R13),pmem(&p,buf->id,0x38));
	op64(ctx,MOV,REG_AT(R14),pmem(&p,buf->id,0x40));
	op64(ctx,MOV,REG_AT(R15),pmem(&p,buf->id,0x48));
	op64(ctx,LDMXCSR,pmem(&p,buf->id,0x58), UNUSED);
	op64(ctx,FLDCW,pmem(&p,buf->id,0x5C), UNUSED);
	for(i=0;i<10;i++)
		op64(ctx,MOVSD,REG_AT(XMM(i+6)),pmem(&p,buf->id,0x60 + i * 16));
	op64(ctx,PUSH,pmem(&p,buf->id,0x50),UNUSED);
	op64(ctx,RET,UNUSED,UNUSED);
}
#endif

static void jit_fail( uchar *msg ) {
	if( msg == NULL ) {
		hl_debug_break();
		msg = USTR("assert");
	}
	vdynamic *d = hl_alloc_dynamic(&hlt_bytes);
	d->v.ptr = msg;
	hl_throw(d);
}

static void jit_null_access( jit_ctx *ctx ) {
	op64(ctx,PUSH,PEBP,UNUSED);
	op64(ctx,MOV,PEBP,PESP);
	int_val arg = (int_val)USTR("Null access");
	call_native_consts(ctx, jit_fail, &arg, 1);
}

static void jit_assert( jit_ctx *ctx ) {
	op64(ctx,PUSH,PEBP,UNUSED);
	op64(ctx,MOV,PEBP,PESP);
	int_val arg = 0;
	call_native_consts(ctx, jit_fail, &arg, 1);
}

static int jit_build( jit_ctx *ctx, void (*fbuild)( jit_ctx *) ) {
	int pos;
	jit_buf(ctx);
	jit_nops(ctx);
	pos = BUF_POS();
	fbuild(ctx);
	jit_nops(ctx);
	return pos;
}

static void hl_jit_init_module( jit_ctx *ctx, hl_module *m ) {
	int i;
	ctx->m = m;
	if( m->code->hasdebug )
		ctx->debug = (hl_debug_infos*)malloc(sizeof(hl_debug_infos) * m->code->nfunctions);
	for(i=0;i<m->code->nfloats;i++) {
		jit_buf(ctx);
		*ctx->buf.d++ = m->code->floats[i];
	}
}

void hl_jit_init( jit_ctx *ctx, hl_module *m ) {
	hl_jit_init_module(ctx,m);
	ctx->c2hl = jit_build(ctx, jit_c2hl);
	ctx->hl2c = jit_build(ctx, jit_hl2c);
#	ifdef JIT_CUSTOM_LONGJUMP
	ctx->longjump = jit_build(ctx, jit_longjump);
#	endif
	ctx->static_functions[0] = (void*)(int_val)jit_build(ctx,jit_null_access);
	ctx->static_functions[1] = (void*)(int_val)jit_build(ctx,jit_assert);
}

void hl_jit_reset( jit_ctx *ctx, hl_module *m ) {
	ctx->debug = NULL;
	hl_jit_init_module(ctx,m);
}

static void *get_dyncast( hl_type *t ) {
	switch( t->kind ) {
	case HF32:
		return hl_dyn_castf;
	case HF64:
		return hl_dyn_castd;
	case HI32:
	case HUI16:
	case HUI8:
	case HBOOL:
		return hl_dyn_casti;
	default:
		return hl_dyn_castp;
	}
}

static void *get_dynset( hl_type *t ) {
	switch( t->kind ) {
	case HF32:
		return hl_dyn_setf;
	case HF64:
		return hl_dyn_setd;
	case HI32:
	case HUI16:
	case HUI8:
	case HBOOL:
		return hl_dyn_seti;
	default:
		return hl_dyn_setp;
	}
}

static void *get_dynget( hl_type *t ) {
	switch( t->kind ) {
	case HF32:
		return hl_dyn_getf;
	case HF64:
		return hl_dyn_getd;
	case HI32:
	case HUI16:
	case HUI8:
	case HBOOL:
		return hl_dyn_geti;
	default:
		return hl_dyn_getp;
	}
}

static double uint_to_double( unsigned int v ) {
	return v;
}

static vclosure *alloc_static_closure( jit_ctx *ctx, int fid ) {
	hl_module *m = ctx->m;
	vclosure *c = hl_malloc(&m->ctx.alloc,sizeof(vclosure));
	int fidx = m->functions_indexes[fid];
	c->hasValue = 0;
	if( fidx >= m->code->nfunctions ) {
		// native
		c->t = m->code->natives[fidx - m->code->nfunctions].t;
		c->fun = m->functions_ptrs[fid];
		c->value = NULL;
	} else {
		c->t = m->code->functions[fidx].type;
		c->fun = (void*)(int_val)fid;
		c->value = ctx->closure_list;
		ctx->closure_list = c;
	}
	return c;
}

static void make_dyn_cast( jit_ctx *ctx, vreg *dst, vreg *v ) {
	int size;
	preg p;
	preg *tmp;
	switch( dst->t->kind ) {
	case HF32:
	case HF64:
		size = begin_native_call(ctx, 2);
		set_native_arg(ctx, pconst64(&p,(int_val)v->t));
		break;
	default:
		size = begin_native_call(ctx, 3);
		set_native_arg(ctx, pconst64(&p,(int_val)dst->t));
		set_native_arg(ctx, pconst64(&p,(int_val)v->t));
		break;
	}
	tmp = alloc_native_arg(ctx);
	op64(ctx,MOV,tmp,REG_AT(Ebp));
	if( v->stackPos >= 0 )
		op64(ctx,ADD,tmp,pconst(&p,v->stackPos));
	else
		op64(ctx,SUB,tmp,pconst(&p,-v->stackPos));
	set_native_arg(ctx,tmp);
	call_native(ctx,get_dyncast(dst->t),size);
	store_result(ctx, dst);
}

int hl_jit_function( jit_ctx *ctx, hl_module *m, hl_function *f ) {
	int i, size = 0, opCount;
	int codePos = BUF_POS();
	int nargs = f->type->fun->nargs;
	unsigned short *debug16 = NULL;
	int *debug32 = NULL;
	call_regs cregs = {0};
	hl_thread_info *tinf = NULL;
	preg p;
	ctx->f = f;
	ctx->allocOffset = 0;
	if( f->nregs > ctx->maxRegs ) {
		free(ctx->vregs);
		ctx->vregs = (vreg*)malloc(sizeof(vreg) * (f->nregs + 1));
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
	int argsSize = 0;
	for(i=0;i<nargs;i++) {
		vreg *r = R(i);
		int creg = select_call_reg(&cregs,r->t,i);
		if( creg < 0 || IS_WINCALL64 ) {
			// use existing stack storage 
			r->stackPos = argsSize + HL_WSIZE * 2;
			argsSize += stack_size(r->t);
		} else {
			// make room in local vars
			size += r->size;
			size += hl_pad_size(size,r->t);
			r->stackPos = -size;
		}
	}
	for(i=nargs;i<f->nregs;i++) {
		vreg *r = R(i);
		size += r->size;
		size += hl_pad_size(size,r->t); // align local vars
		r->stackPos = -size;
	}
#	ifdef HL_64
	size += (-size) & 15; // align on 16 bytes
#	else
	size += hl_pad_size(size,&hlt_dyn); // align on word size
#	endif
	ctx->totalRegsSize = size;
	jit_buf(ctx);
	ctx->functionPos = BUF_POS();
	op_enter(ctx);
#	ifdef HL_64
	{
		// store in local var
		for(i=0;i<nargs;i++) {
			vreg *r = R(i);
			preg *p;
			int reg = mapped_reg(&cregs, i);
			if( reg < 0 ) continue;
			p = REG_AT(reg);
			copy(ctx,fetch(r),p,r->size);
			p->holds = r;
			r->current = p;
		}
	}
#	endif
	if( ctx->m->code->hasdebug ) {
		debug16 = (unsigned short*)malloc(sizeof(unsigned short) * (f->nops + 1));
		debug16[0] = (unsigned short)(BUF_POS() - codePos);
	}
	ctx->opsPos[0] = BUF_POS();

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
		// emit code
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
#				ifdef HL_64
				preg *tmp = alloc_reg(ctx, RCPU);
				op64(ctx, MOV, tmp, pconst64(&p,(int_val)addr));
				copy_to(ctx, dst, pmem(&p,tmp->id,0));
#				else
				copy_to(ctx, dst, paddr(&p,addr));
#				endif
			}
			break;
		case OSetGlobal:
			{
				void *addr = m->globals_data + m->globals_indexes[o->p1];
#				ifdef HL_64
				preg *tmp = alloc_reg(ctx, RCPU);
				op64(ctx, MOV, tmp, pconst64(&p,(int_val)addr));
				copy_from(ctx, pmem(&p,tmp->id,0), ra);
#				else
				copy_from(ctx, paddr(&p,addr), ra);
#				endif
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
		case OSMod:
		case OUMod:
			op_binop(ctx, dst, ra, rb, o);
			break;
		case ONeg:
			{
				if( IS_FLOAT(ra) ) {
					preg *pa = alloc_reg(ctx,RFPU);
					preg *pb = alloc_fpu(ctx,ra,true);
					op64(ctx,XORPD,pa,pa);
					op64(ctx,ra->t->kind == HF32 ? SUBSS : SUBSD,pa,pb);
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
		case OJFalse:
		case OJTrue:
		case OJNotNull:
		case OJNull:
			{
				preg *r = dst->t->kind == HBOOL ? alloc_cpu8(ctx, dst, true) : alloc_cpu(ctx, dst, true);
				op64(ctx, dst->t->kind == HBOOL ? TEST8 : TEST, r, r);
				XJump( o->op == OJFalse || o->op == OJNull ? JZero : JNotZero,jump);
				register_jump(ctx,jump,(opCount + 1) + o->p2);
			}
			break;
		case OJEq:
		case OJNotEq:
		case OJSLt:
		case OJSGte:
		case OJSLte:
		case OJSGt:
		case OJULt:
		case OJUGte:
		case OJNotLt:
		case OJNotGte:
			op_jump(ctx,dst,ra,o,(opCount + 1) + o->p3);
			break;
		case OJAlways:
			jump = do_jump(ctx,o->op,false);
			register_jump(ctx,jump,(opCount + 1) + o->p1);
			break;
		case OToDyn:
			if( ra->t->kind == HBOOL ) {
				int size = begin_native_call(ctx, 1);
				set_native_arg(ctx, fetch(ra));
				call_native(ctx, hl_alloc_dynbool, size);
				store(ctx, dst, PEAX, true);
			} else {
				int_val rt = (int_val)ra->t;
				int jskip = 0;
				if( hl_is_ptr(ra->t) ) {
					int jnz;
					preg *a = alloc_cpu(ctx,ra,true);
					op64(ctx,TEST,a,a);
					XJump_small(JNotZero,jnz);
					op64(ctx,XOR,PEAX,PEAX); // will replace the result of alloc_dynamic at jump land
					XJump_small(JAlways,jskip);
					patch_jump(ctx,jnz);
				}
				call_native_consts(ctx, hl_alloc_dynamic, &rt, 1);
				// copy value to dynamic
				if( (IS_FLOAT(ra) || ra->size == 8) && !IS_64 ) {
					preg *tmp = REG_AT(RCPU_SCRATCH_REGS[1]);
					op64(ctx,MOV,tmp,&ra->stack);
					op32(ctx,MOV,pmem(&p,Eax,HDYN_VALUE),tmp);
					if( ra->t->kind == HF64 ) {
						ra->stackPos += 4;
						op64(ctx,MOV,tmp,&ra->stack);
						op32(ctx,MOV,pmem(&p,Eax,HDYN_VALUE+4),tmp);
						ra->stackPos -= 4;
					}
				} else {
					preg *tmp = REG_AT(RCPU_SCRATCH_REGS[1]);
					copy_from(ctx,tmp,ra);
					op64(ctx,MOV,pmem(&p,Eax,HDYN_VALUE),tmp);
				}
				if( hl_is_ptr(ra->t) ) patch_jump(ctx,jskip);
				store(ctx, dst, PEAX, true);
			}
			break;
		case OToSFloat:
			if( ra == dst ) break;
			if( ra->t->kind == HI32 ) {
				preg *r = alloc_cpu(ctx,ra,true);
				preg *w = alloc_fpu(ctx,dst,false);
				op32(ctx,dst->t->kind == HF64 ? CVTSI2SD : CVTSI2SS,w,r);
				store(ctx, dst, w, true);
			} else if( ra->t->kind == HF64 && dst->t->kind == HF32 ) {
				preg *r = alloc_fpu(ctx,ra,true);
				preg *w = alloc_fpu(ctx,dst,false);
				op32(ctx,CVTSD2SS,w,r);
				store(ctx, dst, w, true);
			} else if( ra->t->kind == HF32 && dst->t->kind == HF64 ) {
				preg *r = alloc_fpu(ctx,ra,true);
				preg *w = alloc_fpu(ctx,dst,false);
				op32(ctx,CVTSS2SD,w,r);
				store(ctx, dst, w, true);
			} else
				ASSERT(0);
			break;
		case OToUFloat:
			{
				int size;
				size = prepare_call_args(ctx,1,&o->p2,ctx->vregs,0);
				call_native(ctx,uint_to_double,size);
				store_result(ctx,dst);
			}
			break;
		case OToInt:
			if( ra == dst ) break;
			if( ra->t->kind == HF64 ) {
				preg *r = alloc_fpu(ctx,ra,true);
				preg *w = alloc_cpu(ctx,dst,false);
				preg *tmp = alloc_reg(ctx,RCPU);
				op32(ctx,STMXCSR,pmem(&p,Esp,-4),UNUSED);
				op32(ctx,MOV,tmp,&p);
				op32(ctx,OR,tmp,pconst(&p,0x6000)); // set round towards 0
				op32(ctx,MOV,pmem(&p,Esp,-8),tmp);
				op32(ctx,LDMXCSR,&p,UNUSED);
				op32(ctx,CVTSD2SI,w,r);
				op32(ctx,LDMXCSR,pmem(&p,Esp,-4),UNUSED);
				store(ctx, dst, w, true);
			} else if (ra->t->kind == HF32) {
				preg *r = alloc_fpu(ctx, ra, true);
				preg *w = alloc_cpu(ctx, dst, false);
				preg *tmp = alloc_reg(ctx, RCPU);
				op32(ctx, STMXCSR, pmem(&p, Esp, -4), UNUSED);
				op32(ctx, MOV, tmp, &p);
				op32(ctx, OR, tmp, pconst(&p, 0x6000)); // set round towards 0
				op32(ctx, MOV, pmem(&p, Esp, -4), tmp);
				op32(ctx, LDMXCSR, &p, UNUSED);
				op32(ctx, CVTSS2SI, w, r);
				op32(ctx, LDMXCSR, pmem(&p, Esp, -4), UNUSED);
				store(ctx, dst, w, true);
			} else if( dst->t->kind == HI64 && ra->t->kind == HI32 ) {
				ASSERT(0); // todo : more i64 native support
			} else {
				preg *r = alloc_cpu(ctx,dst,false);
				copy_from(ctx, r, ra);
				store(ctx, dst, r, true);
			}
			break;
		case ORet:
			op_ret(ctx, dst);
			break;
		case OIncr:
			{
				if( IS_FLOAT(dst) ) {
					ASSERT(0);
				} else {
					preg *v = fetch32(ctx,dst);
					op32(ctx,INC,v,UNUSED);
					if( v->kind != RSTACK ) store(ctx, dst, v, false);
				}
			}
			break;
		case ODecr:
			{
				if( IS_FLOAT(dst) ) {
					ASSERT(0);
				} else {
					preg *v = fetch32(ctx,dst);
					op32(ctx,DEC,v,UNUSED);
					if( v->kind != RSTACK ) store(ctx, dst, v, false);
				}
			}
			break;
		case OFloat:
			{
				if( m->code->floats[o->p2] == 0 ) {
					preg *f = alloc_fpu(ctx,dst,false);
					op64(ctx,XORPD,f,f);
				} else switch( dst->t->kind ) {
				case HF64:
				case HF32:
#					ifdef HL_64
					op64(ctx,dst->t->kind == HF32 ? MOVSS : MOVSD,alloc_fpu(ctx,dst,false),pcodeaddr(&p,o->p2 * 8));
#					else
					op64(ctx,dst->t->kind == HF32 ? MOVSS : MOVSD,alloc_fpu(ctx,dst,false),paddr(&p,m->code->floats + o->p2));
#					endif
					break;
				default:
					ASSERT(dst->t->kind);
				}
				store(ctx,dst,dst->current,false);
			}
			break;
		case OString:
			op64(ctx,MOV,alloc_cpu(ctx, dst, false),pconst64(&p,(int_val)hl_get_ustring(m->code,o->p2)));
			store(ctx,dst,dst->current,false);
			break;
		case OBytes:
			{
				char *b = m->code->version >= 5 ? m->code->bytes + m->code->bytes_pos[o->p2] : m->code->strings[o->p2];
				op64(ctx,MOV,alloc_cpu(ctx,dst,false),pconst64(&p,(int_val)b));
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
			{
				int_val args[] = { (int_val)dst->t };
				void *allocFun;
				int nargs = 1;
				switch( dst->t->kind ) {
				case HOBJ:
				case HSTRUCT:
					allocFun = hl_alloc_obj;
					break;
				case HDYNOBJ:
					allocFun = hl_alloc_dynobj;
					nargs = 0;
					break;
				case HVIRTUAL:
					allocFun = hl_alloc_virtual;
					break;
				default:
					ASSERT(dst->t->kind);
				}
				call_native_consts(ctx, allocFun, args, nargs);
				store(ctx, dst, PEAX, true);
			}
			break;
		case OInstanceClosure:
			{
				preg *r = alloc_cpu(ctx, rb, true);
				jlist *j = (jlist*)hl_malloc(&ctx->galloc,sizeof(jlist));
				int size = begin_native_call(ctx,3);
				set_native_arg(ctx,r);

				j->pos = BUF_POS();
				j->target = o->p2;
				j->next = ctx->calls;
				ctx->calls = j;

				set_native_arg(ctx,pconst64(&p,RESERVE_ADDRESS));
				set_native_arg(ctx,pconst64(&p,(int_val)m->code->functions[m->functions_indexes[o->p2]].type));				
				call_native(ctx,hl_alloc_closure_ptr,size);
				store(ctx,dst,PEAX,true);
			}
			break;
		case OVirtualClosure:
			{
				int size, i;
				preg *r = alloc_cpu_call(ctx, ra);
				hl_type *t = NULL;
				hl_type *ot = ra->t;
				while( t == NULL ) {
					for(i=0;i<ot->obj->nproto;i++) {
						hl_obj_proto *pp = ot->obj->proto + i;
						if( pp->pindex == o->p3 ) {
							t = m->code->functions[m->functions_indexes[pp->findex]].type;
							break;
						}
					}
					ot = ot->obj->super;
				}
				size = begin_native_call(ctx,3);
				set_native_arg(ctx,r);
				// read r->type->vobj_proto[i] for function address
				op64(ctx,MOV,r,pmem(&p,r->id,0));
				op64(ctx,MOV,r,pmem(&p,r->id,HL_WSIZE*2));
				op64(ctx,MOV,r,pmem(&p,r->id,HL_WSIZE*o->p3));
				set_native_arg(ctx,r);
				op64(ctx,MOV,r,pconst64(&p,(int_val)t));
				set_native_arg(ctx,r);
				call_native(ctx,hl_alloc_closure_ptr,size);
				store(ctx,dst,PEAX,true);
			}
			break;
		case OCallClosure:
			if( ra->t->kind == HDYN ) {
				// ASM for {
				//	vdynamic *args[] = {args};
				//  vdynamic *ret = hl_dyn_call(closure,args,nargs);
				//  dst = hl_dyncast(ret,t_dynamic,t_dst);
				// }
				int offset = o->p3 * HL_WSIZE;
				preg *r = alloc_reg(ctx, RCPU_CALL);
				if( offset & 15 ) offset += 16 - (offset & 15);
				op64(ctx,SUB,PESP,pconst(&p,offset));
				op64(ctx,MOV,r,PESP);
				for(i=0;i<o->p3;i++) {
					vreg *a = R(o->extra[i]);
					if( !hl_is_dynamic(a->t) ) ASSERT(0);
					preg *v = alloc_cpu(ctx,a,true);
					op64(ctx,MOV,pmem(&p,r->id,i * HL_WSIZE),v);
					RUNLOCK(v);
				}
#				ifdef HL_64
				int size = begin_native_call(ctx, 3) + offset;
				set_native_arg(ctx, pconst(&p,o->p3));
				set_native_arg(ctx, r);
				set_native_arg(ctx, fetch(ra));
#				else
				int size = pad_before_call(ctx,HL_WSIZE*2 + sizeof(int) + offset);
				op64(ctx,PUSH,pconst(&p,o->p3),UNUSED);
				op64(ctx,PUSH,r,UNUSED);
				op64(ctx,PUSH,alloc_cpu(ctx,ra,true),UNUSED);
#				endif
				call_native(ctx,hl_dyn_call,size);
				if( dst->t->kind != HVOID ) {
					store(ctx,dst,PEAX,true);
					make_dyn_cast(ctx,dst,dst);
				}
			} else {
				int jhasvalue, jend, size;
				// ASM for  if( c->hasValue ) c->fun(value,args) else c->fun(args)
				preg *r = alloc_cpu(ctx,ra,true);
				preg *tmp = alloc_reg(ctx, RCPU);
				op32(ctx,MOV,tmp,pmem(&p,r->id,HL_WSIZE*2));
				op32(ctx,TEST,tmp,tmp);
				scratch(tmp);
				XJump_small(JNotZero,jhasvalue);
				save_regs(ctx);
				size = prepare_call_args(ctx,o->p3,o->extra,ctx->vregs,0);
				preg *rr = r;
				if( rr->holds != ra ) rr = alloc_cpu(ctx, ra, true);
				op_call(ctx, pmem(&p,rr->id,HL_WSIZE), size);
				XJump_small(JAlways,jend);
				patch_jump(ctx,jhasvalue);
				restore_regs(ctx);
#				ifdef HL_64
				{
					int regids[64];
					preg *pc = REG_AT(CALL_REGS[0]);
					vreg *sc = R(f->nregs); // scratch register that we temporary rebind					
					if( o->p3 >= 63 ) jit_error("assert");
					memcpy(regids + 1, o->extra, o->p3 * sizeof(int));
					regids[0] = f->nregs;
					sc->size = HL_WSIZE;
					sc->t = &hlt_dyn;
					op64(ctx, MOV, pc, pmem(&p,r->id,HL_WSIZE*3));
					scratch(pc);
					sc->current = pc;
					pc->holds = sc;
					size = prepare_call_args(ctx,o->p3 + 1,regids,ctx->vregs,0);
					if( r->holds != ra ) r = alloc_cpu(ctx, ra, true);
				}
#				else
				size = prepare_call_args(ctx,o->p3,o->extra,ctx->vregs,HL_WSIZE);
				if( r->holds != ra ) r = alloc_cpu(ctx, ra, true);
				op64(ctx, PUSH,pmem(&p,r->id,HL_WSIZE*3),UNUSED); // push closure value
#				endif
				op_call(ctx, pmem(&p,r->id,HL_WSIZE), size);
				discard_regs(ctx,false);
				patch_jump(ctx,jend);
				store_result(ctx, dst);
			}
			break;
		case OStaticClosure:
			{
				vclosure *c = alloc_static_closure(ctx,o->p2);
				preg *r = alloc_reg(ctx, RCPU);
				op64(ctx, MOV, r, pconst64(&p,(int_val)c));
				store(ctx,dst,r,true);
			}
			break;
		case OField:
			{
				switch( ra->t->kind ) {
				case HOBJ:
				case HSTRUCT:
					{
						hl_runtime_obj *rt = hl_get_obj_rt(ra->t);
						preg *rr = alloc_cpu(ctx,ra, true);
						copy_to(ctx,dst,pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p3]));
					}
					break;
				case HVIRTUAL:
					// ASM for --> if( hl_vfields(o)[f] ) r = *hl_vfields(o)[f]; else r = hl_dyn_get(o,hash(field),vt)
					{
						int jhasfield, jend, size;
						preg *v = alloc_cpu_call(ctx,ra);
						preg *r = alloc_reg(ctx,RCPU);
						op64(ctx,MOV,r,pmem(&p,v->id,sizeof(vvirtual)+HL_WSIZE*o->p3));
						op64(ctx,TEST,r,r);
						XJump_small(JNotZero,jhasfield);
						size = begin_native_call(ctx, 3);
						set_native_arg(ctx,pconst64(&p,(int_val)dst->t));
						set_native_arg(ctx,pconst64(&p,(int_val)ra->t->virt->fields[o->p3].hashed_name));
						set_native_arg(ctx,v);
						call_native(ctx,get_dynget(dst->t),size);
						store_result(ctx,dst);
						XJump_small(JAlways,jend);
						patch_jump(ctx,jhasfield);
						copy_to(ctx, dst, pmem(&p,(CpuReg)r->id,0));
						patch_jump(ctx,jend);
						scratch(dst->current);
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
				case HSTRUCT:
					{
						hl_runtime_obj *rt = hl_get_obj_rt(dst->t);
						preg *rr = alloc_cpu(ctx, dst, true);
						copy_from(ctx, pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p2]), rb);
					}
					break;
				case HVIRTUAL:
					// ASM for --> if( hl_vfields(o)[f] ) *hl_vfields(o)[f] = v; else hl_dyn_set(o,hash(field),vt,v)
					{
						int jhasfield, jend;
						preg *obj = alloc_cpu_call(ctx,dst);
						preg *r = alloc_reg(ctx,RCPU);
						op64(ctx,MOV,r,pmem(&p,obj->id,sizeof(vvirtual)+HL_WSIZE*o->p2));
						op64(ctx,TEST,r,r);
						XJump_small(JNotZero,jhasfield);
#						ifdef HL_64
						switch( rb->t->kind ) {
						case HF64:
						case HF32:
							size = begin_native_call(ctx,3);
							set_native_arg_fpu(ctx, fetch(rb), rb->t->kind == HF32);
							break;
						default:
							size = begin_native_call(ctx, 4);
							set_native_arg(ctx, fetch(rb));
							set_native_arg(ctx, pconst64(&p,(int_val)rb->t));
							break;
						}
						set_native_arg(ctx,pconst(&p,dst->t->virt->fields[o->p2].hashed_name));
						set_native_arg(ctx,obj);
#						else
						switch( rb->t->kind ) {
						case HF64:
							size = pad_before_call(ctx,HL_WSIZE*2 + sizeof(double));
							push_reg(ctx,rb);
							break;
						case HF32:
							size = pad_before_call(ctx,HL_WSIZE*2 + sizeof(float));
							push_reg(ctx,rb);
							break;
						default:
							size = pad_before_call(ctx,HL_WSIZE*4);
							op64(ctx,PUSH,fetch32(ctx,rb),UNUSED);
							op64(ctx,MOV,r,pconst64(&p,(int_val)rb->t));
							op64(ctx,PUSH,r,UNUSED);
							break;
						}
						op32(ctx,MOV,r,pconst(&p,dst->t->virt->fields[o->p2].hashed_name));
						op64(ctx,PUSH,r,UNUSED);
						op64(ctx,PUSH,obj,UNUSED);
#						endif
						call_native(ctx,get_dynset(rb->t),size);
						XJump_small(JAlways,jend);
						patch_jump(ctx,jhasfield);
						copy_from(ctx, pmem(&p,(CpuReg)r->id,0), rb);
						patch_jump(ctx,jend);
						scratch(rb->current);
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
				hl_runtime_obj *rt = hl_get_obj_rt(r->t);
				preg *rr = alloc_cpu(ctx,r, true);
				copy_to(ctx,dst,pmem(&p, (CpuReg)rr->id, rt->fields_indexes[o->p2]));
			}
			break;
		case OSetThis:
			{
				vreg *r = R(0);
				hl_runtime_obj *rt = hl_get_obj_rt(r->t);
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
				tmp = alloc_reg(ctx, RCPU_CALL);
				op64(ctx,MOV,tmp,pmem(&p,r->id,0)); // read type
				op64(ctx,MOV,tmp,pmem(&p,tmp->id,HL_WSIZE*2)); // read proto
				args[0] = 0;
				for(i=1;i<nargs;i++)
					args[i] = o->extra[i-1];
				size = prepare_call_args(ctx,nargs,args,ctx->vregs,0);
				op_call(ctx,pmem(&p,tmp->id,o->p2*HL_WSIZE),size);
				discard_regs(ctx, false);
				store_result(ctx, dst);
			}
			break;
		case OCallMethod:
			switch( R(o->extra[0])->t->kind ) {
			case HOBJ: {
				int size;
				preg *r = alloc_cpu(ctx, R(o->extra[0]), true);
				preg *tmp;
				tmp = alloc_reg(ctx, RCPU_CALL);
				op64(ctx,MOV,tmp,pmem(&p,r->id,0)); // read type
				op64(ctx,MOV,tmp,pmem(&p,tmp->id,HL_WSIZE*2)); // read proto
				size = prepare_call_args(ctx,o->p3,o->extra,ctx->vregs,0);
				op_call(ctx,pmem(&p,tmp->id,o->p2*HL_WSIZE),size);
				discard_regs(ctx, false);
				store_result(ctx, dst);
				break;
			}
			case HVIRTUAL:
				// ASM for --> if( hl_vfields(o)[f] ) dst = *hl_vfields(o)[f](o->value,args...); else dst = hl_dyn_call_obj(o->value,field,args,&ret)
				{
					int size;
					int paramsSize;
					int jhasfield, jend;
					bool need_dyn;
					vreg *obj = R(o->extra[0]);
					preg *v = alloc_cpu_call(ctx,obj);
					preg *r = alloc_reg(ctx,RCPU_CALL);
					op64(ctx,MOV,r,pmem(&p,v->id,sizeof(vvirtual)+HL_WSIZE*o->p2));
					op64(ctx,TEST,r,r);
					save_regs(ctx);

					if( o->p3 < 7 ) {
						XJump_small(JNotZero,jhasfield);
					} else {
						XJump(JNotZero,jhasfield);
					}

					need_dyn = !hl_is_ptr(dst->t) && dst->t->kind != HVOID;
					paramsSize = (o->p3 - 1) * HL_WSIZE;
					if( need_dyn ) paramsSize += sizeof(vdynamic);
					if( paramsSize & 15 ) paramsSize += 16 - (paramsSize&15);
					op64(ctx,SUB,PESP,pconst(&p,paramsSize));
					op64(ctx,MOV,r,PESP);

					for(i=0;i<o->p3-1;i++) {
						vreg *a = R(o->extra[i+1]);
						if( hl_is_ptr(a->t) ) {
							op64(ctx,MOV,pmem(&p,r->id,i*HL_WSIZE),alloc_cpu(ctx,a,true));
							if( a->current != v ) RUNLOCK(a->current);
						} else {
							preg *r2 = alloc_reg(ctx,RCPU);
							op64(ctx,LEA,r2,&a->stack);
							op64(ctx,MOV,pmem(&p,r->id,i*HL_WSIZE),r2);
							if( r2 != v ) RUNLOCK(r2);
						}
					}

					jit_buf(ctx);

					if( !need_dyn ) {
						size = begin_native_call(ctx, 5);
						set_native_arg(ctx, pconst(&p,0));
					} else {
						preg *rtmp = alloc_reg(ctx,RCPU);
						op64(ctx,LEA,rtmp,pmem(&p,Esp,paramsSize - sizeof(vdynamic)));
						size = begin_native_call(ctx, 5);
						set_native_arg(ctx,rtmp);
						if( !IS_64 ) RUNLOCK(rtmp);
					}
					set_native_arg(ctx,r);
					set_native_arg(ctx,pconst(&p,obj->t->virt->fields[o->p2].hashed_name)); // fid
					set_native_arg(ctx,pconst64(&p,(int_val)obj->t->virt->fields[o->p2].t)); // ftype
					set_native_arg(ctx,pmem(&p,v->id,HL_WSIZE)); // o->value
					call_native(ctx,hl_dyn_call_obj,size + paramsSize);
					if( need_dyn ) {
						preg *r = IS_FLOAT(dst) ? REG_AT(XMM(0)) : PEAX;
						copy(ctx,r,pmem(&p,Esp,HDYN_VALUE - (int)sizeof(vdynamic)),dst->size);
						store(ctx, dst, r, false);
					} else
						store(ctx, dst, PEAX, false);

					XJump_small(JAlways,jend);
					patch_jump(ctx,jhasfield);
					restore_regs(ctx);

					/*
						o = o->value hack
					*/
					if( v->holds ) v->holds->current = NULL;
					obj->current = v;
					v->holds = obj;
					op64(ctx,MOV,v,pmem(&p,v->id,HL_WSIZE));

					size = prepare_call_args(ctx,o->p3,o->extra,ctx->vregs,0);
					op_call(ctx,r,size);
					discard_regs(ctx, false);
					store_result(ctx, dst);
					patch_jump(ctx,jend);
				}
				break;
			default:
				ASSERT(0);
				break;
			}
			break;
		case ORethrow:
			{
				int size = prepare_call_args(ctx,1,&o->p1,ctx->vregs,0);
				call_native(ctx,hl_rethrow,size);
			}
			break;
		case OThrow:
			{
				int size = prepare_call_args(ctx,1,&o->p1,ctx->vregs,0);
				call_native(ctx,hl_throw,size);
			}
			break;
		case OLabel:
			// NOP for now
			discard_regs(ctx,false);
			break;
		case OGetI8:
		case OGetI16:
			{
				preg *base = alloc_cpu(ctx, ra, true);
				preg *offset = alloc_cpu64(ctx, rb, true);
				preg *r = alloc_reg(ctx,o->op == OGetI8 ? RCPU_8BITS : RCPU);
				op64(ctx,XOR,r,r);
				op32(ctx, o->op == OGetI8 ? MOV8 : MOV16,r,pmem2(&p,base->id,offset->id,1,0));
				store(ctx, dst, r, true);
			}
			break;
		case OGetMem:
			{
				preg *base = alloc_cpu(ctx, ra, true);
				preg *offset = alloc_cpu64(ctx, rb, true);
				store(ctx, dst, pmem2(&p,base->id,offset->id,1,0), false);
			}
			break;
		case OSetI8:
			{
				preg *base = alloc_cpu(ctx, dst, true);
				preg *offset = alloc_cpu64(ctx, ra, true);
				preg *value = alloc_cpu8(ctx, rb, true);
				op32(ctx,MOV8,pmem2(&p,base->id,offset->id,1,0),value);
			}
			break;
		case OSetI16:
			{
				preg *base = alloc_cpu(ctx, dst, true);
				preg *offset = alloc_cpu64(ctx, ra, true);
				preg *value = alloc_cpu(ctx, rb, true);
				op32(ctx,MOV16,pmem2(&p,base->id,offset->id,1,0),value);
			}
			break;
		case OSetMem:
			{
				preg *base = alloc_cpu(ctx, dst, true);
				preg *offset = alloc_cpu64(ctx, ra, true);
				preg *value;
				switch( rb->t->kind ) {
				case HI32:
					value = alloc_cpu(ctx, rb, true);
					op32(ctx,MOV,pmem2(&p,base->id,offset->id,1,0),value);
					break;
				case HF32:
					value = alloc_fpu(ctx, rb, true);
					op32(ctx,MOVSS,pmem2(&p,base->id,offset->id,1,0),value);
					break;
				case HF64:
					value = alloc_fpu(ctx, rb, true);
					op32(ctx,MOVSD,pmem2(&p,base->id,offset->id,1,0),value);
					break;
				default:
					ASSERT(rb->t->kind);
					break;
				}
			}
			break;
		case OType:
			{
				op64(ctx,MOV,alloc_cpu(ctx, dst, false),pconst64(&p,(int_val)(m->code->types + o->p2)));
				store(ctx,dst,dst->current,false);
			}
			break;
		case OGetType:
			{
				int jnext, jend;
				preg *r = alloc_cpu(ctx, ra, true);
				preg *tmp = alloc_reg(ctx, RCPU);
				op64(ctx,TEST,r,r);
				XJump_small(JNotZero,jnext);
				op64(ctx,MOV, tmp, pconst64(&p,(int_val)&hlt_void));
				XJump_small(JAlways,jend);
				patch_jump(ctx,jnext);
				op64(ctx, MOV, tmp, pmem(&p,r->id,0));
				patch_jump(ctx,jend);
				store(ctx,dst,tmp,true);
			}
			break;
		case OGetArray:
			{
				preg *rdst = IS_FLOAT(dst) ? alloc_fpu(ctx,dst,false) : alloc_cpu(ctx,dst,false);
				copy(ctx, rdst, pmem2(&p,alloc_cpu(ctx,ra,true)->id,alloc_cpu64(ctx,rb,true)->id,hl_type_size(dst->t),sizeof(varray)), dst->size);
				store(ctx,dst,dst->current,false);
			}
			break;
		case OSetArray:
			{
				preg *rrb = IS_FLOAT(rb) ? alloc_fpu(ctx,rb,true) : alloc_cpu(ctx,rb,true);
				copy(ctx, pmem2(&p,alloc_cpu(ctx,dst,true)->id,alloc_cpu64(ctx,ra,true)->id,hl_type_size(rb->t),sizeof(varray)), rrb, rb->size);
			}
			break;
		case OArraySize:
			{
				op32(ctx,MOV,alloc_cpu(ctx,dst,false),pmem(&p,alloc_cpu(ctx,ra,true)->id,HL_WSIZE*2));
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
		case OUnref:
			copy_to(ctx,dst,pmem(&p,alloc_cpu(ctx,ra,true)->id,0));
			break;
		case OSetref:
			copy_from(ctx,pmem(&p,alloc_cpu(ctx,dst,true)->id,0),ra);
			break;
		case ORefData:
			switch( ra->t->kind ) {
			case HARRAY:
				{
					preg *r = fetch(ra);
					preg *d = alloc_cpu(ctx,dst,false);
					op64(ctx,MOV,d,r);
					op64(ctx,ADD,d,pconst(&p,sizeof(varray)));
					store(ctx,dst,dst->current,false);
				}
				break;
			default:
				ASSERT(ra->t->kind);
			}
			break;
		case ORefOffset:
			{
				preg *d = alloc_cpu(ctx,rb,true);
				preg *r2 = alloc_cpu(ctx,dst,false);
				preg *r = fetch(ra);
				int size = hl_type_size(dst->t->tparam);
				op64(ctx,MOV,r2,r);
				switch( size ) {
				case 1:
					break;
				case 2:
					op64(ctx,SHL,d,pconst(&p,1));
					break;
				case 4:
					op64(ctx,SHL,d,pconst(&p,2));
					break;
				case 8:
					op64(ctx,SHL,d,pconst(&p,3));
					break;
				default:
					op64(ctx,IMUL,d,pconst(&p,size));
					break;
				}
				op64(ctx,ADD,r2,d);
				scratch(d);
				store(ctx,dst,dst->current,false);
			}
			break;
		case OToVirtual:
			{
#				ifdef HL_64
				int size = pad_before_call(ctx, 0);
				op64(ctx,MOV,REG_AT(CALL_REGS[1]),fetch(ra));
				op64(ctx,MOV,REG_AT(CALL_REGS[0]),pconst64(&p,(int_val)dst->t));
#				else
				int size = pad_before_call(ctx, HL_WSIZE*2);
				op32(ctx,PUSH,fetch(ra),UNUSED);
				op32(ctx,PUSH,pconst(&p,(int)(int_val)dst->t),UNUSED);
#				endif
				if( ra->t->kind == HOBJ ) hl_get_obj_rt(ra->t); // ensure it's initialized
				call_native(ctx,hl_to_virtual,size);
				store(ctx,dst,PEAX,true);
			}
			break;
		case OMakeEnum:
			{
				hl_enum_construct *c = &dst->t->tenum->constructs[o->p2];
				int_val args[] = { (int_val)dst->t, o->p2 };
				int i;
				call_native_consts(ctx, hl_alloc_enum, args, 2);
				RLOCK(PEAX);
				for(i=0;i<c->nparams;i++) {
					preg *r = fetch(R(o->extra[i]));
					copy(ctx, pmem(&p,Eax,c->offsets[i]),r, R(o->extra[i])->size);
					RUNLOCK(fetch(R(o->extra[i])));
					if ((i & 15) == 0) jit_buf(ctx);
				}
				store(ctx, dst, PEAX, true);
			}
			break;
		case OEnumAlloc:
			{
				int_val args[] = { (int_val)dst->t, o->p2 };
				call_native_consts(ctx, hl_alloc_enum, args, 2);
				store(ctx, dst, PEAX, true);
			}
			break;
		case OEnumField:
			{
				hl_enum_construct *c = &ra->t->tenum->constructs[o->p3];
				preg *r = alloc_cpu(ctx,ra,true);
				copy_to(ctx,dst,pmem(&p,r->id,c->offsets[(int)(int_val)o->extra]));
			}
			break;
		case OSetEnumField:
			{
				hl_enum_construct *c = &dst->t->tenum->constructs[0];
				preg *r = alloc_cpu(ctx,dst,true);
				switch( rb->t->kind ) {
				case HF64:
					{
						preg *d = alloc_fpu(ctx,rb,true);
						copy(ctx,pmem(&p,r->id,c->offsets[o->p2]),d,8);
						break;
					}
				default:
					copy(ctx,pmem(&p,r->id,c->offsets[o->p2]),alloc_cpu(ctx,rb,true),hl_type_size(c->params[o->p2]));
					break;
				}
			}
			break;
		case ONullCheck:
			{
				int jz;
				preg *r = alloc_cpu(ctx,dst,true);
				op64(ctx,TEST,r,r);
				XJump_small(JNotZero,jz);
				pad_before_call(ctx, 0);

				jlist *j = (jlist*)hl_malloc(&ctx->galloc,sizeof(jlist));
				j->pos = BUF_POS();
				j->target = -1;
				j->next = ctx->calls;
				ctx->calls = j;

				op64(ctx,MOV,PEAX,pconst64(&p,RESERVE_ADDRESS));
				op_call(ctx,PEAX,-1);
				patch_jump(ctx,jz);
			}
			break;
		case OSafeCast:
			make_dyn_cast(ctx, dst, ra);
			break;
		case ODynGet:
			{
				int size;
#				ifdef HL_64
				if( IS_FLOAT(dst) ) {
					size = begin_native_call(ctx,2);
				} else {
					size = begin_native_call(ctx,3);
					set_native_arg(ctx,pconst64(&p,(int_val)dst->t));
				}
				set_native_arg(ctx,pconst64(&p,(int_val)hl_hash_utf8(m->code->strings[o->p3])));
				set_native_arg(ctx,fetch(ra));
#				else
				preg *r;
				r = alloc_reg(ctx,RCPU);
				if( IS_FLOAT(dst) ) {
					size = pad_before_call(ctx,HL_WSIZE*2);
				} else {
					size = pad_before_call(ctx,HL_WSIZE*3);
					op64(ctx,MOV,r,pconst64(&p,(int_val)dst->t));
					op64(ctx,PUSH,r,UNUSED);
				}
				op64(ctx,MOV,r,pconst64(&p,(int_val)hl_hash_utf8(m->code->strings[o->p3])));
				op64(ctx,PUSH,r,UNUSED);
				op64(ctx,PUSH,fetch(ra),UNUSED);
#				endif
				call_native(ctx,get_dynget(dst->t),size);
				store_result(ctx,dst);
			}
			break;
		case ODynSet:
			{
				int size;
#				ifdef HL_64
				switch( rb->t->kind ) {
				case HF32:
				case HF64:
					size = begin_native_call(ctx, 3);
					set_native_arg_fpu(ctx,fetch(rb),rb->t->kind == HF32);
					set_native_arg(ctx,pconst64(&p,hl_hash_gen(hl_get_ustring(m->code,o->p2),true)));
					set_native_arg(ctx,fetch(dst));
					call_native(ctx,get_dynset(rb->t),size);
					break;
				default:
					size = begin_native_call(ctx,4);
					set_native_arg(ctx,fetch(rb));
					set_native_arg(ctx,pconst64(&p,(int_val)rb->t));
					set_native_arg(ctx,pconst64(&p,hl_hash_gen(hl_get_ustring(m->code,o->p2),true)));
					set_native_arg(ctx,fetch(dst));
					call_native(ctx,get_dynset(rb->t),size);
					break;
				}
#				else
				switch( rb->t->kind ) {
				case HF32:
					size = pad_before_call(ctx, HL_WSIZE*2 + sizeof(float));
					push_reg(ctx,rb);
					op32(ctx,PUSH,pconst64(&p,hl_hash_gen(hl_get_ustring(m->code,o->p2),true)),UNUSED);
					op32(ctx,PUSH,fetch(dst),UNUSED);
					call_native(ctx,get_dynset(rb->t),size);
					break;
				case HF64:
					size = pad_before_call(ctx, HL_WSIZE*2 + sizeof(double));
					push_reg(ctx,rb);
					op32(ctx,PUSH,pconst64(&p,hl_hash_gen(hl_get_ustring(m->code,o->p2),true)),UNUSED);
					op32(ctx,PUSH,fetch(dst),UNUSED);
					call_native(ctx,get_dynset(rb->t),size);
					break;
				default:
					size = pad_before_call(ctx, HL_WSIZE*4);
					op32(ctx,PUSH,fetch32(ctx,rb),UNUSED);
					op32(ctx,PUSH,pconst64(&p,(int_val)rb->t),UNUSED);
					op32(ctx,PUSH,pconst64(&p,hl_hash_gen(hl_get_ustring(m->code,o->p2),true)),UNUSED);
					op32(ctx,PUSH,fetch(dst),UNUSED);
					call_native(ctx,get_dynset(rb->t),size);
					break;
				}
#				endif
			}
			break;
		case OTrap:
			{
				int size, jenter, jtrap;
				int offset = 0;
				int trap_size = (sizeof(hl_trap_ctx) + 15) & 0xFFF0;
				hl_trap_ctx *t = NULL;
#				ifndef HL_THREADS
				if( tinf == NULL ) tinf = hl_get_thread(); // single thread
#				endif

#				ifdef HL_64
				preg *trap = REG_AT(CALL_REGS[0]);
#				else
				preg *trap = PEAX;
#				endif
				RLOCK(trap);

				preg *treg = alloc_reg(ctx, RCPU);
				if( !tinf ) {
					call_native(ctx, hl_get_thread, 0);
					op64(ctx,MOV,treg,PEAX);
					offset = (int)(int_val)&tinf->trap_current;
				} else {
					offset = 0;
					op64(ctx,MOV,treg,pconst64(&p,(int_val)&tinf->trap_current));
				}
				op64(ctx,MOV,trap,pmem(&p,treg->id,offset));
				op64(ctx,SUB,PESP,pconst(&p,trap_size));
				op64(ctx,MOV,pmem(&p,Esp,(int)(int_val)&t->prev),trap);
				op64(ctx,MOV,trap,PESP);
				op64(ctx,MOV,pmem(&p,treg->id,offset),trap);

				/*
					This is a bit hackshish : we want to detect the type of exception filtered by the catch so we check the following
					sequence of HL opcodes:

					trap E,@catch
					...
					@catch:
					global R, _
					call _, ???(R,E)

					??? is expected to be hl.BaseType.check
				*/
				hl_opcode *next = f->ops + opCount + 1 + o->p2;
				hl_opcode *next2 = f->ops + opCount + 2 + o->p2;
				if( next->op == OGetGlobal && next2->op == OCall2 && next2->p3 == next->p1 && dst->stack.id == (int)(int_val)next2->extra ) {
					hl_type *gt = m->code->globals[next->p2];
					while( gt->kind == HOBJ && gt->obj->super ) gt = gt->obj->super;
					if( gt->kind == HOBJ && gt->obj->nfields && gt->obj->fields[0].t->kind == HTYPE ) {
						void *addr = m->globals_data + m->globals_indexes[next->p2];
#						ifdef HL_64
						op64(ctx,MOV,treg,pconst64(&p,(int_val)addr));
						op64(ctx,MOV,treg,pmem(&p,treg->id,0));
#						else
						op64(ctx,MOV,treg,paddr(&p,addr));
#						endif
					} else
						op64(ctx,MOV,treg,pconst(&p,0));
				} else {
					op64(ctx,MOV,treg,pconst(&p,0));
				}
				op64(ctx,MOV,pmem(&p,Esp,(int)(int_val)&t->tcheck),treg);

				size = begin_native_call(ctx, 1);
				set_native_arg(ctx,trap);
				call_native(ctx,setjmp,size);
				op64(ctx,TEST,PEAX,PEAX);
				XJump_small(JZero,jenter);
				op64(ctx,ADD,PESP,pconst(&p,trap_size));
				if( !tinf ) {
					call_native(ctx, hl_get_thread, 0);
					op64(ctx,MOV,PEAX,pmem(&p, Eax, (int)(int_val)&tinf->exc_value));
				} else {
					op64(ctx,MOV,PEAX,pconst64(&p,(int_val)&tinf->exc_value));
					op64(ctx,MOV,PEAX,pmem(&p, Eax, 0));
				}
				store(ctx,dst,PEAX,false);

				jtrap = do_jump(ctx,OJAlways,false);
				register_jump(ctx,jtrap,(opCount + 1) + o->p2);
				patch_jump(ctx,jenter);
			}
			break;
		case OEndTrap:
			{
				int trap_size = (sizeof(hl_trap_ctx) + 15) & 0xFFF0;
				hl_trap_ctx *tmp = NULL;
				preg *addr,*r;
				int offset;
				if (!tinf) {
					call_native(ctx, hl_get_thread, 0);
					addr = PEAX;
					RLOCK(addr);
					offset = (int)(int_val)&tinf->trap_current;
				} else {
					offset = 0;
					addr = alloc_reg(ctx, RCPU);
					op64(ctx, MOV, addr, pconst64(&p, (int_val)&tinf->trap_current));
				}
				r = alloc_reg(ctx, RCPU);
				op64(ctx, MOV, r, pmem(&p,addr->id,offset));
				op64(ctx, MOV, r, pmem(&p,r->id,(int)(int_val)&tmp->prev));
				op64(ctx, MOV, pmem(&p,addr->id, offset), r);
#				ifdef HL_WIN
				// erase eip (prevent false positive)
				{
					_JUMP_BUFFER *b = NULL;
#					ifdef HL_64
					op64(ctx,MOV,pmem(&p,Esp,(int)(int_val)&(b->Rip)),PEAX);
#					else
					op64(ctx,MOV,pmem(&p,Esp,(int)&(b->Eip)),PEAX);
#					endif
				}
#				endif
				op64(ctx,ADD,PESP,pconst(&p,trap_size));
			}
			break;
		case OEnumIndex:
			{
				preg *r = alloc_reg(ctx,RCPU);
				op64(ctx,MOV,r,pmem(&p,alloc_cpu(ctx,ra,true)->id,HL_WSIZE));
				store(ctx,dst,r,true);
				break;
			}
			break;
		case OSwitch:
			{
				int jdefault;
				int i;
				preg *r = alloc_cpu(ctx, dst, true);
				preg *r2 = alloc_reg(ctx, RCPU);
				op32(ctx, CMP, r, pconst(&p,o->p2));
				XJump(JUGte,jdefault);
				// r2 = r * 5 + eip
#				ifdef HL_64
				op64(ctx, XOR, r2, r2);
#				endif
				op32(ctx, MOV, r2, r);
				op32(ctx, SHL, r2, pconst(&p,2));
				op32(ctx, ADD, r2, r);
#				ifdef HL_64
				preg *tmp = alloc_reg(ctx, RCPU);
				op64(ctx, MOV, tmp, pconst64(&p,RESERVE_ADDRESS));
#				else
				op64(ctx, ADD, r2, pconst64(&p,RESERVE_ADDRESS));
#				endif
				{
					jlist *s = (jlist*)hl_malloc(&ctx->galloc, sizeof(jlist));
					s->pos = BUF_POS() - sizeof(void*);
					s->next = ctx->switchs;
					ctx->switchs = s;
				}
#				ifdef HL_64
				op64(ctx, ADD, r2, tmp);
#				endif
				op64(ctx, JMP, r2, UNUSED);
				for(i=0;i<o->p2;i++) {
					int j = do_jump(ctx,OJAlways,false);
					register_jump(ctx,j,(opCount + 1) + o->extra[i]);
					if( (i & 15) == 0 ) jit_buf(ctx);
				}
				patch_jump(ctx, jdefault);
			}
			break;
		case OGetTID:
			op32(ctx, MOV, alloc_cpu(ctx,dst,false), pmem(&p,alloc_cpu(ctx,ra,true)->id,0));
			store(ctx,dst,dst->current,false);
			break;
		case OAssert:
			{
				jlist *j = (jlist*)hl_malloc(&ctx->galloc,sizeof(jlist));
				j->pos = BUF_POS();
				j->target = -1;
				j->next = ctx->calls;
				ctx->calls = j;

				op64(ctx,MOV,PEAX,pconst64(&p,RESERVE_ADDRESS));
				op_call(ctx,PEAX,-2);
			}
			break;
		case ONop:
			break;
		default:
			jit_error(hl_op_name(o->op));
			break;
		}
		// we are landing at this position, assume we have lost our registers
		if( ctx->opsPos[opCount+1] == -1 )
			discard_regs(ctx,true);
		ctx->opsPos[opCount+1] = BUF_POS();

		// write debug infos
		size = BUF_POS() - codePos;
		if( debug16 && size > 0xFF00 ) {
			debug32 = malloc(sizeof(int) * (f->nops + 1));
			for(i=0;i<ctx->currentPos;i++)
				debug32[i] = debug16[i];
			free(debug16);
			debug16 = NULL;
		}
		if( debug16 ) debug16[ctx->currentPos] = (unsigned short)size; else if( debug32 ) debug32[ctx->currentPos] = size;

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
	jit_nops(ctx);
	// clear regs
	for(i=0;i<REG_COUNT;i++) {
		preg *r = REG_AT(i);
		r->holds = NULL;
		r->lock = 0;
	}
	// save debug infos
	{
		int fid = (int)(f - m->code->functions);
		ctx->debug[fid].start = codePos;
		ctx->debug[fid].offsets = debug32 ? (void*)debug32 : (void*)debug16;
		ctx->debug[fid].large = debug32 != NULL;
	}
	// reset tmp allocator
	hl_free(&ctx->falloc);
	return codePos;
}

static void *get_wrapper( hl_type *t ) {
	return call_jit_hl2c;
}

void hl_jit_patch_method( void *old_fun, void **new_fun_table ) {
	// mov eax, addr
	// jmp [eax]
	unsigned char *b = (unsigned char*)old_fun;
	unsigned long long addr = (unsigned long long)(int_val)new_fun_table;
#	ifdef HL_64
	*b++ = 0x48;
	*b++ = 0xB8;
	*b++ = (unsigned char)addr;
	*b++ = (unsigned char)(addr>>8);
	*b++ = (unsigned char)(addr>>16);
	*b++ = (unsigned char)(addr>>24);
	*b++ = (unsigned char)(addr>>32);
	*b++ = (unsigned char)(addr>>40);
	*b++ = (unsigned char)(addr>>48);
	*b++ = (unsigned char)(addr>>56);
#	else
	*b++ = 0xB8;
	*b++ = (unsigned char)addr;
	*b++ = (unsigned char)(addr>>8);
	*b++ = (unsigned char)(addr>>16);
	*b++ = (unsigned char)(addr>>24);
#	endif
	*b++ = 0xFF;
	*b++ = 0x20;
}

void *hl_jit_code( jit_ctx *ctx, hl_module *m, int *codesize, hl_debug_infos **debug, hl_module *previous ) {
	jlist *c;
	int size = BUF_POS();
	unsigned char *code;
	if( size & 4095 ) size += 4096 - (size&4095);
	code = (unsigned char*)hl_alloc_executable_memory(size);
	if( code == NULL ) return NULL;
	memcpy(code,ctx->startBuf,BUF_POS());
	*codesize = size;
	*debug = ctx->debug;
	if( !call_jit_c2hl ) {
		call_jit_c2hl = code + ctx->c2hl;
		call_jit_hl2c = code + ctx->hl2c;
		hl_setup_callbacks2(callback_c2hl, get_wrapper, 1);
#		ifdef JIT_CUSTOM_LONGJUMP
		hl_setup_longjump(code + ctx->longjump);
#		endif
		int i;
		for(i=0;i<sizeof(ctx->static_functions)/sizeof(void*);i++)
			ctx->static_functions[i] = (void*)(code + (int)(int_val)ctx->static_functions[i]);
	}
	// patch calls
	c = ctx->calls;
	while( c ) {
		void *fabs;
		if( c->target < 0 )
			fabs = ctx->static_functions[-c->target-1];
		else {
			fabs = m->functions_ptrs[c->target];
			if( fabs == NULL ) {
				// read absolute address from previous module
				int old_idx = m->hash->functions_hashes[m->functions_indexes[c->target]];
				if( old_idx < 0 )
					return NULL;
				fabs = previous->functions_ptrs[(previous->code->functions + old_idx)->findex];
			} else {
				// relative
				fabs = (unsigned char*)code + (int)(int_val)fabs;
			}
		}
		if( (code[c->pos]&~3) == (IS_64?0x48:0xB8) || code[c->pos] == 0x68 ) // MOV : absolute | PUSH
			*(void**)(code + c->pos + (IS_64?2:1)) = fabs;
		else {
			int_val delta = (int_val)fabs - (int_val)code - (c->pos + 5);
			int rpos = (int)delta;
			if( (int_val)rpos != delta ) {
				printf("Target code too far too rebase\n");
				return NULL;
			}
			*(int*)(code + c->pos + 1) = rpos;
		}
		c = c->next;
	}
	// patch switchs
	c = ctx->switchs;
	while( c ) {
		*(void**)(code + c->pos) = code + c->pos + (IS_64 ? 14 : 6);
		c = c->next;
	}
	// patch closures
	{
		vclosure *c = ctx->closure_list;
		while( c ) {
			vclosure *next;
			int fidx = (int)(int_val)c->fun;
			void *fabs = m->functions_ptrs[fidx];
			if( fabs == NULL ) {
				// read absolute address from previous module
				int old_idx = m->hash->functions_hashes[m->functions_indexes[fidx]];
				if( old_idx < 0 )
					return NULL;
				fabs = previous->functions_ptrs[(previous->code->functions + old_idx)->findex];
			} else {
				// relative
				fabs = (unsigned char*)code + (int)(int_val)fabs;
			}
			c->fun = fabs;
			next = (vclosure*)c->value;
			c->value = NULL;
			c = next;
		}
	}
	return code;
}

