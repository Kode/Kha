package kha.kore;

@:headerCode("
#include <kinc/input/keyboard.h>
")
@:allow(kha.SystemImpl)
class Keyboard extends kha.input.Keyboard {
	function new() {
		super();
	}

	@:functionCode("kinc_keyboard_show();")
	override public function show(): Void {}

	@:functionCode("kinc_keyboard_hide();")
	override public function hide(): Void {}
}
