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

#if !defined(HL_THREADS)

struct _hl_mutex {
	void (*free)( hl_mutex * );
	void *_unused;
};

struct _hl_tls {
	void (*free)( hl_tls * );
	void *value;
};

#elif defined(HL_WIN)

struct _hl_mutex {
	void (*free)( hl_mutex * );
	CRITICAL_SECTION cs;
	bool is_gc;
};

struct _hl_tls {
	void (*free)( hl_tls * );
	DWORD tid;
};

#else

#	include <pthread.h>
#	include <unistd.h>
#	include <sys/syscall.h>
#	include <sys/time.h>


struct _hl_mutex {
	void (*free)( hl_mutex * );
	pthread_mutex_t lock;
	bool is_gc;
};

struct _hl_tls {
	void (*free)( hl_tls * );
	pthread_key_t key;
};

#endif

// ----------------- ALLOC

HL_PRIM hl_mutex *hl_mutex_alloc( bool gc_thread ) {
#	if !defined(HL_THREADS)
	static struct _hl_mutex null_mutex = {0};
	return (hl_mutex*)&null_mutex;
#	elif defined(HL_WIN)
	hl_mutex *l = (hl_mutex*)hl_gc_alloc_finalizer(sizeof(hl_mutex));
	l->free = hl_mutex_free;
	l->is_gc = gc_thread;
	InitializeCriticalSection(&l->cs);
	return l;
#	else
	hl_mutex *l = (hl_mutex*)hl_gc_alloc_finalizer(sizeof(hl_mutex));
	l->free = hl_mutex_free;
	l->is_gc = gc_thread;
	pthread_mutexattr_t a;
	pthread_mutexattr_init(&a);
	pthread_mutexattr_settype(&a,PTHREAD_MUTEX_RECURSIVE);
	pthread_mutex_init(&l->lock,&a);
	pthread_mutexattr_destroy(&a);
	return l;
#	endif
}

HL_PRIM void hl_mutex_acquire( hl_mutex *l ) {
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	if( l->is_gc ) hl_blocking(true);
	EnterCriticalSection(&l->cs);
	if( l->is_gc ) hl_blocking(false);
#	else
	if( l->is_gc ) hl_blocking(true);
	pthread_mutex_lock(&l->lock);
	if( l->is_gc ) hl_blocking(false);
#	endif
}

HL_PRIM bool hl_mutex_try_acquire( hl_mutex *l ) {
#if	!defined(HL_THREADS)
	return true;
#	elif defined(HL_WIN)
	return (bool)TryEnterCriticalSection(&l->cs);
#	else
	return pthread_mutex_trylock(&l->lock) == 0;
#	endif
}

HL_PRIM void hl_mutex_release( hl_mutex *l ) {
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	LeaveCriticalSection(&l->cs);
#	else
	pthread_mutex_unlock(&l->lock);
#	endif
}

HL_PRIM void hl_mutex_free( hl_mutex *l ) {
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	if( l->free ) {
		DeleteCriticalSection(&l->cs);
		l->free = NULL;
	}
#	else
	if( l->free ) {
		pthread_mutex_destroy(&l->lock);
		l->free = NULL;
	}
#	endif
}

#define _MUTEX _ABSTRACT(hl_mutex)
DEFINE_PRIM(_MUTEX, mutex_alloc, _BOOL);
DEFINE_PRIM(_VOID, mutex_acquire, _MUTEX);
DEFINE_PRIM(_BOOL, mutex_try_acquire, _MUTEX);
DEFINE_PRIM(_VOID, mutex_release, _MUTEX);
DEFINE_PRIM(_VOID, mutex_free, _MUTEX);

// ----------------- THREAD LOCAL

HL_PRIM hl_tls *hl_tls_alloc( bool gc_value ) {
#	if !defined(HL_THREADS)
	hl_tls *l = (hl_tls*)hl_gc_alloc_finalizer(sizeof(hl_tls));
	l->free = hl_tls_free;
	l->value = NULL;
	return l;
#	elif defined(HL_WIN)
	hl_tls *l = (hl_tls*)hl_gc_alloc_finalizer(sizeof(hl_tls));
	l->free = hl_tls_free;
	l->tid = TlsAlloc();
	TlsSetValue(l->tid,NULL);
	return l;
#	else
	hl_tls *l = (hl_tls*)hl_gc_alloc_finalizer(sizeof(hl_tls));
	l->free = hl_tls_free;
	pthread_key_create(&l->key,NULL);
	return l;
#	endif
}

