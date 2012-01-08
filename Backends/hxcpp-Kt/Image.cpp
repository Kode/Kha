#include <hxcpp.h>

#ifndef INCLUDED_com_ktxsoftware_kha_Image
#include <com/ktxsoftware/kha/Image.h>
#endif
#ifndef INCLUDED_com_ktxsoftware_kha_backends_cpp_Image
#include <com/ktxsoftware/kha/backends/cpp/Image.h>
#endif
namespace com{
namespace ktxsoftware{
namespace kha{
namespace backends{
namespace cpp{

Void Image_obj::__construct(::String filename)
{
{
	image = Kt::Image(filename.c_str());
}
;
	return null();
}

Image_obj::~Image_obj() { }

Dynamic Image_obj::__CreateEmpty() { return  new Image_obj; }
hx::ObjectPtr< Image_obj > Image_obj::__new(::String filename)
{  hx::ObjectPtr< Image_obj > result = new Image_obj();
	result->__construct(filename);
	return result;}

Dynamic Image_obj::__Create(hx::DynamicArray inArgs)
{  hx::ObjectPtr< Image_obj > result = new Image_obj();
	result->__construct(inArgs[0]);
	return result;}

hx::Object *Image_obj::__ToInterface(const type_info &inType) {
	if (inType==typeid( ::com::ktxsoftware::kha::Image_obj)) return operator ::com::ktxsoftware::kha::Image_obj *();
	return super::__ToInterface(inType);
}

int Image_obj::getWidth( ){
	HX_SOURCE_PUSH("Image_obj::getWidth")
	HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Image.hx",8)
	return (int)image.Width();
}


HX_DEFINE_DYNAMIC_FUNC0(Image_obj,getWidth,return )

int Image_obj::getHeight( ){
	HX_SOURCE_PUSH("Image_obj::getHeight")
	HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Image.hx",12)
	return (int)image.Height();
}


HX_DEFINE_DYNAMIC_FUNC0(Image_obj,getHeight,return )

bool Image_obj::isAlpha( int x,int y){
	HX_SOURCE_PUSH("Image_obj::isAlpha")
	HX_SOURCE_POS("C:\\Users\\Robert\\Projekte\\Zool\\/Kha/Backends/Kt/com/ktxsoftware/kha/backends/cpp/Image.hx",16)
	return true;
}


HX_DEFINE_DYNAMIC_FUNC2(Image_obj,isAlpha,return )


Image_obj::Image_obj()
{
}

void Image_obj::__Mark(HX_MARK_PARAMS)
{
	HX_MARK_BEGIN_CLASS(Image);
	HX_MARK_END_CLASS();
}

Dynamic Image_obj::__Field(const ::String &inName)
{
	switch(inName.length) {
	case 7:
		if (HX_FIELD_EQ(inName,"isAlpha") ) { return isAlpha_dyn(); }
		break;
	case 8:
		if (HX_FIELD_EQ(inName,"getWidth") ) { return getWidth_dyn(); }
		break;
	case 9:
		if (HX_FIELD_EQ(inName,"getHeight") ) { return getHeight_dyn(); }
	}
	return super::__Field(inName);
}

Dynamic Image_obj::__SetField(const ::String &inName,const Dynamic &inValue)
{
	return super::__SetField(inName,inValue);
}

void Image_obj::__GetFields(Array< ::String> &outFields)
{
	super::__GetFields(outFields);
};

static ::String sStaticFields[] = {
	String(null()) };

static ::String sMemberFields[] = {
	HX_CSTRING("getWidth"),
	HX_CSTRING("getHeight"),
	HX_CSTRING("isAlpha"),
	String(null()) };

static void sMarkStatics(HX_MARK_PARAMS) {
};

Class Image_obj::__mClass;

void Image_obj::__register()
{
	Static(__mClass) = hx::RegisterClass(HX_CSTRING("com.ktxsoftware.kha.backends.cpp.Image"), hx::TCanCast< Image_obj> ,sStaticFields,sMemberFields,
	&__CreateEmpty, &__Create,
	&super::__SGetClass(), 0, sMarkStatics);
}

void Image_obj::__boot()
{
}

} // end namespace com
} // end namespace ktxsoftware
} // end namespace kha
} // end namespace backends
} // end namespace cpp
