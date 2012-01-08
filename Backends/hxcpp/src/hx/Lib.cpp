#include <hxcpp.h>

#include <stdio.h>
#define INT_MIN     (-2147483647 - 1) /* minimum (signed) int value */
#define INT_MAX       2147483647    /* maximum (signed) int value */
#include <string>
#include <map>
#include <vector>

#ifdef ANDROID
#include <android/log.h>
#include <unistd.h>
#endif


#ifdef HXCPP_LOAD_DEBUG
bool gLoadDebug = true;
#else
bool gLoadDebug = false;
#endif

#ifdef _WIN32

#include <windows.h>
typedef HMODULE Module;

Module hxLoadLibrary(String inLib) { return LoadLibraryW(inLib.__WCStr()); }
void *hxFindSymbol(Module inModule, const char *inSymbol) { return (void *)GetProcAddress(inModule,inSymbol); }
#elif defined (IPHONE)

typedef void *Module;
Module hxLoadLibrary(const String &) { return 0; }
#else

typedef void *Module;

#include <dlfcn.h>
typedef void *Module;
Module hxLoadLibrary(String inLib)
{
   Module result = dlopen(inLib.__CStr(), RTLD_NOW|RTLD_GLOBAL);
   if (gLoadDebug)
   {
      printf("Error loading library: %s\n", dlerror());
   }
   return result;
}
void *hxFindSymbol(Module inModule, const char *inSymbol) { return dlsym(inModule,inSymbol); }
#endif

#ifdef HX_UTF8_STRINGS
typedef std::map<std::string,Module> LoadedModule;
#else
typedef std::map<std::wstring,Module> LoadedModule;
#endif

static LoadedModule sgLoadedModule;

typedef hx::Object * (*prim_0)();
typedef hx::Object * (*prim_1)(hx::Object *);
typedef hx::Object * (*prim_2)(hx::Object *,hx::Object *);
typedef hx::Object * (*prim_3)(hx::Object *,hx::Object *,hx::Object *);
typedef hx::Object * (*prim_4)(hx::Object *,hx::Object *,hx::Object *,hx::Object *);
typedef hx::Object * (*prim_5)(hx::Object *,hx::Object *,hx::Object *,hx::Object *,hx::Object *);
typedef hx::Object * (*prim_mult)(hx::Object **inArray,int inArgs);

typedef void *(*FundFunc)(); 


class ExternalPrimitive : public hx::Object
{
public:
   ExternalPrimitive(void *inProc,int inArgCount,const String &inName) :
       mProc(inProc), mArgCount(inArgCount), mName(inName)
   {
   }

   virtual int __GetType() const { return vtFunction; }
   String __ToString() const { return mName; }

   Dynamic __run()
   {
      if (mArgCount!=0) throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_0)mProc)();
   }
   Dynamic __run(D a)
   {
      if (mArgCount!=1) throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_1)mProc)(a.GetPtr());
   }
   Dynamic __run(D a,D b)
   {
      if (mArgCount!=2) throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_2)mProc)(a.GetPtr(),b.GetPtr());
   }
   Dynamic __run(D a,D b,D c)
   {
      if (mArgCount!=3) throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_3)mProc)(a.GetPtr(),b.GetPtr(),c.GetPtr());
   }
   Dynamic __run(D a,D b,D c,D d)
   {
      if (mArgCount!=4) throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_4)mProc)(a.GetPtr(),b.GetPtr(),c.GetPtr(),d.GetPtr());
   }
   Dynamic __run(D a,D b,D c,D d,D e)
   {
      if (mArgCount!=5) throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_5)mProc)(a.GetPtr(),b.GetPtr(),c.GetPtr(),d.GetPtr(),e.GetPtr());
   }

   Dynamic __Run(const Array<Dynamic> &inArgs)
   {
      if (mArgCount!=-1)
         throw HX_INVALID_ARG_COUNT;
      HX_SOURCE_PUSH(0);
      return ((prim_mult)mProc)( (hx::Object **)inArgs->GetBase(), inArgs->length );
   }

   void __Mark(HX_MARK_PARAMS) {  HX_MARK_MEMBER(mName); }

   int __Compare(const hx::Object *inRHS) const
   {
      const ExternalPrimitive *other = dynamic_cast<const ExternalPrimitive *>(inRHS);
      if (!other)
         return -1;
      return mProc==other->mProc;
   }


   void        *mProc;
   int         mArgCount;
   String      mName;
};


