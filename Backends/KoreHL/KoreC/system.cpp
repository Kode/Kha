#include <Kore/pch.h>
#include <Kore/System.h>
#include <hl.h>

extern "C" double hl_kore_get_time() {
	return Kore::System::time();
}

extern "C" int hl_kore_get_window_width(int window) {
	return Kore::System::windowWidth(window);
}

extern "C" int hl_kore_get_window_height(int window) {
	return Kore::System::windowHeight(window);
}

