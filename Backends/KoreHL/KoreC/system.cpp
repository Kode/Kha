#include <Kore/pch.h>
#include <Kore/System.h>
#include <Kore/Log.h>
#include <Kore/Input/Keyboard.h>
#include <Kore/Input/Mouse.h>
#include <Kore/Input/Gamepad.h>
#include <Kore/Input/Surface.h>
#include <Kore/Input/Pen.h>
#include <Kore/Input/Sensor.h>
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

extern "C" vbyte* hl_kore_get_system_id() {
	return NULL;
	// return (vbyte*)Kore::System::systemId();
}

extern "C" void hl_kore_request_shutdown() {
	return Kore::System::stop();
}

extern "C" void hl_kore_mouse_lock(int windowId) {
	Kore::Mouse::the()->lock(windowId);
}

extern "C" void hl_kore_mouse_unlock(int windowId) {
	Kore::Mouse::the()->unlock(windowId);
}

extern "C" bool hl_kore_can_lock_mouse(int windowId) {
	return Kore::Mouse::the()->canLock(windowId);
}

extern "C" bool hl_kore_is_mouse_locked(int windowId) {
	return Kore::Mouse::the()->isLocked(windowId);
}

extern "C" void hl_kore_show_mouse(bool show) {
	Kore::Mouse::the()->show(show);
}

extern "C" bool hl_kore_system_is_fullscreen() {
	return false; //Kore::System::isFullscreen();
}

extern "C" void hl_kore_system_request_fullscreen() {
	//Kore::System::changeResolution(Kore::System::desktopWidth(), Kore::System::desktopHeight(), true);
}

extern "C" void hl_kore_system_exit_fullscreen(int previousWidth, int previousHeight) {
	//Kore::System::changeResolution(previousWidth, previousHeight, false);
}

extern "C" void hl_kore_system_change_resolution(int width, int height) {
	//Kore::System::changeResolution(width, height, false);
}

extern "C" void hl_kore_system_set_keepscreenon(bool on) {
	Kore::System::setKeepScreenOn(on);
}

extern "C" void hl_kore_system_load_url(vbyte* url) {
	Kore::System::loadURL((char*)url);
}

// const char* getGamepadId(int index);

extern "C" vbyte* hl_kore_get_gamepad_id(int index) {
	return NULL;
	// return (vbyte*)getGamepadId(index);
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
typedef void(*FN_MOUSE_WHEEL)(int, int);

extern "C" void hl_kore_register_mouse(vclosure *mouseDown, vclosure *mouseUp, vclosure *mouseMove, vclosure *mouseWheel) {
	Kore::Mouse::the()->Press = *((FN_MOUSE_DOWN*)(&mouseDown->fun));
	Kore::Mouse::the()->Release = *((FN_MOUSE_UP*)(&mouseUp->fun));
	Kore::Mouse::the()->Move = *((FN_MOUSE_MOVE*)(&mouseMove->fun));
	Kore::Mouse::the()->Scroll = *((FN_MOUSE_WHEEL*)(&mouseWheel->fun));
}

typedef void(*FN_PEN_DOWN)(int, int, int, float);
typedef void(*FN_PEN_UP)(int, int, int, float);
typedef void(*FN_PEN_MOVE)(int, int, int, float);

extern "C" void hl_kore_register_pen(vclosure *penDown, vclosure *penUp, vclosure *penMove) {
	Kore::Pen::the()->Press = *((FN_PEN_DOWN*)(&penDown->fun));
	Kore::Pen::the()->Release = *((FN_PEN_UP*)(&penUp->fun));
	Kore::Pen::the()->Move = *((FN_PEN_MOVE*)(&penMove->fun));
}

typedef void(*FN_GAMEPAD_AXIS)(int, float);
typedef void(*FN_GAMEPAD_BUTTON)(int, float);

extern "C" void hl_kore_register_gamepad(int index, vclosure *gamepadAxis, vclosure *gamepadButton) {
	Kore::Gamepad::get(index)->Axis = *((FN_GAMEPAD_AXIS*)(&gamepadAxis->fun));
	Kore::Gamepad::get(index)->Button = *((FN_GAMEPAD_BUTTON*)(&gamepadButton->fun));
}

typedef void(*FN_TOUCH_START)(int, int, int);
typedef void(*FN_TOUCH_END)(int, int, int);
typedef void(*FN_TOUCH_MOVE)(int, int, int);

extern "C" void hl_kore_register_surface(vclosure *touchStart, vclosure *touchEnd, vclosure *touchMove) {
	Kore::Surface::the()->TouchStart = *((FN_TOUCH_START*)(&touchStart->fun));
	Kore::Surface::the()->TouchEnd = *((FN_TOUCH_END*)(&touchEnd->fun));
	Kore::Surface::the()->Move = *((FN_TOUCH_MOVE*)(&touchMove->fun));
}

typedef void(*FN_SENSOR_ACCELEROMETER)(float, float, float);
typedef void(*FN_SENSOR_GYROSCOPE)(float, float, float);

extern "C" void hl_kore_register_sensor(vclosure *accelerometerChanged, vclosure *gyroscopeChanged) {
	Kore::Sensor::the(Kore::SensorAccelerometer)->Changed = *((FN_SENSOR_ACCELEROMETER*)(&accelerometerChanged->fun));
	Kore::Sensor::the(Kore::SensorGyroscope)->Changed = *((FN_SENSOR_GYROSCOPE*)(&gyroscopeChanged->fun));
}

// typedef void(*FN_CB_ORIENTATION)(int);
typedef void(*FN_CB_FOREGROUND)();
typedef void(*FN_CB_RESUME)();
typedef void(*FN_CB_PAUSE)();
typedef void(*FN_CB_BACKGROUND)();
typedef void(*FN_CB_SHUTDOWN)();

extern "C" void hl_kore_register_callbacks(vclosure *foreground, vclosure *resume, vclosure *pause, vclosure *background, vclosure *shutdown) {
	// Kore::System::setOrientationCallback(orientation);
	Kore::System::setForegroundCallback(*((FN_CB_FOREGROUND*)(&foreground->fun)));
	Kore::System::setResumeCallback(*((FN_CB_RESUME*)(&resume->fun)));
	Kore::System::setPauseCallback(*((FN_CB_PAUSE*)(&pause->fun)));
	Kore::System::setBackgroundCallback(*((FN_CB_BACKGROUND*)(&background->fun)));
	Kore::System::setShutdownCallback(*((FN_CB_SHUTDOWN*)(&shutdown->fun)));
}

typedef void(*FN_CB_DROPFILES)(wchar_t*);

extern "C" void hl_kore_register_dropfiles(vclosure *dropFiles) {
	// todo: string convert
	// Kore::System::setDropFilesCallback(*((FN_CB_DROPFILES*)(&dropFiles->fun)));
}

typedef char*(*FN_CB_COPY)();
typedef char*(*FN_CB_CUT)();
typedef void(*FN_CB_PASTE)(char*);

extern "C" void hl_kore_register_copycutpaste(vclosure *copy, vclosure *cut, vclosure *paste) {
	// todo: string convert
	// Kore::System::setCopyCallback(*((FN_CB_COPY*)(&copy->fun)));
	// Kore::System::setCutCallback(*((FN_CB_CUT*)(&cut->fun)));
	// Kore::System::setPasteCallback(*((FN_CB_PASTE*)(&paste->fun)));
}

extern "C" const char *hl_kore_video_format() {
	return Kore::System::videoFormats()[0];
}