HL_PRIM void hl_tls_free( hl_tls *l ) {
#	if !defined(HL_THREADS)
	free(l);
#	elif defined(HL_WIN)
	if( l->free ) {
		TlsFree(l->tid);
		l->free = NULL;
	}
#	else
	if( l->free ) {
		pthread_key_delete(l->key);
		l->free = NULL;
	}
#	endif
}

HL_PRIM void hl_tls_set( hl_tls *l, void *v ) {
#	if !defined(HL_THREADS)
	l->value = v;
#	elif defined(HL_WIN)
	TlsSetValue(l->tid,v);
#	else
	pthread_setspecific(l->key,v);
#	endif
}

HL_PRIM void *hl_tls_get( hl_tls *l ) {
#	if !defined(HL_THREADS)
	return l->value;
#	elif defined(HL_WIN)
	return (void*)TlsGetValue(l->tid);
#	else
	return pthread_getspecific(l->key);
#	endif
}

#define _TLS _ABSTRACT(hl_tls)
DEFINE_PRIM(_TLS, tls_alloc, _BOOL);
DEFINE_PRIM(_DYN, tls_get, _TLS);
DEFINE_PRIM(_VOID, tls_set, _TLS _DYN);

// ----------------- DEQUE

typedef struct _tqueue {
	vdynamic *msg;
	struct _tqueue *next;
} tqueue;

struct _hl_deque;
typedef struct _hl_deque hl_deque;

struct _hl_deque {
	void (*free)( hl_deque * );
	tqueue *first;
	tqueue *last;
#ifdef HL_THREADS
#	ifdef HL_WIN
	CRITICAL_SECTION lock;
	HANDLE wait;
#	else
	pthread_mutex_t lock;
	pthread_cond_t wait;
#	endif
#endif
};

#if !defined(HL_THREADS)
#	define LOCK(l)
#	define UNLOCK(l)
#	define SIGNAL(l)
#elif defined(HL_WIN)
#	define LOCK(l)		EnterCriticalSection(&(l))
#	define UNLOCK(l)	LeaveCriticalSection(&(l))
#	define SIGNAL(l)	ReleaseSemaphore(l,1,NULL)
#else
#	define LOCK(l)		pthread_mutex_lock(&(l))
#	define UNLOCK(l)	pthread_mutex_unlock(&(l))
#	define SIGNAL(l)	pthread_cond_signal(&(l))
#endif

static void hl_deque_free( hl_deque *q ) {
	hl_remove_root(&q->first);
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	DeleteCriticalSection(&q->lock);
	CloseHandle(q->wait);
#	else
	pthread_mutex_destroy(&q->lock);
	pthread_cond_destroy(&q->wait);
#	endif
}

HL_API hl_deque *hl_deque_alloc() {
	hl_deque *q = (hl_deque*)hl_gc_alloc_finalizer(sizeof(hl_deque));
	q->free = hl_deque_free;
	q->first = NULL;
	q->last = NULL;
	hl_add_root(&q->first);
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	q->wait = CreateSemaphore(NULL,0,(1 << 30),NULL);
	InitializeCriticalSection(&q->lock);
#	else
	pthread_mutex_init(&q->lock,NULL);
	pthread_cond_init(&q->wait,NULL);
#	endif
	return q;
}

HL_API void hl_deque_add( hl_deque *q, vdynamic *msg ) {
	tqueue *t = (tqueue*)hl_gc_alloc_raw(sizeof(tqueue));
	t->msg = msg;
	t->next = NULL;
	LOCK(q->lock);
	if( q->last == NULL )
		q->first = t;
	else
		q->last->next = t;
	q->last = t;
	SIGNAL(q->wait);
	UNLOCK(q->lock);
}

