#include <hxcpp.h>

namespace hx
{

void Interface::__Mark(HX_MARK_PARAMS)
{
	Object *obj = __GetRealObject();
	HX_MARK_OBJECT(obj);
}

hx::Object *Interface::__ToInterface(const type_info &i)
{
	return __GetRealObject()->__ToInterface(i);
}
int Interface::__GetType() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__GetType();
}

void *Interface::__GetHandle() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__GetHandle();
}

hx::FieldRef Interface::__FieldRef(const ::String &s)
{
	return __GetRealObject()->__FieldRef(s);
}

::String Interface::__ToString() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__ToString();
}

int Interface::__ToInt() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__ToInt();
}

double Interface::__ToDouble() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__ToDouble();
}

const char * Interface::__CStr() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__CStr();
}

::String Interface::toString()
{
	return __GetRealObject()->toString();
}

bool Interface::__HasField(const ::String &s)
{
	return __GetRealObject()->__HasField(s);
}

Dynamic Interface::__Field(const ::String &s HXCPP_EXTRA_FIELD_DECL)
{
	return __GetRealObject()->__Field(s HXCPP_EXTRA_FIELD_CALL);
}

Dynamic Interface::__IField(int i)
{
	return __GetRealObject()->__IField( i);
}

Dynamic Interface::__SetField(const ::String &s,const Dynamic &d HXCPP_EXTRA_FIELD_DECL)
{
	return __GetRealObject()->__SetField(s,d HXCPP_EXTRA_FIELD_CALL);
}

void Interface::__SetThis(Dynamic d)
{
	return __GetRealObject()->__SetThis(d);
}

void Interface::__GetFields(Array< ::String> &a)
{
	return __GetRealObject()->__GetFields(a);
}

Class Interface::__GetClass() const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__GetClass();
}

int Interface::__Compare(const hx::Object *o) const
{
	return const_cast<Interface *>(this)->__GetRealObject()->__Compare(o);
}



} // end namespace hx
