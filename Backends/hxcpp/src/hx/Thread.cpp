#include <hxcpp.h>

#include <hx/Thread.h>
#include <time.h>

#ifdef HXCPP_MULTI_THREADED
#define CHECK_THREADED
#else

#define CHECK_THREADED \
	throw Dynamic(HX_CSTRING("HXCPP_MULTI_THREADED not enabled"));

#endif

static TLSData<class hxThreadInfo> tlsCurrentThread;

// --- Deque ----------------------------------------------------------

struct Deque : public Array_obj<Dynamic>
{
	Deque() : Array_obj<Dynamic>(0,0) { }

	static Deque *Create()
	{
		Deque *result = new Deque();
		result->mFinalizer = new hx::InternalFinalizer(result);
		result->mFinalizer->mFinalizer = clean;
		return result;
	}
	static void clean(hx::Object *inObj)
	{
		Deque *d = dynamic_cast<Deque *>(inObj);
		if (d) d->Clean();
	}
	void Clean()
	{
		#ifdef HX_WINDOWS
		mMutex.Clean();
		#endif
		mSemaphore.Clean();
	}

	void __Mark(HX_MARK_PARAMS)
	{
		Array_obj<Dynamic>::__Mark(HX_MARK_ARG);
		mFinalizer->Mark();
	}

	#ifdef HX_WINDOWS
	MyMutex     mMutex;
	void PushBack(Dynamic inValue)
	{
		hx::EnterGCFreeZone();
		AutoLock lock(mMutex);
		hx::ExitGCFreeZone();

		push(inValue);
		mSemaphore.Set();
	}
	void PushFront(Dynamic inValue)
	{
		hx::EnterGCFreeZone();
		AutoLock lock(mMutex);
		hx::ExitGCFreeZone();

		unshift(inValue);
		mSemaphore.Set();
	}

	
	Dynamic PopFront(bool inBlock)
	{
		hx::EnterGCFreeZone();
		AutoLock lock(mMutex);
		if (!inBlock)
		{
			hx::ExitGCFreeZone();
			return shift();
		}
		// Ok - wait for something on stack...
		while(!length)
		{
			mSemaphore.Reset();
			lock.Unlock();
			mSemaphore.Wait();
			lock.Lock();
		}
		hx::ExitGCFreeZone();
		if (length==1)
			mSemaphore.Reset();
		return shift();
	}
	#else
	void PushBack(Dynamic inValue)
	{
		hx::EnterGCFreeZone();
		AutoLock lock(mSemaphore);
		hx::ExitGCFreeZone();
		push(inValue);
		mSemaphore.QSet();
	}
	void PushFront(Dynamic inValue)
	{
		hx::EnterGCFreeZone();
		AutoLock lock(mSemaphore);
		hx::ExitGCFreeZone();
		unshift(inValue);
		mSemaphore.QSet();
	}

	
	Dynamic PopFront(bool inBlock)
	{
		hx::EnterGCFreeZone();
		AutoLock lock(mSemaphore);
		while(inBlock && !length)
			mSemaphore.QWait();
		hx::ExitGCFreeZone();
		return shift();
	}
	#endif

	hx::InternalFinalizer *mFinalizer;
	MySemaphore mSemaphore;
};

Dynamic __hxcpp_deque_create()
{
	return Deque::Create();
}

void __hxcpp_deque_add(Dynamic q,Dynamic inVal)
{
	Deque *d = dynamic_cast<Deque *>(q.mPtr);
	if (!d)
		throw HX_INVALID_OBJECT;
	d->PushBack(inVal);
}

void __hxcpp_deque_push(Dynamic q,Dynamic inVal)
{
	Deque *d = dynamic_cast<Deque *>(q.mPtr);
	if (!d)
		throw HX_INVALID_OBJECT;
	d->PushFront(inVal);
}

Dynamic __hxcpp_deque_pop(Dynamic q,bool block)
{
	Deque *d = dynamic_cast<Deque *>(q.mPtr);
	if (!d)
		throw HX_INVALID_OBJECT;
	return d->PopFront(block);
}



// --- Thread ----------------------------------------------------------

