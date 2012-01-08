#include <hxcpp.h>
#include <ctype.h>
#include <stdio.h>

using namespace hx;

// -------- String ----------------------------------------



#ifdef HX_WINDOWS

#ifndef _MSC_VER
#define _MSC_VER 1
#endif

// vc 7...
#if _MSC_VER < 1400 

#ifdef HX_UTF8_STRINGS
#define SPRINTF _snprintf
#else
#define SPRINTF _snwprintf
#endif

#else // vc8+

#ifdef HX_UTF8_STRINGS
#define SPRINTF _snprintf_s
#else
#define SPRINTF _snwprintf_s
#endif

#endif

#else // not windows ..

#ifdef HX_UTF8_STRINGS
#define SPRINTF snprintf
#else
#define SPRINTF swmprintf
#endif

#endif

#ifdef HX_UTF8_STRINGS
#define HX_DOUBLE_PATTERN "%.10g"
#define HX_INT_PATTERN "%d"
#else
#define HX_DOUBLE_PATTERN L"%.10g"
#define HX_INT_PATTERN L"%d"
#endif

// --- GC helper

Class __StringClass;


static int UTF8Bytes(int c)
{
      if( c <= 0x7F )
         return 1;
      else if( c <= 0x7FF )
         return 2;
      else if( c <= 0xFFFF )
         return 3;
      else
         return 4;
}

static void UTF8EncodeAdvance(char * &ioPtr,int c)
{
      if( c <= 0x7F )
         *ioPtr++ = (c);
      else if( c <= 0x7FF )
      {
         *ioPtr++ = ( 0xC0 | (c >> 6) );
         *ioPtr++ = ( 0x80 | (c & 63) );
      }
      else if( c <= 0xFFFF )
      {
         *ioPtr++  = ( 0xE0 | (c >> 12) );
         *ioPtr++  = ( 0x80 | ((c >> 6) & 63) );
         *ioPtr++  = ( 0x80 | (c & 63) );
      }
      else
      {
         *ioPtr++  = ( 0xF0 | (c >> 18) );
         *ioPtr++  = ( 0x80 | ((c >> 12) & 63) );
         *ioPtr++  = ( 0x80 | ((c >> 6) & 63) );
         *ioPtr++  = ( 0x80 | (c & 63) );
      }
}

int DecodeAdvanceUTF8(const unsigned char * &ioPtr)
{
   int c = *ioPtr++;
   if( c < 0x80 )
   {
      return c;
   }
   else if( c < 0xE0 )
   {
      return ((c & 0x3F) << 6) | ((*ioPtr++) & 0x7F);
   }
   else if( c < 0xF0 )
   {
      int c2 = *ioPtr++;
      return  ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | ( (*ioPtr++) & 0x7F);
   }

   int c2 = *ioPtr++;
   int c3 = *ioPtr++;
   return ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 << 6) & 0x7F) | ((*ioPtr++) & 0x7F);
 }


int DecodeBytes(int c)
{
   if( c < 0x80 )
   {
      return 1;
   }
   else if( c < 0xE0 )
   {
      return 2;
   }
   else if( c < 0xF0 )
   {
      return  3;
   }

   return 4;
 }






template<typename T>
char *TConvertToUTF8(T *inStr, int *ioLen)
{
   int len = 0;
   int chars = 0;
   if (ioLen==0)
      while(inStr[len])
         chars += UTF8Bytes(inStr[len++]);
   else
   {
      len = *ioLen;
      for(int i=0;i<len;i++)
         chars += UTF8Bytes(inStr[i]);
   }

   char *buf = (char *)NewGCPrivate(0,chars+1);
   char *ptr = buf;
   for(int i=0;i<len;i++)
       UTF8EncodeAdvance(ptr,inStr[i]);
   *ptr = 0;
   if (ioLen)
      *ioLen = chars;

   return buf;
 
}

String __hxcpp_char_array_to_utf8_string(Array<int> &inChars,int inFirst, int inLen)
{
   int *base = &inChars[0];
   int len = inChars->length;
   if (inFirst<0)
     inFirst = 0;
   if (inLen<0) inLen = len;
   if (inFirst+inLen>len)
      inLen = len-inFirst;
   if (inLen<0)
      return String();
   char *result = TConvertToUTF8(base+inFirst,&len);
   return String(result,len);
}

