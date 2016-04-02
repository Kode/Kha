package kha.android;

@:allow(kha.SystemImpl)
class Keyboard extends kha.input.Keyboard {
	override public function show() {
		SystemImpl.showKeyboard = true;
	}

	override public function hide() {
		SystemImpl.showKeyboard = false;
	}
}