class hxThreadInfo : public hx::Object
{
public:
	hxThreadInfo(Dynamic inFunction) : mFunction(inFunction), mTLS(0,0)
	{
		mSemaphore = new MySemaphore;
		mDeque = Deque::Create();
	}
	hxThreadInfo()
	{
		mSemaphore = 0;
		mDeque = Deque::Create();
	}
	void Clean()
	{
		mDeque->Clean();
	}
	void CleanSemaphore()
	{
		delete mSemaphore;
		mSemaphore = 0;
	}
	void Send(Dynamic inMessage)
	{
		mDeque->PushBack(inMessage);
	}
	Dynamic ReadMessage(bool inBlocked)
	{
		return mDeque->PopFront(inBlocked);
	}
	void SetTLS(int inID,Dynamic inVal) { mTLS[inID] = inVal; }
	Dynamic GetTLS(int inID) { return mTLS[inID]; }

	void __Mark(HX_MARK_PARAMS)
	{
		HX_MARK_MEMBER(mFunction);
		HX_MARK_MEMBER(mTLS);
		if (mDeque)
			HX_MARK_OBJECT(mDeque);
	}

	Array<Dynamic> mTLS;
	MySemaphore *mSemaphore;
	Dynamic mFunction;
	Deque   *mDeque;
};


THREAD_FUNC_TYPE hxThreadFunc( void *inInfo )
{
	int dummy = 0;
	hx::RegisterCurrentThread(&dummy);

	hxThreadInfo *info = (hxThreadInfo *)inInfo;
	tlsCurrentThread.Set(info);

	// Release the creation function
	info->mSemaphore->Set();

	if ( info->mFunction.GetPtr() )
	{
		// Try ... catch
		info->mFunction->__run();
	}

	hx::UnregisterCurrentThread();

	tlsCurrentThread.Set(0);

	THREAD_FUNC_RET
}



Dynamic __hxcpp_thread_create(Dynamic inStart)
{
	hxThreadInfo *info = new hxThreadInfo(inStart);

	hx::GCPrepareMultiThreaded();

   #if defined(HX_WINDOWS)
      _beginthreadex(0,0,hxThreadFunc,info,0,0);
   #else
      pthread_t result;
      pthread_create(&result,0,hxThreadFunc,info);
	#endif


	hx::EnterGCFreeZone();
	info->mSemaphore->Wait();
	hx::ExitGCFreeZone();
	info->CleanSemaphore();
	return info;
}

static hx::Object *sMainThreadInfo = 0;

static hxThreadInfo *GetCurrentInfo()
{
	hxThreadInfo *info = tlsCurrentThread.Get();
	if (!info)
	{
		// Hmm, must be the "main" thead...
		info = new hxThreadInfo(null());
		sMainThreadInfo = info;
		hx::GCAddRoot(&sMainThreadInfo);
		tlsCurrentThread.Set(info);
	}
	return info;
}

Dynamic __hxcpp_thread_current()
{
	CHECK_THREADED;
	return GetCurrentInfo();
}

void __hxcpp_thread_send(Dynamic inThread, Dynamic inMessage)
{
	CHECK_THREADED;
	hxThreadInfo *info = dynamic_cast<hxThreadInfo *>(inThread.mPtr);
	if (!info)
		throw HX_INVALID_OBJECT;
	info->Send(inMessage);
}

Dynamic __hxcpp_thread_read_message(bool inBlocked)
{
	CHECK_THREADED;
	hxThreadInfo *info = GetCurrentInfo();
	return info->ReadMessage(inBlocked);
}

// --- TLS ------------------------------------------------------------

Dynamic __hxcpp_tls_get(int inID)
{
	CHECK_THREADED;
	return GetCurrentInfo()->GetTLS(inID);
}

void __hxcpp_tls_set(int inID,Dynamic inVal)
{
	CHECK_THREADED;
	GetCurrentInfo()->SetTLS(inID,inVal);
}



// --- Mutex ------------------------------------------------------------

class hxMutex : public hx::Object
{
public:

	hxMutex()
	{
		mFinalizer = new hx::InternalFinalizer(this);
		mFinalizer->mFinalizer = clean;
	}