Array<int> __hxcpp_utf8_string_to_char_array(String &inString)
{
    Array<int> result = Array_obj<int>::__new(0,inString.length);

    const unsigned char *src = (const unsigned char *)inString.__s;
    const unsigned char *end = src + inString.length;
    while(src<end)
        result->push(DecodeAdvanceUTF8(src));

    if (src!=end)
       throw Dynamic(HX_CSTRING("Invalid UTF8"));

   return result;
}

String __hxcpp_char_bytes_to_utf8_string(String &inBytes)
{
   int len = inBytes.length;
   char *result = TConvertToUTF8((unsigned char *)inBytes.__s,&len);
   return String(result,len);
}


String __hxcpp_utf8_string_to_char_bytes(String &inUTF8)
{
    const unsigned char *src = (unsigned char *)inUTF8.__s;
    const unsigned char *end = src + inUTF8.length;
    int char_count = 0;
    while(src<end)
    {
        int c = DecodeAdvanceUTF8(src);
        char_count++;
	     if( c == 8364 ) // euro symbol
				c = 164;
			else if( c == 0xFEFF ) // BOM
			{
            char_count--;
         }
			else if( c > 255 )
				throw Dynamic(HX_CSTRING("Utf8::decode invalid character"));
    }

    if (src!=end)
       throw Dynamic(HX_CSTRING("Invalid UTF8"));

    HX_CHAR *result = hx::NewString(char_count);

    src = (unsigned char *)inUTF8.__s;
    char_count = 0;
    while(src<end)
    {
        int c = DecodeAdvanceUTF8(src);
	     if( c == 8364 ) // euro symbol
				c = 164;
		  if( c != 0xFEFF ) // BOM
           result[char_count++] = c;
    }

   result[char_count] = '\0';
   return String(result,char_count);
}




static HX_CHAR *GCStringDup(const HX_CHAR *inStr,int inLen, int *outLen=0)
{
   if (inStr==0 && inLen<=0)
   {
      if (outLen)
         outLen = 0;
      return 0;
   }

   if (inLen==-1)
   {
       inLen=0;
       while(inStr[inLen]) inLen++;
   }
   
   if (outLen)
      *outLen = inLen;

   HX_CHAR *result = hx::NewString(inLen);
   memcpy(result,inStr,sizeof(HX_CHAR)*(inLen));
   result[inLen] = '\0';
   return result;
}




String::String(const Dynamic &inRHS)
{
   if (inRHS.GetPtr())
      (*this)=const_cast<Dynamic &>(inRHS)->toString();
   else
   {
      __s = 0;
      length = 0;
   }
}


String::String(const int &inRHS)
{
   HX_CHAR buf[100];
   SPRINTF(buf,100,HX_INT_PATTERN,inRHS);
   buf[99]='\0';
   __s = GCStringDup(buf,-1,&length);
}


String::String(const cpp::CppInt32__ &inRHS)
{
   HX_CHAR buf[100];
   SPRINTF(buf,100,HX_INT_PATTERN,inRHS.mValue);
   __s = GCStringDup(buf,-1,&length);
}

// Construct from utf8 string
#ifdef HX_UTF8_STRINGS
String::String(const wchar_t *inPtr,int inLen)
{
   if (!inPtr)
   {
       __s = 0;
       length = 0;
   }
   else if (inLen==0)
   {
       __s = 0;
       length = 0;
       *this = HX_CSTRING("");
   }
   else
   {
      length = inLen;
      __s = TConvertToUTF8(inPtr,&length);
   }
}
#else
String::String(const char *inPtr,int inLen)
{
   length = inLen;
    __s = hx::ConvertToWChar(inPtr,&length);
}
#endif

String::String(const HX_CHAR *inStr)
{
   __s = GCStringDup(inStr,-1,&length);
}



String::String(const double &inRHS)
{
   HX_CHAR buf[100];
   SPRINTF(buf,100,HX_DOUBLE_PATTERN,inRHS);
   buf[99]='\0';
   __s = GCStringDup(buf,-1,&length);
}

