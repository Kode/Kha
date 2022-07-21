#include <kinc/input/acceleration.h>
#include <kinc/input/gamepad.h>
#include <kinc/input/keyboard.h>
#include <kinc/input/mouse.h>
#include <kinc/input/pen.h>
#include <kinc/input/rotation.h>
#include <kinc/input/surface.h>
#include <kinc/log.h>
#include <kinc/system.h>
#include <kinc/video.h>
#include <kinc/window.h>

#include <hl.h>

void hl_kinc_log(vbyte *v) {
	kinc_log(KINC_LOG_LEVEL_INFO, (char *)v);
}

double hl_kinc_get_time(void) {
	return kinc_time();
}

int hl_kinc_get_window_width(int window) {
	return kinc_window_width(window);
}

int hl_kinc_get_window_height(int window) {
	return kinc_window_height(window);
}

vbyte *hl_kinc_get_system_id(void) {
	return (vbyte *)kinc_system_id();
}

void hl_kinc_vibrate(int ms) {
	kinc_vibrate(ms);
}

vbyte *hl_kinc_get_language(void) {
	return (vbyte *)kinc_language();
}

void hl_kinc_request_shutdown(void) {
	kinc_stop();
}

void hl_kinc_mouse_lock(int windowId) {
	kinc_mouse_lock(windowId);
}

void hl_kinc_mouse_unlock(void) {
	kinc_mouse_unlock();
}

bool hl_kinc_can_lock_mouse(void) {
	return kinc_mouse_can_lock();
}

bool hl_kinc_is_mouse_locked(void) {
	return kinc_mouse_is_locked();
}

void hl_kinc_show_mouse(bool show) {
	if (show) {
		kinc_mouse_show();
	}
	else {
		kinc_mouse_hide();
	}
}

bool hl_kinc_system_is_fullscreen(void) {
	return false; // kinc_is_fullscreen();
}

void hl_kinc_system_request_fullscreen(void) {
	// kinc_change_resolution(display_width(), display_height(), true);
}

void hl_kinc_system_exit_fullscreen(int previousWidth, int previousHeight) {
	// kinc_change_resolution(previousWidth, previousHeight, false);
}

void hl_kinc_system_change_resolution(int width, int height) {
	// kinc_change_resolution(width, height, false);
}

void hl_kinc_system_set_keepscreenon(bool on) {
	kinc_set_keep_screen_on(on);
}

void hl_kinc_system_load_url(vbyte *url) {
	kinc_load_url((char *)url);
}

// const char* getGamepadId(int index);

vbyte *hl_kinc_get_gamepad_id(int index) {
	return NULL;
	// return (vbyte*)getGamepadId(index);
}

typedef void (*FN_KEY_DOWN)(int);
typedef void (*FN_KEY_UP)(int);
typedef void (*FN_KEY_PRESS)(unsigned int);

void hl_kinc_register_keyboard(vclosure *keyDown, vclosure *keyUp, vclosure *keyPress) {
	kinc_keyboard_set_key_down_callback(*((FN_KEY_DOWN *)(&keyDown->fun)));
	kinc_keyboard_set_key_up_callback(*((FN_KEY_UP *)(&keyUp->fun)));
	kinc_keyboard_set_key_press_callback(*((FN_KEY_PRESS *)(&keyPress->fun)));
}

typedef void (*FN_MOUSE_DOWN)(int, int, int, int);
typedef void (*FN_MOUSE_UP)(int, int, int, int);
typedef void (*FN_MOUSE_MOVE)(int, int, int, int, int);
typedef void (*FN_MOUSE_WHEEL)(int, int);

void hl_kinc_register_mouse(vclosure *mouseDown, vclosure *mouseUp, vclosure *mouseMove, vclosure *mouseWheel) {
	kinc_mouse_set_press_callback(*((FN_MOUSE_DOWN *)(&mouseDown->fun)));
	kinc_mouse_set_release_callback(*((FN_MOUSE_UP *)(&mouseUp->fun)));
	kinc_mouse_set_move_callback(*((FN_MOUSE_MOVE *)(&mouseMove->fun)));
	kinc_mouse_set_scroll_callback(*((FN_MOUSE_WHEEL *)(&mouseWheel->fun)));
}

