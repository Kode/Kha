#include <hxcpp.h>

#ifndef INCLUDED_com_ktxsoftware_kha_Music
#include <com/ktxsoftware/kha/Music.h>
#endif
#ifndef INCLUDED_com_ktxsoftware_kha_backends_cpp_Music
#include <com/ktxsoftware/kha/backends/cpp/Music.h>
#endif
namespace com{
namespace ktxsoftware{
namespace kha{
namespace backends{
namespace cpp{

Void Music_obj::__construct(::String filename)
{
{
	music = Kt::Text(filename.c_str());
}
;
	return null();
}

Music_obj::~Music_obj() { }

Dynamic Music_obj::__CreateEmpty() { return  new Music_obj; }
hx::ObjectPtr< Music_obj > Music_obj::__new(::String filename)
{  hx::ObjectPtr< Music_obj > result = new Music_obj();
	result->__construct(filename);
	return result;}

Dynamic Music_obj::__Create(hx::DynamicArray inArgs)
{  hx::ObjectPtr< Music_obj > result = new Music_obj();
	result->__construct(inArgs[0]);
	return result;}

hx::Object *Music_obj::__ToInterface(const type_info &inType) {
	if (inType==typeid( ::com::ktxsoftware::kha::Music_obj)) return operator ::com::ktxsoftware::kha::Music_obj *();
	return super::__ToInterface(inType);
}

Void Music_obj::start( ){
{
		HX_SOURCE_PUSH("Music_obj::start")
		Kt::Music::play(music);
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Music_obj,start,(void))

Void Music_obj::stop( ){
{
		HX_SOURCE_PUSH("Music_obj::stop")
		Kt::Music::stop();
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Music_obj,stop,(void))

Void Music_obj::update( ){
{
		HX_SOURCE_PUSH("Music_obj::update")
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Music_obj,update,(void))


Music_obj::Music_obj()
{
}

void Music_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(Music);
	HX_MARK_END_CLASS();
}

Dynamic Music_obj::__Field(const ::String &inName)
{
	switch(inName.length) {
	case 4:
		if (HX_FIELD_EQ(inName,"stop") ) { return stop_dyn(); }
		break;
	case 5:
		if (HX_FIELD_EQ(inName,"start") ) { return start_dyn(); }
		break;
	case 6:
		if (HX_FIELD_EQ(inName,"update") ) { return update_dyn(); }
	}
	return super::__Field(inName);
}

Dynamic Music_obj::__SetField(const ::String &inName,const Dynamic &inValue)
{
	return super::__SetField(inName,inValue);
}

void Music_obj::__GetFields(Array< ::String> &outFields)
{
	super::__GetFields(outFields);
};

static ::String sStaticFields[] = {
	String(null()) };

static ::String sMemberFields[] = {
	HX_CSTRING("start"),
	HX_CSTRING("stop"),
	HX_CSTRING("update"),
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
};

Class Music_obj::__mClass;

void Music_obj::__register()
{
	Static(__mClass) = hx::RegisterClass(HX_CSTRING("com.ktxsoftware.kha.backends.cpp.Music"), hx::TCanCast< Music_obj> ,sStaticFields,sMemberFields,
	&__CreateEmpty, &__Create,
	&super::__SGetClass(), 0, sMarkStatics);
}

void Music_obj::__boot()
{
}

} // end namespace com
} // end namespace ktxsoftware
} // end namespace kha
} // end namespace backends
} // end namespace cpp