HL_API void hl_deque_push( hl_deque *q, vdynamic *msg ) {
	tqueue *t = (tqueue*)hl_gc_alloc_raw(sizeof(tqueue));
	t->msg = msg;
	LOCK(q->lock);
	t->next = q->first;
	q->first = t;
	if( q->last == NULL )
		q->last = t;
	SIGNAL(q->wait);
	UNLOCK(q->lock);
}

HL_API vdynamic *hl_deque_pop( hl_deque *q, bool block ) {
	vdynamic *msg;
	hl_blocking(true);
	LOCK(q->lock);
	while( q->first == NULL )
		if( block ) {
#			if !defined(HL_THREADS)
#			elif defined(HL_WIN)
			UNLOCK(q->lock);
			WaitForSingleObject(q->wait,INFINITE);
			LOCK(q->lock);
#			else
			pthread_cond_wait(&q->wait,&q->lock);
#			endif
		} else {
			UNLOCK(q->lock);
			hl_blocking(false);
			return NULL;
		}
	msg = q->first->msg;
	q->first = q->first->next;
	if( q->first == NULL )
		q->last = NULL;
	else
		SIGNAL(q->wait);
	UNLOCK(q->lock);
	hl_blocking(false);
	return msg;
}


#define _DEQUE _ABSTRACT(hl_deque)
DEFINE_PRIM(_DEQUE, deque_alloc, _NO_ARG);
DEFINE_PRIM(_VOID, deque_add, _DEQUE _DYN);
DEFINE_PRIM(_VOID, deque_push, _DEQUE _DYN);
DEFINE_PRIM(_DYN, deque_pop, _DEQUE _BOOL);

// ----------------- LOCK

struct _hl_lock;
typedef struct _hl_lock hl_lock;

struct _hl_lock {
	void (*free)( hl_lock * );
#if !defined(HL_THREADS)
#elif defined(HL_WIN)
	HANDLE wait;
#else
	pthread_mutex_t lock;
	pthread_cond_t wait;
	int counter;
#endif
};

static void hl_lock_free( hl_lock *l ) {
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	CloseHandle(l->wait);
#	else
	pthread_mutex_destroy(&l->lock);
	pthread_cond_destroy(&l->wait);
#	endif
}

HL_PRIM hl_lock *hl_lock_create() {
	hl_lock *l = (hl_lock*)hl_gc_alloc_finalizer(sizeof(hl_lock));
	l->free = hl_lock_free;
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	l->wait = CreateSemaphore(NULL,0,(1 << 30),NULL);
#	else
	l->counter = 0;
	pthread_mutex_init(&l->lock,NULL);
	pthread_cond_init(&l->wait,NULL);
#	endif
	return l;
}

HL_PRIM void hl_lock_release( hl_lock *l ) {
#	if !defined(HL_THREADS)
#	elif defined(HL_WIN)
	ReleaseSemaphore(l->wait,1,NULL);
#	else
	pthread_mutex_lock(&l->lock);
	l->counter++;
	pthread_cond_signal(&l->wait);
	pthread_mutex_unlock(&l->lock);
#	endif
}

HL_PRIM bool hl_lock_wait( hl_lock *l, vdynamic *timeout ) {
#	if !defined(HL_THREADS)
	return true;
#	elif defined(HL_WIN)
	DWORD ret;
	hl_blocking(true);
	ret = WaitForSingleObject(l->wait, timeout?(DWORD)((FLOAT)timeout->v.d * 1000.0):INFINITE);
	hl_blocking(false);
	switch( ret ) {
	case WAIT_ABANDONED:
	case WAIT_OBJECT_0:
		return true;
	case WAIT_TIMEOUT:
		return false;
	default:
		hl_error("Lock wait error");
	}
#	else
	{
		hl_blocking(true);
		pthread_mutex_lock(&l->lock);
		while( l->counter == 0 ) {
			if( timeout ) {
				struct timeval tv;
				struct timespec t;
				double delta = timeout->v.d;
				int idelta = (int)delta, idelta2;
				delta -= idelta;
				delta *= 1.0e9;
				gettimeofday(&tv,NULL);
				delta += tv.tv_usec * 1000.0;
				idelta2 = (int)(delta / 1e9);
				delta -= idelta2 * 1e9;
				t.tv_sec = tv.tv_sec + idelta + idelta2;
				t.tv_nsec = (long)delta;
				if( pthread_cond_timedwait(&l->wait,&l->lock,&t) != 0 ) {
					pthread_mutex_unlock(&l->lock);
					hl_blocking(false);
					return false;
				}
			} else
				pthread_cond_wait(&l->wait,&l->lock);
		}
		l->counter--;
		if( l->counter > 0 )
			pthread_cond_signal(&l->wait);
		pthread_mutex_unlock(&l->lock);
		hl_blocking(false);
		return true;
	}
#	endif
}

