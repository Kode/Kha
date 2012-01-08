#include <hxcpp.h>

#ifndef INCLUDED_com_ktxsoftware_kha_Sound
#include <com/ktxsoftware/kha/Sound.h>
#endif
#ifndef INCLUDED_com_ktxsoftware_kha_backends_cpp_Sound
#include <com/ktxsoftware/kha/backends/cpp/Sound.h>
#endif
namespace com{
namespace ktxsoftware{
namespace kha{
namespace backends{
namespace cpp{

Void Sound_obj::__construct(::String filename)
{
{
	sound = new Kt::Sound::SoundHandle(Kt::Text(filename.c_str()) + ".wav", false);
}
;
	return null();
}

Sound_obj::~Sound_obj() { }

Dynamic Sound_obj::__CreateEmpty() { return  new Sound_obj; }
hx::ObjectPtr< Sound_obj > Sound_obj::__new(::String filename)
{  hx::ObjectPtr< Sound_obj > result = new Sound_obj();
	result->__construct(filename);
	return result;}

Dynamic Sound_obj::__Create(hx::DynamicArray inArgs)
{  hx::ObjectPtr< Sound_obj > result = new Sound_obj();
	result->__construct(inArgs[0]);
	return result;}

hx::Object *Sound_obj::__ToInterface(const type_info &inType) {
	if (inType==typeid( ::com::ktxsoftware::kha::Sound_obj)) return operator ::com::ktxsoftware::kha::Sound_obj *();
	return super::__ToInterface(inType);
}

Void Sound_obj::play( ){
{
		HX_SOURCE_PUSH("Sound_obj::play")
		sound->play();
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Sound_obj,play,(void))

Void Sound_obj::stop( ){
{
		HX_SOURCE_PUSH("Sound_obj::stop")
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Sound_obj,stop,(void))


Sound_obj::Sound_obj()
{
}

void Sound_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(Sound);
	HX_MARK_END_CLASS();
}

Dynamic Sound_obj::__Field(const ::String &inName)
{
	switch(inName.length) {
	case 4:
		if (HX_FIELD_EQ(inName,"play") ) { return play_dyn(); }
		if (HX_FIELD_EQ(inName,"stop") ) { return stop_dyn(); }
	}
	return super::__Field(inName);
}

Dynamic Sound_obj::__SetField(const ::String &inName,const Dynamic &inValue)
{
	return super::__SetField(inName,inValue);
}

void Sound_obj::__GetFields(Array< ::String> &outFields)
{
	super::__GetFields(outFields);
};

static ::String sStaticFields[] = {
	String(null()) };

static ::String sMemberFields[] = {
	HX_CSTRING("play"),
	HX_CSTRING("stop"),
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
};

Class Sound_obj::__mClass;

void Sound_obj::__register()
{
	Static(__mClass) = hx::RegisterClass(HX_CSTRING("com.ktxsoftware.kha.backends.cpp.Sound"), hx::TCanCast< Sound_obj> ,sStaticFields,sMemberFields,
	&__CreateEmpty, &__Create,
	&super::__SGetClass(), 0, sMarkStatics);
}

void Sound_obj::__boot()
{
}

} // end namespace com
} // end namespace ktxsoftware
} // end namespace kha
} // end namespace backends
} // end namespace cpp
