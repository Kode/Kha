#include <kinc/display.h>

void hl_kinc_display_init(void) {
	kinc_display_init();
}

int hl_kinc_display_count(void) {
	return kinc_count_displays();
}

int hl_kinc_display_width(int index) {
	return kinc_display_current_mode(index).width;
}

int hl_kinc_display_height(int index) {
	return kinc_display_current_mode(index).height;
}

int hl_kinc_display_x(int index) {
	return kinc_display_current_mode(index).x;
}

int hl_kinc_display_y(int index) {
	return kinc_display_current_mode(index).y;
}

bool hl_kinc_display_is_primary(int index) {
	return kinc_primary_display() == index;
}

int hl_kinc_display_ppi(void) {
	return kinc_display_current_mode(kinc_primary_display()).pixels_per_inch;
}
