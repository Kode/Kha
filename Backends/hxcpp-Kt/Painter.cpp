#include <hxcpp.h>

#ifndef INCLUDED_com_ktxsoftware_kha_Image
#include <com/ktxsoftware/kha/Image.h>
#endif
#ifndef INCLUDED_com_ktxsoftware_kha_Painter
#include <com/ktxsoftware/kha/Painter.h>
#endif
#ifndef INCLUDED_com_ktxsoftware_kha_backends_cpp_Painter
#include <com/ktxsoftware/kha/backends/cpp/Painter.h>
#endif

#include <com/ktxsoftware/kha/backends/cpp/Image.h>
#include <Kt/stdafx.h>
#include <Kt/Graphics/Painter.h>

extern Kt::Painter* haxePainter;

namespace com{
namespace ktxsoftware{
namespace kha{
namespace backends{
namespace cpp{

Void Painter_obj::__construct()
{
{
	HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Painter.hx",8)
	this->tx = (int)0;
	HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Painter.hx",9)
	this->ty = (int)0;
}
;
	return null();
}

Painter_obj::~Painter_obj() { }

Dynamic Painter_obj::__CreateEmpty() { return  new Painter_obj; }
hx::ObjectPtr< Painter_obj > Painter_obj::__new()
{  hx::ObjectPtr< Painter_obj > result = new Painter_obj();
	result->__construct();
	return result;}

Dynamic Painter_obj::__Create(hx::DynamicArray inArgs)
{  hx::ObjectPtr< Painter_obj > result = new Painter_obj();
	result->__construct();
	return result;}

Void Painter_obj::begin( ){
{
		HX_SOURCE_PUSH("Painter_obj::begin")
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Painter_obj,begin,(void))

Void Painter_obj::end( ){
{
		HX_SOURCE_PUSH("Painter_obj::end")
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC0(Painter_obj,end,(void))

Void Painter_obj::translate( double x,double y){
{
		HX_SOURCE_PUSH("Painter_obj::translate")
		HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Painter.hx",21)
		this->tx = x;
		HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Painter.hx",22)
		this->ty = y;
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC2(Painter_obj,translate,(void))

Void Painter_obj::drawImage2( ::com::ktxsoftware::kha::Image image,double sx,double sy,double sw,double sh,double dx,double dy,double dw,double dh){
{
		HX_SOURCE_PUSH("Painter_obj::drawImage2")
		::com::ktxsoftware::kha::backends::cpp::Image_obj* img = dynamic_cast< ::com::ktxsoftware::kha::backends::cpp::Image_obj*>(image->__GetRealObject());
		haxePainter->drawSubImage(img->image, tx + dx, ty + dy, dw, dh, sx, sy, sw, sh);
	}
return null();
}


HX_DEFINE_DYNAMIC_FUNC9(Painter_obj,drawImage2,(void))


Painter_obj::Painter_obj()
{
}

void Painter_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(Painter);
	HX_MARK_MEMBER_NAME(tx,"tx");
	HX_MARK_MEMBER_NAME(ty,"ty");
	super::__Mark(HX_MARK_ARG);
	HX_MARK_END_CLASS();
}

Dynamic Painter_obj::__Field(const ::String &inName)
{
	switch(inName.length) {
	case 2:
		if (HX_FIELD_EQ(inName,"tx") ) { return tx; }
		if (HX_FIELD_EQ(inName,"ty") ) { return ty; }
		break;
	case 3:
		if (HX_FIELD_EQ(inName,"end") ) { return end_dyn(); }
		break;
	case 5:
		if (HX_FIELD_EQ(inName,"begin") ) { return begin_dyn(); }
		break;
	case 9:
		if (HX_FIELD_EQ(inName,"translate") ) { return translate_dyn(); }
		break;
	case 10:
		if (HX_FIELD_EQ(inName,"drawImage2") ) { return drawImage2_dyn(); }
	}
	return super::__Field(inName);
}

Dynamic Painter_obj::__SetField(const ::String &inName,const Dynamic &inValue)
{
	switch(inName.length) {
	case 2:
		if (HX_FIELD_EQ(inName,"tx") ) { tx=inValue.Cast< double >(); return inValue; }
		if (HX_FIELD_EQ(inName,"ty") ) { ty=inValue.Cast< double >(); return inValue; }
	}
	return super::__SetField(inName,inValue);
}

void Painter_obj::__GetFields(Array< ::String> &outFields)
{
	outFields->push(HX_CSTRING("tx"));
	outFields->push(HX_CSTRING("ty"));
	super::__GetFields(outFields);
};

static ::String sStaticFields[] = {
	String(null()) };

static ::String sMemberFields[] = {
	HX_CSTRING("tx"),
	HX_CSTRING("ty"),
	HX_CSTRING("begin"),
	HX_CSTRING("end"),
	HX_CSTRING("translate"),
	HX_CSTRING("drawImage2"),
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
};

Class Painter_obj::__mClass;

void Painter_obj::__register()
{
	Static(__mClass) = hx::RegisterClass(HX_CSTRING("com.ktxsoftware.kha.backends.cpp.Painter"), hx::TCanCast< Painter_obj> ,sStaticFields,sMemberFields,
	&__CreateEmpty, &__Create,
	&super::__SGetClass(), 0, sMarkStatics);
}

void Painter_obj::__boot()
{
}

} // end namespace com
} // end namespace ktxsoftware
} // end namespace kha
} // end namespace backends
} // end namespace cpp