	void __Mark(HX_MARK_PARAMS) { mFinalizer->Mark(); }
	hx::InternalFinalizer *mFinalizer;

	static void clean(hx::Object *inObj)
	{
		hxMutex *m = dynamic_cast<hxMutex *>(inObj);
		if (m) m->mMutex.Clean();
	}
	bool Try()
	{
		return mMutex.TryLock();
	}
	void Acquire()
	{
		hx::EnterGCFreeZone();
		mMutex.Lock();
		hx::ExitGCFreeZone();
	}
	void Release()
	{
		mMutex.Unlock();
	}


   MyMutex mMutex;
};



Dynamic __hxcpp_mutex_create()
{
	CHECK_THREADED;
	return new hxMutex;
}
void __hxcpp_mutex_acquire(Dynamic inMutex)
{
	CHECK_THREADED;
	hxMutex *mutex = dynamic_cast<hxMutex *>(inMutex.mPtr);
	if (!mutex)
		throw HX_INVALID_OBJECT;
	mutex->Acquire();
}
bool __hxcpp_mutex_try(Dynamic inMutex)
{
	CHECK_THREADED;
	hxMutex *mutex = dynamic_cast<hxMutex *>(inMutex.mPtr);
	if (!mutex)
		throw HX_INVALID_OBJECT;
	return mutex->Try();
}
void __hxcpp_mutex_release(Dynamic inMutex)
{
	CHECK_THREADED;
	hxMutex *mutex = dynamic_cast<hxMutex *>(inMutex.mPtr);
	if (!mutex)
		throw HX_INVALID_OBJECT;
	return mutex->Release();
}






// --- Lock ------------------------------------------------------------

class hxLock : public hx::Object
{
public:

	hxLock()
	{
		mFinalizer = new hx::InternalFinalizer(this);
		mFinalizer->mFinalizer = clean;
	}

	void __Mark(HX_MARK_PARAMS) { mFinalizer->Mark(); }
	hx::InternalFinalizer *mFinalizer;

	#ifdef HX_WINDOWS
	double Now()
	{
		return (double)clock()/CLOCKS_PER_SEC;
	}
	#else
	double Now()
	{
		struct timeval tv;
		gettimeofday(&tv,NULL);
		return tv.tv_sec + tv.tv_usec*0.000001;
	}
	#endif

	static void clean(hx::Object *inObj)
	{
		hxLock *l = dynamic_cast<hxLock *>(inObj);
		if (l)
		{
			l->mNotEmpty.Clean();
			l->mAvailableLock.Clean();
		}
	}
	bool Wait(double inTimeout)
	{
		double stop = 0;
		if (inTimeout>=0)
			stop = Now() + inTimeout;
		while(1)
		{
			mAvailableLock.Lock();
			if (mAvailable)
			{
				--mAvailable;
				mAvailableLock.Unlock();
				return true;
			}
			mAvailableLock.Unlock();
			double wait = 0;
			if (inTimeout>=0)
			{
				wait = stop-Now();
				if (wait<=0)
					return false;
			}

			hx::EnterGCFreeZone();
			if (inTimeout<0)
				mNotEmpty.Wait( );
			else
				mNotEmpty.WaitFor(wait);
			hx::ExitGCFreeZone();
		}
	}
	void Release()
	{
		AutoLock lock(mAvailableLock);
		mAvailable++;
		mNotEmpty.Set();
	}


	MySemaphore mNotEmpty;
   MyMutex     mAvailableLock;
	int         mAvailable;
};



Dynamic __hxcpp_lock_create()
{
	CHECK_THREADED;
	return new hxLock;
}
bool __hxcpp_lock_wait(Dynamic inlock,double inTime)
{
	CHECK_THREADED;
	hxLock *lock = dynamic_cast<hxLock *>(inlock.mPtr);
	if (!lock)
		throw HX_INVALID_OBJECT;
	return lock->Wait(inTime);
}
void __hxcpp_lock_release(Dynamic inlock)
{
	CHECK_THREADED;
	hxLock *lock = dynamic_cast<hxLock *>(inlock.mPtr);
	if (!lock)
		throw HX_INVALID_OBJECT;
	lock->Release();
}


