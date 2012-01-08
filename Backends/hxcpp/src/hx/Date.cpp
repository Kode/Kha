#include <hxcpp.h>

#include <time.h>
//#include <hxMacros.h>


double __hxcpp_new_date(int inYear,int inMonth,int inDay,int inHour, int inMin, int inSeconds)
{
   struct tm time;
   time.tm_year = inYear;

	time.tm_isdst = -1;
   time.tm_year = inYear - 1900;
   time.tm_mon = inMonth;
   time.tm_mday = inDay;
   time.tm_hour = inHour;
   time.tm_min = inMin;
   time.tm_sec = inSeconds;

   return mktime(&time);
}

int __hxcpp_get_hours(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_hour;
}
int __hxcpp_get_minutes(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_min;
}
int __hxcpp_get_seconds(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_sec;
}
int __hxcpp_get_year(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_year + 1900;
}
int __hxcpp_get_month(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_mon;
}
int __hxcpp_get_date(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_mday;
}
int __hxcpp_get_day(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
   return time->tm_wday;
}
double __hxcpp_date_now()
{
   time_t t = time(NULL);
   return t;
}
String __hxcpp_to_string(double inSeconds)
{
   time_t t = (time_t)inSeconds;
   struct tm *time = localtime(&t);
#ifndef HX_UTF8_STRINGS
   wchar_t buf[100];
   wcsftime(buf,100,L"%Y-%m-%d %H:%M:%S", time);
#else
   char buf[100];
   strftime(buf,100,"%Y-%m-%d %H:%M:%S", time);
#endif
   return String(buf).dup();
}

