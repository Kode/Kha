#ifndef HX_INTERFACE_H
#define HX_INTERFACE_H

namespace hx
{

class Interface : public hx::Object
{
public:
   // The following functions make use of : hx::Object *__GetRealObject();

	void __Mark(HX_MARK_PARAMS);
   hx::Object *__ToInterface(const type_info &);
	int __GetType();
	void *__GetHandle();
	hx::FieldRef __FieldRef(const ::String &);
	::String __ToString();
	int __ToInt();
	double __ToDouble();
	const char * __CStr();
	::String toString();
	bool __HasField(const ::String &);
	Dynamic __Field(const ::String &);
	Dynamic __IField(int);
	Dynamic __SetField(const ::String &,const Dynamic &);
	void __SetThis(Dynamic);
	void __GetFields(Array< ::String> &);
	Class __GetClass();
	int __Compare(const hx::Object *);

   /* No need for enum options - not in interfaces */
   /* No need for array options - not in interfaces */
   /* No need for function options - not in interfaces */
};

}

#endif

