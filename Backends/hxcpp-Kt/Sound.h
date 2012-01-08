#ifndef INCLUDED_com_ktxsoftware_kha_backends_cpp_Sound
#define INCLUDED_com_ktxsoftware_kha_backends_cpp_Sound

#ifndef HXCPP_H
#include <hxcpp.h>
#endif

#include <com/ktxsoftware/kha/Sound.h>
HX_DECLARE_CLASS3(com,ktxsoftware,kha,Sound)
HX_DECLARE_CLASS5(com,ktxsoftware,kha,backends,cpp,Sound)

#include <Kt/stdafx.h>
#include <Kt/Sound/Sound.h>

namespace com{
namespace ktxsoftware{
namespace kha{
namespace backends{
namespace cpp{


class Sound_obj : public hx::Object{
	public:
		typedef hx::Object super;
		typedef Sound_obj OBJ_;
		Sound_obj();
		Void __construct(::String filename);

	public:
		static hx::ObjectPtr< Sound_obj > __new(::String filename);
		static Dynamic __CreateEmpty();
		static Dynamic __Create(hx::DynamicArray inArgs);
		~Sound_obj();

		HX_DO_RTTI;
		static void __boot();
		static void __register();
		void __Mark(HX_MARK_PARAMS);
		inline operator ::com::ktxsoftware::kha::Sound_obj *()
			{ return new ::com::ktxsoftware::kha::Sound_delegate_< Sound_obj >(this); }
		hx::Object *__ToInterface(const type_info &inType);
		::String __ToString() const { return HX_CSTRING("Sound"); }

		virtual Void play( );
		Dynamic play_dyn();

		virtual Void stop( );
		Dynamic stop_dyn();
		Kt::Sound::SoundHandle* sound;
};

} // end namespace com
} // end namespace ktxsoftware
} // end namespace kha
} // end namespace backends
} // end namespace cpp

#endif /* INCLUDED_com_ktxsoftware_kha_backends_cpp_Sound */ 