String::String(const bool &inRHS)
{
   if (inRHS)
   {
      *this = HX_CSTRING("true");
   }
   else
   {
      *this = HX_CSTRING("false");
   }
}



String String::__URLEncode() const
{
   Array<unsigned char> bytes(0,length);
   // utf8-encode
   __hxcpp_bytes_of_string(bytes,*this);

   int extra = 0;
   int spaces = 0;
   int utf8_chars = bytes->__length();
   for(int i=0;i<utf8_chars;i++)
      if ( !isalnum(bytes[i]) && bytes[i]!=' ' && bytes[i]!='-')
         extra++;
      else if (bytes[i]==' ')
         spaces++;
   if (extra==0 && spaces==0)
      return *this;

   int l = utf8_chars + extra*2 + spaces*2 /* *0 */;
   HX_CHAR *result = hx::NewString(l);
   HX_CHAR *ptr = result;
   bool has_plus = false;

   for(int i=0;i<utf8_chars;i++)
   {
      if ( bytes[i]==' ')
      {
         //*ptr++ = '+';
         *ptr++ = '%';
         *ptr++ = '2';
         *ptr++ = '0';
      }
      else if ( !isalnum(bytes[i]) && bytes[i]!='-' )
      {
         static char hex[] = "0123456789ABCDEF";
         unsigned char b = bytes[i];
         *ptr++ = '%';
         *ptr++ = hex[ b>>4 ];
         *ptr++ = hex[ b & 0x0f ];
      }
      else
         *ptr++ = bytes[i];
   }
   return String(result,l);
}

String String::toUpperCase() const
{
   HX_CHAR *result = hx::NewString(length);
   for(int i=0;i<length;i++)
      result[i] = toupper( __s[i] );
   return String(result,length);
}

String String::toLowerCase() const
{
   HX_CHAR *result = hx::NewString(length);
   for(int i=0;i<length;i++)
      result[i] = tolower( __s[i] );
   return String(result,length);
}


static int hex(int inChar)
{
   if (inChar>='0' && inChar<='9')
      return inChar-'0';
   if (inChar>='a' && inChar<='f')
      return inChar-'a' + 10;
   if (inChar>='A' && inChar<='F')
      return inChar-'A' + 10;
   return 0;
}

String String::__URLDecode() const
{
   Array<unsigned char> bytes(0,length);
   for(int i=0;i<length;i++)
   {
      int c = __s[i];
      if (c>127)
         bytes->push('?');
      else if (c=='+')
         bytes->push(' ');
      else if (c=='%')
      {
         i++;
         int h0 = __s[i];
         if (h0!=0)
         {
            i++;
            int h1 = __s[i];
            bytes->push( (hex(h0)<<4) | hex(h1) );
         }
      }
      else
         bytes->push(c);
   }
   // utf8 -> unicode ...
   int len = bytes->__length();
   bytes->push(' ');
   #ifdef HX_UTF8_STRINGS
   return String( bytes->GetBase(), len ).dup();
   #else
   return String( GCStringDup(bytes->GetBase(),len,0), len );
   #endif
}


String &String::dup()
{
   __s = GCStringDup(__s,length,&length);
   return *this;
}

int String::indexOf(const String &inValue, Dynamic inStart) const
{
   if (__s==0)
      return -1;
   int s = inStart==null() ? 0 : inStart->__ToInt();
   int l = inValue.length;
   if (l==1)
   {
      HX_CHAR test = *inValue.__s;
      while(s<length)
      {
         if (__s[s]==test)
            return s;
         ++s;
      }
   }
   else
   {
      while(s<=length-l)
      {
         if (!memcmp(__s + s,inValue.__s,l*sizeof(HX_CHAR)))
            return s;
         s++;
      }
   }
   return -1;
}



int String::lastIndexOf(const String &inValue, Dynamic inStart) const
{
   if (__s==0)
      return -1;
   int l = inValue.length;
   if (l>length) return -1;
   int s = inStart==null() ? length : inStart->__ToInt();
   if (s+l>length) s = length-l;

   if (l==1)
   {
      HX_CHAR test = *inValue.__s;
      while(s>=0)
      {
         if (__s[s]==test)
            return s;
         --s;
      }
   }
   else
   {
      while(s>=0)
      {
         if (!memcmp(__s + s,inValue.__s,l*sizeof(HX_CHAR)))
            return s;
         --s;
      }
   }
   return -1;
}