typedef void (*SetLoaderProcFunc)(void *(*)(const char *));
typedef void *(*GetNekoEntryFunc)();
typedef void (*NekoEntryFunc)();

String GetFileContents(String inFile)
{
#ifndef _WIN32
   FILE *file = fopen(inFile.__CStr(),"rb");
#else
   FILE *file = _wfopen(inFile.__WCStr(),L"rb");
#endif
   if (!file)
   {
      // printf("Could not open %S\n", inFile.__s);
      return null();
   }

   char buf[2049];
   int bytes = fread(buf,1,2048,file);
   fclose(file);
   if (bytes<1)
      return null();
   buf[bytes]='\0';
   return String(buf,strlen(buf));
}

String GetEnv(const char *inPath)
{
   const char *env  = getenv(inPath);
   String result(env,env?strlen(env):0);
   return result;
}

String FindHaxelib(String inLib)
{
   bool gLoadDebug = getenv("HXCPP_LOAD_DEBUG");

   // printf("FindHaxelib %S\n", inLib.__s);
   String haxepath = GetEnv("HAXEPATH");
   if (gLoadDebug) printf("HAXEPATH env:%s\n", haxepath.__s);
   if (haxepath.length==0)
   {
       String home = GetEnv("HOME") + HX_CSTRING("/.haxelib");
       haxepath = GetFileContents(home);
       if (gLoadDebug) printf("HAXEPATH home:%s\n", haxepath.__s);
   }
   else
   {
      haxepath += HX_CSTRING("/lib");
   }
   if (gLoadDebug) printf("HAXEPATH dir:%s\n", haxepath.__s);

   if (haxepath.length==0)
   {
       haxepath = GetFileContents(HX_CSTRING("/etc/.haxepath"));
       if (gLoadDebug) printf("HAXEPATH etc:%s\n", haxepath.__s);
   }

   if (haxepath.length==0)
   {
      #ifdef _WIN32
      haxepath = HX_CSTRING("C:\\Program Files\\Motion-Twin\\haxe\\lib");
      #else
      haxepath = HX_CSTRING("/usr/lib/haxe/lib");
      #endif
       if (gLoadDebug) printf("HAXEPATH default:%s\n", haxepath.__s);
   }

   String dir = haxepath + HX_CSTRING("/") + inLib + HX_CSTRING("/");


   String dev = dir + HX_CSTRING(".dev");
   String path = GetFileContents(dev);
   if (gLoadDebug) printf("Read dev location from file :%s, got %s\n", dev.__s, path.__s);
   if (path.length==0)
   {
      path = GetFileContents(dir + HX_CSTRING(".current"));
      if (path.length==0)
         return null();
      // Replace "." with "," ...
      String with_commas;
      for(int i=0;i<path.length;i++)
         if (path.getChar(i)=='.')
            with_commas += HX_CSTRING(",");
         else
            with_commas += path.substr(i,1);

      path = dir + with_commas + HX_CSTRING("/");
   }

   return path;
}

typedef std::map<std::string,void *> RegistrationMap;
RegistrationMap *sgRegisteredPrims=0;


#ifdef IPHONE

