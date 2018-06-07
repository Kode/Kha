
#include <Kore/Display.h>

extern "C" int hl_kore_display_count() {
	return Kore::Display::count();
}

extern "C" int hl_kore_display_width(int index) {
	return Kore::Display::width(index);
}

extern "C" int hl_kore_display_height(int index) {
	return Kore::Display::height(index);
}

extern "C" int hl_kore_display_x(int index) {
	return Kore::Display::x(index);
}

extern "C" int hl_kore_display_y(int index) {
	return Kore::Display::y(index);
}

extern "C" bool hl_kore_display_is_primary(int index) {
	return Kore::Display::isPrimary(index);
}
