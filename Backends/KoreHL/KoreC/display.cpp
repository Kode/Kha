#include <Kore/pch.h>
#include <Kore/Display.h>
#include <Kore/System.h>

extern "C" int hl_kore_display_count() {
	return Kore::Display::count();
}

extern "C" int hl_kore_display_width(int index) {
	return Kore::Display::get(index)->width();
}

extern "C" int hl_kore_display_height(int index) {
	return Kore::Display::get(index)->height();
}

extern "C" int hl_kore_display_x(int index) {
	return Kore::Display::get(index)->x();
}

extern "C" int hl_kore_display_y(int index) {
	return Kore::Display::get(index)->y();
}

extern "C" bool hl_kore_display_is_primary(int index) {
	return Kore::Display::get(index) == Kore::Display::primary();
}

extern "C" int hl_kore_display_ppi() {
	return Kore::Display::primary()->pixelsPerInch();
}