Dynamic __loadprim(String inLib, String inPrim,int inArgCount)
{
   String full_name = inPrim;
   switch(inArgCount)
   {
      case 0: full_name += HX_CSTRING("__0"); break;
      case 1: full_name += HX_CSTRING("__1"); break;
      case 2: full_name += HX_CSTRING("__2"); break;
      case 3: full_name += HX_CSTRING("__3"); break;
      case 4: full_name += HX_CSTRING("__4"); break;
      case 5: full_name += HX_CSTRING("__5"); break;
      default:
          full_name += HX_CSTRING("__MULT");
   }


   if (sgRegisteredPrims)
   {
      void *registered = (*sgRegisteredPrims)[full_name.__CStr()];
      if (registered)
      {
         return Dynamic( new ExternalPrimitive(registered,inArgCount,HX_CSTRING("registered@")+full_name) );
      }
   }

   printf("Primitive not found : %s\n", full_name.__CStr() );
   return null();
}



#else


extern "C" void *hx_cffi(const char *inName);

Dynamic __loadprim(String inLib, String inPrim,int inArgCount)
{
#ifdef ANDROID
   inLib = HX_CSTRING("lib") + inLib;

   //__android_log_print(ANDROID_LOG_INFO, "loader", "%s: %s", inLib.__CStr(), inPrim.__CStr() );
#endif

   gLoadDebug = gLoadDebug || getenv("HXCPP_LOAD_DEBUG");
   String ext =
#if defined(_WIN32)
    HX_CSTRING(".dll");
#elif defined(__APPLE__)
    HX_CSTRING(".dylib");
#elif defined(ANDROID) || defined(GPH) || defined(WEBOS)
    HX_CSTRING(".so");
#else
    HX_CSTRING(".dso");
#endif



   String bin =
#ifdef _WIN32
    HX_CSTRING("Windows");
// Unix...
#elif defined(__APPLE__)
  #ifdef HXCPP_M64
    HX_CSTRING("Mac64");
  #else
    HX_CSTRING("Mac");
  #endif
#elif defined (ANDROID)
    HX_CSTRING("Android");
#elif defined(WEBOS)
    HX_CSTRING("webOS");
#else
  #ifdef HXCPP_M64
    HX_CSTRING("Linux64");
  #else
    HX_CSTRING("Linux");
  #endif
#endif

    int passes = 4;

   String full_name = inPrim;
   switch(inArgCount)
   {
      case 0: full_name += HX_CSTRING("__0"); break;
      case 1: full_name += HX_CSTRING("__1"); break;
      case 2: full_name += HX_CSTRING("__2"); break;
      case 3: full_name += HX_CSTRING("__3"); break;
      case 4: full_name += HX_CSTRING("__4"); break;
      case 5: full_name += HX_CSTRING("__5"); break;
      default:
          full_name += HX_CSTRING("__MULT");
   }

   #ifdef ANDROID
   std::string module_name = inLib.__CStr();
   Module module = sgLoadedModule[module_name];
   #else
   Module module = sgLoadedModule[inLib.__s];
   #endif
   bool new_module = module==0;

   if (!module && gLoadDebug)
   {
      #ifdef ANDROID
       __android_log_print(ANDROID_LOG_INFO, "loader", "Searching for %s...", module_name.c_str());
      #else
      printf("Searching for %s...\n", inLib.__CStr());
      #endif
   }


   for(int pass=0;module==0 && pass<2;pass++)
   {
      String dll_ext = HX_CSTRING("./") + inLib + ( (pass&1) ? HX_CSTRING(".ndll") : ext );

      // Try Current directory first ...
      if (gLoadDebug)
      {
         #ifndef ANDROID
         printf(" try %s...\n", dll_ext.__CStr());
         #else
         __android_log_print(ANDROID_LOG_INFO, "loader", "Try %s", dll_ext.__CStr());
         #endif
      }
      module = hxLoadLibrary(dll_ext);
      if (module)
         break;

      
      dll_ext = inLib + ( (pass&1) ? HX_CSTRING(".ndll") : ext );
      if (gLoadDebug)
      {
         #ifndef ANDROID
         printf(" try %s...\n", dll_ext.__CStr());
         #else
         __android_log_print(ANDROID_LOG_INFO, "loader", "Try %s", dll_ext.__CStr());
         #endif
      }
      module = hxLoadLibrary(dll_ext);

      #ifndef ANDROID
      if (!module)
      {
         String hxcpp = GetEnv("HXCPP");
         if (hxcpp.length!=0)
         {
             String name = hxcpp + HX_CSTRING("/bin/") + bin + HX_CSTRING("/") + dll_ext;
             if (gLoadDebug)
                printf(" try %s...\n", name.__CStr());
             module = hxLoadLibrary(name);
         }
      }
   
      if (!module)
      {
         String hxcpp = FindHaxelib( HX_CSTRING("hxcpp") );
         if (hxcpp.length!=0)
         {
             String name = hxcpp + HX_CSTRING("/bin/") + bin + HX_CSTRING("/") + dll_ext;
             if (gLoadDebug)
                printf(" try %s...\n", name.__CStr());
             module = hxLoadLibrary(name);
         }
      }

      if (!module)
      {
         String path = FindHaxelib(inLib);
         if (path.length!=0)
         {
            String full_path  = path + HX_CSTRING("/ndll/") + bin + HX_CSTRING("/") + dll_ext;
            if (gLoadDebug)
               printf(" try %s...\n", full_path.__CStr());
            module = hxLoadLibrary(full_path);
         }
      }
      #endif
   }

   if (!module && sgRegisteredPrims)
   {
      void *registered = (*sgRegisteredPrims)[full_name.__CStr()];
      if (registered)
      {
         return Dynamic( new ExternalPrimitive(registered,inArgCount,HX_CSTRING("registered@")+full_name) );
      }
   }

   if (!module)
   {
     throw Dynamic(HX_CSTRING("Could not load module ") + inLib + HX_CSTRING("@") + full_name);
    }


   if (new_module)
   {
      #ifdef ANDROID
      sgLoadedModule[module_name] = module;
      #else
      sgLoadedModule[inLib.__s] = module;
      #endif

      SetLoaderProcFunc set_loader = (SetLoaderProcFunc)hxFindSymbol(module,"hx_set_loader");
      if (set_loader)
         set_loader(hx_cffi);

      GetNekoEntryFunc func = (GetNekoEntryFunc)hxFindSymbol(module,"__neko_entry_point");
      if (func)
      {
         NekoEntryFunc entry = (NekoEntryFunc)func();
         if (entry)
            entry();
      }
   }

   FundFunc proc_query = (FundFunc)hxFindSymbol(module,full_name.__CStr());
   if (!proc_query)
   {
      #ifdef ANDROID
       __android_log_print(ANDROID_LOG_ERROR, "loader", "Could not find primitive %s in %p",
        full_name.__CStr(), module);
      #else
      fprintf(stderr,"Could not find primitive %s.\n", full_name.__CStr());
      #endif
      return 0;
   }

   void *proc = proc_query();
   if (!proc)
   {
#ifdef ANDROID
      __android_log_print(ANDROID_LOG_ERROR, "loader", "Could not identify primitive %s in %s\n", full_name.__CStr(),inLib.__CStr());
      fprintf(stderr,"Could not identify primitive %s in %s\n", full_name.__CStr(),inLib.__CStr());
#elif defined(ANDROID)
   __android_log_print(ANDROID_LOG_ERROR, "loader", "Could not identify primitive %s in %s",
        inPrim.__CStr(), inLib.__CStr() );
#else
   fprintf(stderr,"Could not identify primitive %s in %s\n", full_name.__CStr(),inLib.__CStr());
#endif
      return 0;
   }

   return Dynamic( new ExternalPrimitive(proc,inArgCount,inLib+HX_CSTRING("@")+full_name) );

   return 0;
}

#endif // not IPHONE

// This can be used to find symbols in static libraries

int __hxcpp_register_prim(const char *inName,void *inProc)
{
   if (sgRegisteredPrims==0)
      sgRegisteredPrims = new RegistrationMap();
   (*sgRegisteredPrims)[inName] = inProc;
   return 0;
}

