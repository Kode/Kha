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
	int __GetType() const;
	void *__GetHandle() const;
	hx::FieldRef __FieldRef(const ::String &);
	::String __ToString() const;
	int __ToInt() const;
	double __ToDouble() const;
	const char * __CStr() const;
	::String toString();
	bool __HasField(const ::String &);
	Dynamic __Field(const ::String & HXCPP_EXTRA_FIELD_DECL);
	Dynamic __IField(int);
	Dynamic __SetField(const ::String &,const Dynamic & HXCPP_EXTRA_FIELD_DECL);
	void __SetThis(Dynamic);
	void __GetFields(Array< ::String> &);
	Class __GetClass() const;
	int __Compare(const hx::Object *) const;

   /* No need for enum options - not in interfaces */
   /* No need for array options - not in interfaces */
   /* No need for function options - not in interfaces */
};

}

#endif