typedef void (*FN_PEN_DOWN)(int, int, int, float);
typedef void (*FN_PEN_UP)(int, int, int, float);
typedef void (*FN_PEN_MOVE)(int, int, int, float);

void hl_kinc_register_pen(vclosure *penDown, vclosure *penUp, vclosure *penMove) {
	kinc_pen_set_press_callback(*((FN_PEN_DOWN *)(&penDown->fun)));
	kinc_pen_set_release_callback(*((FN_PEN_UP *)(&penUp->fun)));
	kinc_pen_set_move_callback(*((FN_PEN_MOVE *)(&penMove->fun)));
}

typedef void (*FN_GAMEPAD_AXIS)(int, int, float);
typedef void (*FN_GAMEPAD_BUTTON)(int, int, float);

void hl_kinc_register_gamepad(vclosure *gamepadAxis, vclosure *gamepadButton) {
	kinc_gamepad_set_axis_callback(*((FN_GAMEPAD_AXIS *)(&gamepadAxis->fun)));
	kinc_gamepad_set_button_callback(*((FN_GAMEPAD_BUTTON *)(&gamepadButton->fun)));
}

typedef void (*FN_TOUCH_START)(int, int, int);
typedef void (*FN_TOUCH_END)(int, int, int);
typedef void (*FN_TOUCH_MOVE)(int, int, int);

void hl_kinc_register_surface(vclosure *touchStart, vclosure *touchEnd, vclosure *touchMove) {
	kinc_surface_set_touch_start_callback(*((FN_TOUCH_START *)(&touchStart->fun)));
	kinc_surface_set_touch_end_callback(*((FN_TOUCH_END *)(&touchEnd->fun)));
	kinc_surface_set_move_callback(*((FN_TOUCH_MOVE *)(&touchMove->fun)));
}

typedef void (*FN_SENSOR_ACCELEROMETER)(float, float, float);
typedef void (*FN_SENSOR_GYROSCOPE)(float, float, float);

void hl_kinc_register_sensor(vclosure *accelerometerChanged, vclosure *gyroscopeChanged) {
	kinc_acceleration_set_callback(*((FN_SENSOR_ACCELEROMETER *)(&accelerometerChanged->fun)));
	kinc_rotation_set_callback(*((FN_SENSOR_GYROSCOPE *)(&gyroscopeChanged->fun)));
}

// typedef void(*FN_CB_ORIENTATION)(int);
typedef void (*FN_CB_FOREGROUND)(void);
typedef void (*FN_CB_RESUME)(void);
typedef void (*FN_CB_PAUSE)(void);
typedef void (*FN_CB_BACKGROUND)(void);
typedef void (*FN_CB_SHUTDOWN)(void);

void hl_kinc_register_callbacks(vclosure *foreground, vclosure *resume, vclosure *pause, vclosure *background, vclosure *shutdown) {
	// kinc_set_orientation_callback(orientation);
	kinc_set_foreground_callback(*((FN_CB_FOREGROUND *)(&foreground->fun)));
	kinc_set_resume_callback(*((FN_CB_RESUME *)(&resume->fun)));
	kinc_set_pause_callback(*((FN_CB_PAUSE *)(&pause->fun)));
	kinc_set_background_callback(*((FN_CB_BACKGROUND *)(&background->fun)));
	kinc_set_shutdown_callback(*((FN_CB_SHUTDOWN *)(&shutdown->fun)));
}

typedef void (*FN_CB_DROPFILES)(wchar_t *);

void hl_kinc_register_dropfiles(vclosure *dropFiles) {
	// todo: string convert
	// kinc_set_drop_files_callback(*((FN_CB_DROPFILES*)(&dropFiles->fun)));
}

typedef char *(*FN_CB_COPY)(void);
typedef char *(*FN_CB_CUT)(void);
typedef void (*FN_CB_PASTE)(char *);

void hl_kinc_register_copycutpaste(vclosure *copy, vclosure *cut, vclosure *paste) {
	kinc_set_copy_callback(*((FN_CB_COPY *)(&copy->fun)));
	kinc_set_cut_callback(*((FN_CB_CUT *)(&cut->fun)));
	kinc_set_paste_callback(*((FN_CB_PASTE *)(&paste->fun)));
}

const char *hl_kinc_video_format(void) {
	return kinc_video_formats()[0];
}
