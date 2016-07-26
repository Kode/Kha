package kha.input;

class MouseImpl extends kha.input.Mouse {
	public function new() {
		super();
	}

	override public function hideSystemCursor(): Void {
		SystemImpl.khanvas.style.cursor = "none";
	}

	override public function showSystemCursor(): Void {
		SystemImpl.khanvas.style.cursor = "default";
	}
}