Dynamic String::charCodeAt(int inPos) const
{
   if (inPos<0 || inPos>=length)
      return null();

   #ifdef HX_UTF8_STRINGS
   // really "byte code at" ...
   //const unsigned char *p = (const unsigned char *)(__s + inPos);
   //return DecodeAdvanceUTF8(p);
   return (int)( ((unsigned char *)__s) [inPos]);
   #else
   return (int)(__s[inPos]);
   #endif
}

String String::fromCharCode( int c )
{
   #ifdef HX_UTF8_STRINGS
   int len = 0;
   char buf[5];

      if( c <= 0x7F )
         buf[len++] = (c);
      else if( c <= 0x7FF )
      {
         buf[len++] = ( 0xC0 | (c >> 6) );
         buf[len++] = ( 0x80 | (c & 63) );
      }
      else if( c <= 0xFFFF )
      {
         buf[len++] = ( 0xE0 | (c >> 12) );
         buf[len++] = ( 0x80 | ((c >> 6) & 63) );
         buf[len++] = ( 0x80 | (c & 63) );
      }
      else
      {
         buf[len++] = ( 0xF0 | (c >> 18) );
         buf[len++] = ( 0x80 | ((c >> 12) & 63) );
         buf[len++] = ( 0x80 | ((c >> 6) & 63) );
         buf[len++] = ( 0x80 | (c & 63) );
      }
   buf[len] = '\0';
   return String( GCStringDup(buf,len,0), len );

   #else
   wchar_t *result = hx::NewString(1);
   result[0] = c;
   result[1] = '\0';
   return String(result,1);
   #endif
}

String String::charAt( int at ) const
{
   if (at<0 || at>=length) return HX_CSTRING("");
   return fromCharCode(__s[at]);
}

void __hxcpp_bytes_of_string(Array<unsigned char> &outBytes,const String &inString)
{
   #ifdef HX_UTF8_STRINGS
   outBytes->__SetSize(inString.length);
   if (inString.length)
      memcpy(outBytes->GetBase(), inString.__s,inString.length);
   #else
   for(int i=0;i<inString.length;i++)
   {
      int c = inString.__s[i];
      if( c <= 0x7F )
         outBytes->push(c);
      else if( c <= 0x7FF )
      {
         outBytes->push( 0xC0 | (c >> 6) );
         outBytes->push( 0x80 | (c & 63) );
      }
      else if( c <= 0xFFFF )
      {
         outBytes->push( 0xE0 | (c >> 12) );
         outBytes->push( 0x80 | ((c >> 6) & 63) );
         outBytes->push( 0x80 | (c & 63) );
      }
      else
      {
         outBytes->push( 0xF0 | (c >> 18) );
         outBytes->push( 0x80 | ((c >> 12) & 63) );
         outBytes->push( 0x80 | ((c >> 6) & 63) );
         outBytes->push( 0x80 | (c & 63) );
      }
   }
   #endif
}

void __hxcpp_string_of_bytes(Array<unsigned char> &inBytes,String &outString,int pos,int len)
{
   #ifdef HX_UTF8_STRINGS
   outString = String( GCStringDup(inBytes->GetBase()+pos, len, 0), len);
   #else
   const unsigned char *ptr = (unsigned char *)inBytes->GetBase() + pos;
   const unsigned char *last = ptr + len;
   wchar_t *result = hx::NewString(len);
   wchar_t *out = result;

   // utf8-encode
   while( ptr < last )
   {
      *out++ = DecodeAdvanceUTF8(ptr);
   }
   int l = out - result;
   *out++ = '\0';

   outString = String(result,l);
   #endif
}

const char * String::__CStr() const
{
   #ifdef HX_UTF8_STRINGS
   return __s ? __s : (char *)"";
   #else
   Array<unsigned char> bytes(0,length+1);
   __hxcpp_bytes_of_string(bytes,*this);
	bytes.Add(0);
   char *result =  bytes->GetBase();
   if (result)
   {
      return  (char *)NewGCPrivate(result,bytes->length);
   }
   return (char *)"";
   #endif
}


