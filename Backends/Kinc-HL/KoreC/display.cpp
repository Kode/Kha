#include <kinc/display.h>

extern "C" void hl_kore_display_init() {
	kinc_display_init();
}

extern "C" int hl_kore_display_count() {
	return kinc_count_displays();
}

extern "C" int hl_kore_display_width(int index) {
	return kinc_display_current_mode(index).width;
}

extern "C" int hl_kore_display_height(int index) {
	return kinc_display_current_mode(index).height;
}

extern "C" int hl_kore_display_x(int index) {
	return kinc_display_current_mode(index).x;
}

extern "C" int hl_kore_display_y(int index) {
	return kinc_display_current_mode(index).y;
}

extern "C" bool hl_kore_display_is_primary(int index) {
	return kinc_primary_display() == index;
}

extern "C" int hl_kore_display_ppi() {
	return kinc_display_current_mode(kinc_primary_display()).pixels_per_inch;
}
