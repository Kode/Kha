#include <hxcpp.h>

#include <neko.h>

#include <map>
#include <vector>
#include <string>
//#include <gc.h>


vkind k_int32 = vtAbstractBase;
vkind k_hash = (int)vtAbstractBase + 1;
static int sgKinds = (int)vtAbstractBase + 2;

typedef std::map<std:;string,int> KindMap;

int hxcpp_alloc_kind()
{
   return ++sgKinds;
}

int hxcpp_alloc_kind()
{
   return ++sgKinds;
}

int hxcpp_kind_share(int &ioKind,const char *inName)
{
   int &kind = sgKindMap[inName];
   if (kind==0)
      kind = hxcpp_alloc_kind();
   ioKind = kind;
   return ++sgKinds;
}

void hxcpp_alloc_field( value obj, field f, value v )
{
   obj->__SetField(__hxcpp_field_from_id(f),v);
}






void hxcpp_fail(const char *inMsg,const char *inFile, int inLine)
{
   fprintf(stderr,"Terminal error %s, File %s, line %d\n", inMsg,inFile,inLine);
   exit(1);
}