namespace hx
{

wchar_t *ConvertToWChar(const char *inStr, int *ioLen)
{
   int len = ioLen ? *ioLen : strlen(inStr);

   wchar_t *result = (wchar_t *)NewGCPrivate(0,sizeof(wchar_t)*(len+1));
   int l = 0;

   unsigned char *b = (unsigned char *)inStr;
   for(int i=0;i<len;)
   {
      int c = b[i++];
      if (c==0) break;
      else if( c < 0x80 )
      {
        result[l++] = c;
      }
      else if( c < 0xE0 )
        result[l++] = ( ((c & 0x3F) << 6) | (b[i++] & 0x7F) );
      else if( c < 0xF0 )
      {
        int c2 = b[i++];
        result[l++] = ( ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | ( b[i++] & 0x7F) );
      }
      else
      {
        int c2 = b[i++];
        int c3 = b[i++];
        result[l++] = ( ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 << 6) & 0x7F) | (b[i++] & 0x7F) );
      }
   }
   result[l] = '\0';
   if (ioLen)
      *ioLen = l;
   return result;
}




}

const wchar_t * String::__WCStr() const
{
   #ifndef HX_UTF8_STRINGS
   return __s ? __s : L"";
   #else
   
   const unsigned char *ptr = (const unsigned char *)__s;
   const unsigned char *end = ptr + length;
   int idx = 0;
   while(ptr<end)
   {
      DecodeAdvanceUTF8(ptr);
      idx++;
   }

   wchar_t *result = (wchar_t *)NewGCPrivate(0,sizeof(wchar_t) * (idx+1) );
   ptr = (const unsigned char *)__s;
   idx = 0;
   while(ptr<end)
      result[idx++] = DecodeAdvanceUTF8(ptr);
   result[idx] = 0;
   return result;
   #endif
}



#ifdef ANDROID
bool my_wstrneq(const wchar_t *s1, const wchar_t *s2, int len)
{
   for(int i=0;i<len;i++)
      if (s1[i]!=s2[i])
        return false;
   return true;
}
#endif

Array<String> String::split(const String &inDelimiter) const
{
   int len = inDelimiter.length;
   int pos = 0;
   int last = 0;
   if (len==0)
   {
      // Special case of splitting into characters - use efficient code...
      int chars = length;
      Array<String> result(0,chars);
      int idx = 0;
      for(int i=0;i<chars; )
      {
         #ifdef HX_UTF8_STRINGS
         const unsigned char *start = (const unsigned char *)(__s + i);
         const unsigned char *ptr = start;
         int ch = DecodeAdvanceUTF8(ptr);
         int len =  ptr - start;
         result[idx++] = String( __s+i, len ).dup();
         i+=len;
         #else
         wchar_t *ptr = hx::NewString(1);
         ptr[0] = __s[i];
         ptr[1] = '\0';
         result[i] = String(ptr,1);
         i++;
         #endif
      }
      return result;
   }


   Array<String> result(0,1);
   while(pos+len <=length )
   {
      #ifdef HX_UTF8_STRINGS
         if (!strncmp(__s+pos,inDelimiter.__s,len))
      #else
         #ifdef ANDROID
         if (my_wstrneq(__s+pos,inDelimiter.__s,len))
         #else
         if (!wcsncmp(__s+pos,inDelimiter.__s,len))
         #endif
      #endif
      {
         result.Add( substr(last,pos-last) );
         pos += len;
         last = pos;
      }
      else
      {
         pos++;
      }
   }

   result.Add( substr(last,null()) );

   return result;
}

Dynamic CreateEmptyString() { return HX_CSTRING(""); }

Dynamic CreateString(DynamicArray inArgs)
{
   if (inArgs->__length()>0)
      return inArgs[0]->toString();
   return String();
}


