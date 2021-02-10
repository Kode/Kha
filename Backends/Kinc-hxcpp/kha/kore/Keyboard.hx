package kha.kore;

@:headerCode('
#include <Kore/pch.h>
#include <Kore/System.h>
')

@:allow(kha.SystemImpl)
class Keyboard extends kha.input.Keyboard {
	private function new() {
		super();
	}

	@:functionCode('Kore::System::showKeyboard();')
	override public function show(): Void {

	}

	@:functionCode('Kore::System::hideKeyboard();')
	override public function hide(): Void {

	}
}
