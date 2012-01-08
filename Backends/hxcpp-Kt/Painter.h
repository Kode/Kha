#ifndef INCLUDED_com_ktxsoftware_kha_backends_cpp_Painter
#define INCLUDED_com_ktxsoftware_kha_backends_cpp_Painter

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <com/ktxsoftware/kha/Painter.h>
HX_DECLARE_CLASS3(com,ktxsoftware,kha,Image)
HX_DECLARE_CLASS3(com,ktxsoftware,kha,Painter)
HX_DECLARE_CLASS5(com,ktxsoftware,kha,backends,cpp,Painter)
namespace com{
namespace ktxsoftware{
namespace kha{
namespace backends{
namespace cpp{


class Painter_obj : public ::com::ktxsoftware::kha::Painter_obj{
	public:
		typedef ::com::ktxsoftware::kha::Painter_obj super;
		typedef Painter_obj OBJ_;
		Painter_obj();
		Void __construct();

	public:
		static hx::ObjectPtr< Painter_obj > __new();
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		~Painter_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		::String __ToString() const { return HX_CSTRING("Painter"); }

		double tx; /* REM */ 
		double ty; /* REM */ 
		virtual Void begin( );
		Dynamic begin_dyn();

		virtual Void end( );
		Dynamic end_dyn();

		virtual Void translate( double x,double y);
		Dynamic translate_dyn();

		virtual Void drawImage2( ::com::ktxsoftware::kha::Image image,double sx,double sy,double sw,double sh,double dx,double dy,double dw,double dh);
		Dynamic drawImage2_dyn();

};

} // end namespace com
} // end namespace ktxsoftware
} // end namespace kha
} // end namespace backends
} // end namespace cpp

#endif /* INCLUDED_com_ktxsoftware_kha_backends_cpp_Painter */ 