String String::substr(int inFirst, Dynamic inLen) const
{
   int len = inLen == null() ? length : inLen->__ToInt();
   if (inFirst<0) inFirst += length;
   if (inFirst<0) inFirst = 0;
	if (len<0)
	{
		len += length;
		// This logic matches flash ....
		if (inFirst + len >=length)
			len = 0;
	}

   if (len<=0 || inFirst>=length)
		return HX_CSTRING("");

   if ((len+inFirst > length) ) len = length - inFirst;
   if (len==0)
      return HX_CSTRING("");

   HX_CHAR *ptr = hx::NewString(len);
   memcpy(ptr,__s+inFirst,len*sizeof(HX_CHAR));
   ptr[len] = 0;
   return String(ptr,len);
}

String String::operator+(String inRHS) const
{
   if (!__s) return HX_CSTRING("null") + inRHS;
   if (!length) return inRHS;
   if (!inRHS.__s) return *this + HX_CSTRING("null");
   if (!inRHS.length) return *this;
   int l = length + inRHS.length;
   HX_CHAR *result = hx::NewString(l);
   memcpy(result,__s,length*sizeof(HX_CHAR));
   memcpy(result+length,inRHS.__s,inRHS.length*sizeof(HX_CHAR));
   result[l] = '\0';
   return String(result,l);
}


String &String::operator+=(String inRHS)
{
   if (length==0)
   {
      *this = inRHS;
   }
   else if (inRHS.length>0)
   {
      int l = length + inRHS.length;
      HX_CHAR *s = hx::NewString(l);
      memcpy(s,__s,length*sizeof(HX_CHAR));
      memcpy(s+length,inRHS.__s,inRHS.length*sizeof(HX_CHAR));
      s[l] = '\0';
      __s = s;
      length = l;
   }
   return *this;
}


