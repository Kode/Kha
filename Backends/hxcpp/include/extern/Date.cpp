
#include <time.h>
#include <stdio.h>
#include <memory.h>


class hxDate : public Date_obj
{
   public:
      hxDate(time_t inTime = 0 ) : mTime(inTime)  {  }

   Void __construct(Int year,Int month,Int day,Int hour,Int min,Int sec)
   {
      struct tm time;
      time.tm_year = year-1900;
      time.tm_mon = month;
      time.tm_mday = day;
      time.tm_hour = hour;
      time.tm_min = min;
      time.tm_sec = sec;
      time.tm_isdst = -1;
      mTime = mktime(&time);
		return null();
   }
   struct tm &time()
   {
      struct tm *lt = localtime(&mTime);
      if (!lt)
         throw Dynamic(L"Invalid local time");
      return *lt;
   }

   virtual Float getTime( ) { return mTime; }
   virtual Int getHours( ) { return time().tm_hour; }
   virtual Int getMinutes( ) { return time().tm_min; }
   virtual Int getSeconds( ) { return time().tm_sec; }
   virtual Int getFullYear( ) { return time().tm_year + 1900; }
   virtual Int getMonth( ) { return time().tm_mon; }
   virtual Int getDate( ) { return time().tm_mday; }
   virtual Int getDay( ) { return time().tm_wday; }
   virtual String toString( )
   {
      int m = getMonth() + 1;
      int d = getDate();
      int h = getHours();
      int mi = getMinutes();
      int s = getSeconds();
      return String(getFullYear())
         +L"-"+String( m < 10 ? String(L"0",1)+m : String(m) )
         +L"-"+String( d < 10 ? String(L"0",1)+d : String(d) )
         +L" "+String( h < 10 ? String(L"0",1)+h : String(h) )
         +L":"+String( mi < 10 ? String(L"0",1)+mi : String(mi) )
         +L":"+String( s < 10 ? String(L"0",1)+s : String(s) );
   }

   time_t mTime;
};


Dynamic Date_obj::__CreateEmpty() { return new hxDate; }

void Date_obj::__boot() { }

Date Date_obj::now( ) { return new hxDate( (int)time(NULL) ); }
Date Date_obj::fromTime( Float t) { return new hxDate(); }
Date Date_obj::fromString( String s) { return new hxDate(); }