#define _LOCK _ABSTRACT(hl_lock)
DEFINE_PRIM(_LOCK, lock_create, _NO_ARG);
DEFINE_PRIM(_VOID, lock_release, _LOCK);
DEFINE_PRIM(_BOOL, lock_wait, _LOCK _NULL(_F64));

// ----------------- THREAD

HL_PRIM hl_thread *hl_thread_current() {
#if !defined(HL_THREADS)
	return NULL;
#elif defined(HL_WIN)
	return (hl_thread*)(int_val)GetCurrentThreadId();
#else
	return (hl_thread*)pthread_self();
#endif
}

HL_PRIM void hl_thread_yield() {
#if !defined(Hl_THREADS)
	// nothing
#elif defined(HL_WIN)
	Sleep(0);
#else
	pthread_yield();
#endif
}


HL_PRIM int hl_thread_id() {
#if !defined(HL_THREADS)
	return 0;
#elif defined(HL_WIN)
	return (int)GetCurrentThreadId();
#elif defined(HL_MAC)
	uint64_t tid64;
	pthread_threadid_np(NULL, &tid64);
	return (pid_t)tid64;
#elif defined(SYS_gettid) && !defined(HL_TVOS)
	return syscall(SYS_gettid);
#else
	hl_error("hl_thread_id() not available for this platform");
	return -1;
#endif
}

typedef struct {
	void (*callb)( void *);
	void *param;
} thread_start;

#ifdef HL_THREADS
static void gc_thread_entry( thread_start *_s ) {
	thread_start s = *_s;
	hl_register_thread(&s);
	hl_remove_root(&_s->param);
	free(_s);
	s.callb(s.param);
	hl_unregister_thread();
}
#endif

HL_PRIM hl_thread *hl_thread_start( void *callback, void *param, bool withGC ) {
#ifdef HL_THREADS
	if( withGC ) {
		thread_start *s = (thread_start*)malloc(sizeof(thread_start));
		s->callb = callback;
		s->param = param;
		hl_add_root(&s->param);
		callback = gc_thread_entry;
		param = s;
	}
#endif
#if !defined(HL_THREADS)
	hl_error("Threads support is disabled");
	return NULL;
#elif defined(HL_WIN)
	DWORD tid;
	HANDLE h = CreateThread(NULL,0,callback,param,0,&tid);
	if( h == NULL )
		return NULL;
	CloseHandle(h);
	return (hl_thread*)(int_val)tid;
#else
	pthread_t t;
	pthread_attr_t attr;
	pthread_attr_init(&attr);
	pthread_attr_setdetachstate(&attr,PTHREAD_CREATE_DETACHED);
	if( pthread_create(&t,&attr,callback,param) != 0 ) {
		pthread_attr_destroy(&attr);
		return NULL;
	}
	pthread_attr_destroy(&attr);
	return (hl_thread*)t;
#endif
}

static void hl_run_thread( vclosure *c ) {
	bool isExc;
	varray *a;
	int i;
	vdynamic *exc = hl_dyn_call_safe(c,NULL,0,&isExc);
	if( !isExc )
		return;
	a = hl_exception_stack();
	uprintf(USTR("Uncaught exception: %s\n"), hl_to_string(exc));
	for(i=0;i<a->size;i++)
		uprintf(USTR("Called from %s\n"), hl_aptr(a,uchar*)[i]);
	fflush(stdout);
}

HL_PRIM hl_thread *hl_thread_create( vclosure *c ) {
	return hl_thread_start(hl_run_thread,c,true);
}

#define _THREAD _ABSTRACT(hl_thread)
DEFINE_PRIM(_THREAD, thread_current, _NO_ARG);
DEFINE_PRIM(_THREAD, thread_create, _FUN(_VOID,_NO_ARG));