#define DEFINE_STRING_FUNC(func,array_list,dynamic_arg_list,arg_list,ARG_C) \
struct __String_##func : public hx::Object \
{ \
   bool __IsFunction() const { return true; } \
   String mThis; \
   __String_##func(const String &inThis) : mThis(inThis) { } \
   String toString() const{ return HX_CSTRING(#func); } \
   String __ToString() const{ return HX_CSTRING(#func); } \
	int __GetType() const { return vtFunction; } \
	void *__GetHandle() const { return const_cast<HX_CHAR *>(mThis.__s); } \
	int __ArgCount() const { return ARG_C; } \
   Dynamic __Run(const Array<Dynamic> &inArgs) \
   { \
      return mThis.func(array_list); return Dynamic(); \
   } \
   Dynamic __run(dynamic_arg_list) \
   { \
      return mThis.func(arg_list); return Dynamic(); \
   } \
	void __Mark(HX_MARK_PARAMS) { HX_MARK_STRING(mThis.__s); } \
	void  __SetThis(Dynamic inThis) { mThis = inThis; } \
}; \
Dynamic String::func##_dyn()  { return new __String_##func(*this);  }


#define DEFINE_STRING_FUNC0(func) DEFINE_STRING_FUNC(func,HX_ARR_LIST0,HX_DYNAMIC_ARG_LIST0,HX_ARG_LIST0,0)
#define DEFINE_STRING_FUNC1(func) DEFINE_STRING_FUNC(func,HX_ARR_LIST1,HX_DYNAMIC_ARG_LIST1,HX_ARG_LIST1,1)
#define DEFINE_STRING_FUNC2(func) DEFINE_STRING_FUNC(func,HX_ARR_LIST2,HX_DYNAMIC_ARG_LIST2,HX_ARG_LIST2,2)

DEFINE_STRING_FUNC1(charAt);
DEFINE_STRING_FUNC1(charCodeAt);
DEFINE_STRING_FUNC2(indexOf);
DEFINE_STRING_FUNC2(lastIndexOf);
DEFINE_STRING_FUNC1(split);
DEFINE_STRING_FUNC2(substr);
DEFINE_STRING_FUNC0(toLowerCase);
DEFINE_STRING_FUNC0(toUpperCase);
DEFINE_STRING_FUNC0(toString);

Dynamic String::__Field(const String &inString)
{
   if (HX_FIELD_EQ(inString,"length")) return length;
   if (HX_FIELD_EQ(inString,"charAt")) return charAt_dyn();
   if (HX_FIELD_EQ(inString,"charCodeAt")) return charCodeAt_dyn();
   if (HX_FIELD_EQ(inString,"indexOf")) return indexOf_dyn();
   if (HX_FIELD_EQ(inString,"lastIndexOf")) return lastIndexOf_dyn();
   if (HX_FIELD_EQ(inString,"split")) return split_dyn();
   if (HX_FIELD_EQ(inString,"substr")) return substr_dyn();
   if (HX_FIELD_EQ(inString,"toLowerCase")) return toLowerCase_dyn();
   if (HX_FIELD_EQ(inString,"toUpperCase")) return toUpperCase_dyn();
   if (HX_FIELD_EQ(inString,"toString")) return toString_dyn();
   return null();
}


static String sStringStatics[] = {
   HX_CSTRING("fromCharCode"),
   String(null())
};
static String sStringFields[] = {
   HX_CSTRING("length"),
   HX_CSTRING("charAt"),
   HX_CSTRING("charCodeAt"),
   HX_CSTRING("indexOf"),
   HX_CSTRING("lastIndexOf"),
   HX_CSTRING("split"),
   HX_CSTRING("substr"),
   HX_CSTRING("toLowerCase"),
   HX_CSTRING("toUpperCase"),
   HX_CSTRING("toString"),
   String(null())
};

STATIC_HX_DEFINE_DYNAMIC_FUNC1(String,fromCharCode,return )

namespace hx
{



#ifndef HX_WINDOWS
inline double _wtof(const wchar_t *inStr)
{
   #ifdef ANDROID
   char buf[101];
   int i;
   for(int i=0;i<100 && inStr[i];i++)
      buf[i] = inStr[i];
   buf[i] = '\0';
   return atof(buf);
   #else
   return wcstod(inStr,0);
   #endif
}

#ifdef ANDROID
int my_wtol(const wchar_t *inStr,wchar_t ** end, int inBase)
{
   char buf[101];
   int i;
   for(int i=0;i<100 && inStr[i];i++)
      buf[i] = inStr[i];
   buf[i] = '\0';
   char *cend = buf;
   int result = strtol(buf,&cend,inBase);
   *end = (wchar_t *)inStr + (cend-buf);
   return result;
}
#define wcstol my_wtol
#endif

inline int _wtoi(const wchar_t *inStr)
{
	wchar_t *end = 0;
	if (!inStr) return 0;
	long result = 0;
	if (inStr[0]=='0' && (inStr[1]=='x' || inStr[1]=='X'))
		result = wcstol(inStr,&end,16);
	else
		result = wcstol(inStr,&end,10);
	return result;
}
#endif



class StringData : public hx::Object
{
public:
   StringData(String inValue) : mValue(inValue) {};

   Class __GetClass() const { return __StringClass; }
   bool __Is(hx::Object *inClass) const { return dynamic_cast< StringData *>(inClass); }

   virtual int __GetType() const { return vtString; }
   String __ToString() const { return mValue; }
   String toString() { return mValue; }
   double __ToDouble() const
   {
      if (!mValue.__s) return 0;
      #ifdef HX_UTF8_STRINGS
      return atof(mValue.__s);
      #else
      return _wtof(mValue.__s);
      #endif
   }
   int __length() const { return mValue.length; }

   void __Mark(HX_MARK_PARAMS)
   {
      HX_MARK_MEMBER(mValue);
   }

   int __ToInt() const
   {
      if (!mValue.__s) return 0;
      #ifdef HX_UTF8_STRINGS
      return atoi(mValue.__s);
      #else
      return _wtoi(mValue.__s);
      #endif
   }

   int __Compare(const hx::Object *inRHS) const
   {
      return mValue.compare( const_cast<hx::Object*>(inRHS)->toString() );
   }

   Dynamic __Field(const String &inString)
   {
      return mValue.__Field(inString);
   }


   String mValue;
};

Class &GetStringClass() { return __StringClass; }

}

hx::Object *String::__ToObject() const { return new StringData(*this); }




void String::__boot()
{
   Static(__StringClass) = hx::RegisterClass(HX_CSTRING("String"),TCanCast<StringData>,sStringStatics, sStringFields,
           &CreateEmptyString, &CreateString, 0);
}





