#include <Kore/pch.h>
#include <Kore/System.h>
#include <Kore/Log.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/Mouse.h>
#include <hl.h>

extern "C" void hl_kore_log(vbyte *v) {
	Kore::log(Kore::Info, (char*)v);
}

extern "C" double hl_kore_get_time() {
	return Kore::System::time();
}

extern "C" int hl_kore_get_window_width(int window) {
	return Kore::System::windowWidth(window);
}

extern "C" int hl_kore_get_window_height(int window) {
	return Kore::System::windowHeight(window);
}

typedef void(*FN_KEY_DOWN)(Kore::KeyCode);
typedef void(*FN_KEY_UP)(Kore::KeyCode);
typedef void(*FN_KEY_PRESS)(wchar_t);

extern "C" void hl_kore_register_keyboard(vclosure *keyDown, vclosure *keyUp, vclosure *keyPress) {
	Kore::Keyboard::the()->KeyDown = *((FN_KEY_DOWN*)(&keyDown->fun));
	Kore::Keyboard::the()->KeyUp = *((FN_KEY_UP*)(&keyUp->fun));
	Kore::Keyboard::the()->KeyPress = *((FN_KEY_PRESS*)(&keyPress->fun));
}

typedef void(*FN_MOUSE_DOWN)(int, int, int, int);
typedef void(*FN_MOUSE_UP)(int, int, int, int);
typedef void(*FN_MOUSE_MOVE)(int, int, int, int, int);

extern "C" void hl_kore_register_mouse(vclosure *mouseDown, vclosure *mouseUp, vclosure *mouseMove) {
	Kore::Mouse::the()->Press = *((FN_MOUSE_DOWN*)(&mouseDown->fun));
	Kore::Mouse::the()->Release = *((FN_MOUSE_UP*)(&mouseUp->fun));
	Kore::Mouse::the()->Move = *((FN_MOUSE_MOVE*)(&mouseMove->fun));
}
