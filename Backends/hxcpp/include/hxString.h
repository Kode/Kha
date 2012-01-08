#ifndef HX_STRING_H
#define HX_STRING_H

#ifndef HXCPP_H
#error "Please include hxcpp.h, not hx/Object.h"
#endif


// --- String --------------------------------------------------------
//
// Basic String type for hxcpp.
// It's based on garbage collection of the wchar_t (or char ) *ptr.
// Note: this does not inherit from "hx::Object", so in some ways it acts more
// like a standard "int" type than a mode generic class.

class String
{
public:
  // These allocate the function using the garbage-colleced malloc
   void *operator new( size_t inSize );
   void operator delete( void * ) { }

   inline String() : length(0), __s(0) { }
   explicit String(const HX_CHAR *inPtr);
   inline String(const HX_CHAR *inPtr,int inLen) : __s(inPtr), length(inLen) { }
   #ifdef HX_UTF8_STRINGS
   String(const wchar_t *inPtr,int inLen);
   #else
   String(const char *inPtr,int inLen);
   #endif
   inline String(const String &inRHS) : __s(inRHS.__s), length(inRHS.length) { }
   String(const int &inRHS);
   String(const cpp::CppInt32__ &inRHS);
   String(const double &inRHS);
   explicit String(const bool &inRHS);
   inline String(const null &inRHS) : __s(0), length(0) { }

   static void __boot();

	hx::Object *__ToObject() const;

   template<typename T>
   inline String(const hx::ObjectPtr<T> &inRHS)
   {
      if (inRHS.mPtr)
      {
         String s = static_cast<hx::Object *>(inRHS.mPtr)->toString();
         __s = s.__s;
         length = s.length;
      }
      else { __s = 0; length = 0; }
   }
    String(const Dynamic &inRHS);

   inline String &operator=(const String &inRHS)
           { length = inRHS.length; __s = inRHS.__s; return *this; }

   String Default(const String &inDef) { return __s ? *this : inDef; }


   String toString() { return *this; }

    String __URLEncode() const;
    String __URLDecode() const;

    String &dup();

    String toUpperCase() const;
    String toLowerCase() const;
    String charAt(int inPos) const;
    Dynamic charCodeAt(int inPos) const;
    int indexOf(const String &inValue, Dynamic inStart) const;
    int lastIndexOf(const String &inValue, Dynamic inStart) const;
    Array<String> split(const String &inDelimiter) const;
    String substr(int inPos,Dynamic inLen) const;

   inline const HX_CHAR *c_str() const { return __s; }
   const char *__CStr() const;
   const wchar_t *__WCStr() const;

   static  String fromCharCode(int inCode);

   inline bool operator==(const null &inRHS) const { return __s==0; }
   inline bool operator!=(const null &inRHS) const { return __s!=0; }

   inline int getChar( int index ) { return __s[index]; }


   inline int compare(const String &inRHS) const
   {
      const HX_CHAR *r = inRHS.__s;
      if (__s == r) return inRHS.length-length;
      if (__s==0) return -1;
      if (r==0) return 1;
      #ifdef HX_UTF8_STRINGS
      return strcmp(__s,r);
      #elif defined(ANDROID)
      int min_len = length < inRHS.length ? length : inRHS.length;
      for(int i=0;i<min_len;i++)
         if (__s[i]<r[i]) return -1;
         else if (__s[i]>r[i]) return 1;
      return length<inRHS.length ? -1 : length>inRHS.length ? 1 : 0;
      #else
      return wcscmp(__s,r);
      #endif
   }


   String &operator+=(String inRHS);
   String operator+(String inRHS) const;
   String operator+(const int &inRHS) const { return *this + String(inRHS); }
   String operator+(const bool &inRHS) const { return *this + String(inRHS); }
   String operator+(const double &inRHS) const { return *this + String(inRHS); }
   String operator+(const null &inRHS) const{ return *this + HX_CSTRING("null"); } 
   //String operator+(const HX_CHAR *inRHS) const{ return *this + String(inRHS); } 
   String operator+(const cpp::CppInt32__ &inRHS) const{ return *this + String(inRHS); } 
   template<typename T>
   inline String operator+(const hx::ObjectPtr<T> &inRHS) const
      { return *this + (inRHS.mPtr ? const_cast<hx::ObjectPtr<T>&>(inRHS)->toString() : HX_CSTRING("null") ); }

   inline bool operator==(const String &inRHS) const
                     { return length==inRHS.length && compare(inRHS)==0; }
   inline bool operator!=(const String &inRHS) const
                     { return length != inRHS.length || compare(inRHS)!=0; }
   inline bool operator<(const String &inRHS) const { return compare(inRHS)<0; }
   inline bool operator<=(const String &inRHS) const { return compare(inRHS)<=0; }
   inline bool operator>(const String &inRHS) const { return compare(inRHS)>0; }
   inline bool operator>=(const String &inRHS) const { return compare(inRHS)>=0; }

   inline int cca(int inPos) const
	{
		if ((unsigned)inPos>=length) return 0;
		return __s[inPos];
	}


   static  Dynamic fromCharCode_dyn();

   Dynamic charAt_dyn();
   Dynamic charCodeAt_dyn();
   Dynamic indexOf_dyn();
   Dynamic lastIndexOf_dyn();
   Dynamic split_dyn();
   Dynamic substr_dyn();
   Dynamic toLowerCase_dyn();
   Dynamic toString_dyn();
   Dynamic toUpperCase_dyn();

	// This is used by the string-wrapped-as-dynamic class
   Dynamic __Field(const String &inString);

	// The actual implementation.
	// Note that "__s" is const - if you want to change it, you should create a new string.
	//  this allows for multiple strings to point to the same data.
   int length;
   const HX_CHAR *__s;
};




#endif
