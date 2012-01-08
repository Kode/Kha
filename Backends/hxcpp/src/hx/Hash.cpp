#include <hxcpp.h>
#include "RedBlack.h"
#include "FieldMap.h"

#include <hx/CFFI.h>
#include <map>


using namespace hx;

// --- IntHash ------------------------------------------------------------------------------

namespace hx
{

// --- FieldObject ------------------------------

FieldMap *FieldMapCreate()
{
	return (FieldMap *)(RBTree<String,Dynamic>::Create());
}

bool FieldMapGet(FieldMap *inMap, const String &inName, Dynamic &outValue)
{
	Dynamic *value = inMap->Find(inName);
	if (!value)
		return false;
	outValue = *value;
	return true;
}


bool FieldMapHas(FieldMap *inMap, const String &inName)
{
	return inMap->Find(inName);
}


bool FieldMapGet(FieldMap *inMap, int inID, Dynamic &outValue)
{
	Dynamic *value = inMap->Find(__hxcpp_field_from_id(inID));
	if (!value)
		return false;
	outValue = *value;
	return true;
}

void FieldMapSet(FieldMap *inMap, const String &inName, const Dynamic &inValue)
{
	inMap->Insert(inName,inValue);
}



void FieldMapAppendFields(FieldMap *inMap,Array<String> &outFields)
{
	KeyGetter getter(outFields);
	inMap->Iterate(getter);
}

struct Marker
{
	Marker(HX_MARK_PARAMS) { this->__inCtx = __inCtx;  }
	hx::MarkContext *__inCtx;

	void Visit(void *inPtr, const String &inStr, Dynamic &inDyn)
	{
		hx::MarkAlloc(inPtr HX_MARK_ADD_ARG);
		HX_MARK_STRING(inStr.__s);
		if (inDyn.mPtr)
      {
         #ifdef HXCPP_DEBUG
         hx::MarkSetMember(inStr.__s, __inCtx);
         #endif
		   HX_MARK_OBJECT(inDyn.mPtr);
      }
	}
};

void FieldMapMark(FieldMap *inMap HX_MARK_ADD_PARAMS)
{
	if (inMap)
	{
		hx::MarkAlloc(inMap HX_MARK_ADD_ARG);
		Marker m(HX_MARK_ARG);
		inMap->Iterate(m);
	}
}






class IntHash : public Object
{
#ifdef _WIN32
typedef int IntKey;
#else
typedef const int IntKey;
#endif

typedef std::map<IntKey,Dynamic, std::less<IntKey> > Map;

class hxMap : public Map
{
};

private:
   Map *mMap;
	hx::InternalFinalizer *mFinalizer;

public:
   IntHash()
	{
		mMap = new hxMap;
		mFinalizer = new hx::InternalFinalizer(this);
		mFinalizer->mFinalizer = Destroy;
	}

   void set(int inKey,const Dynamic &inValue) { (*mMap)[inKey] = inValue; }

   static void Destroy(Object *inObj);

   Dynamic get(int inKey)
   {
      Map::iterator i = mMap->find(inKey);
      if (i==mMap->end()) return null();
      return i->second;
   }
   bool exists(int inKey) { return mMap->find(inKey)!=mMap->end(); }
   bool remove(int inKey)
   {
      Map::iterator i = mMap->find(inKey);
      if (i==mMap->end()) return false;
      mMap->erase(i);
      return true;
   }
   Dynamic keys()
   {
      Array<Int> result(0,mMap->size());
      for(Map::iterator i=mMap->begin();i!=mMap->end();++i)
         result.Add(i->first);
      return result;
   }
   Dynamic values()
   {
      Array<Dynamic> result(0,mMap->size());
      for(Map::iterator i=mMap->begin();i!=mMap->end();++i)
         result.Add(i->second);
      return result;
   }
   String toString()
   {
      String result = HX_CSTRING("{ ");
      Map::iterator i=mMap->begin();
      while(i!=mMap->end())
      {
         result += String(i->first) + HX_CSTRING(" => ") + i->second;
         ++i;
         if (i!=mMap->end())
            result+= HX_CSTRING(",");
      }

      return result + HX_CSTRING("}");
   }

   void __Mark(HX_MARK_PARAMS)
   {
		mFinalizer->Mark();
      for(Map::iterator i=mMap->begin();i!=mMap->end();++i)
      {
         HX_MARK_OBJECT(i->second.mPtr);
      }
   }

};

void IntHash::Destroy(Object *inHash)
{
	IntHash *hash = dynamic_cast<IntHash *>(inHash);
	if (hash)
		delete hash->mMap;
}

}


Object * __int_hash_create() { return new IntHash; }

void __int_hash_set(Dynamic inHash,int inKey,const Dynamic &value)
{
   IntHash *h = dynamic_cast<IntHash *>(inHash.GetPtr());
   h->set(inKey,value);
}

Dynamic  __int_hash_get(Dynamic inHash,int inKey)
{
   IntHash *h = dynamic_cast<IntHash *>(inHash.GetPtr());
   return h->get(inKey);
}

bool  __int_hash_exists(Dynamic inHash,int inKey)
{
   IntHash *h = dynamic_cast<IntHash *>(inHash.GetPtr());
   return h->exists(inKey);
}

bool  __int_hash_remove(Dynamic inHash,int inKey)
{
   IntHash *h = dynamic_cast<IntHash *>(inHash.GetPtr());
   return h->remove(inKey);
}

Dynamic __int_hash_keys(Dynamic inHash)
{
   IntHash *h = dynamic_cast<IntHash *>(inHash.GetPtr());
   return h->keys();
}

Dynamic __int_hash_values(Dynamic inHash)
{
   IntHash *h = dynamic_cast<IntHash *>(inHash.GetPtr());
   return h->values();
}

