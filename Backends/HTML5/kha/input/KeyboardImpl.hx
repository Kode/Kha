package kha.input;

import js.Browser.document;
import js.html.InputElement;
import js.html.InputEvent;
import js.html.KeyboardEvent;

using StringTools;

class KeyboardImpl extends Keyboard {
	static var virtualKeyboardId = "kha-virtual-keyboard";
	public static var input: InputElement;

	public function new() {
		super();
	}

	override function show(): Void {
		input = cast document.getElementById(virtualKeyboardId);
		input ??= createKeyboardInputElement();
		document.body.appendChild(input);
		input.focus();
	}

	static function createKeyboardInputElement(): InputElement {
		final input = document.createInputElement();
		input.id = virtualKeyboardId;
		input.style.position = "fixed";
		input.style.left = "0px";
		input.style.top = "0px";
		input.style.opacity = "0.0";
		input.style.pointerEvents = "none";
		input.type = "text";
		input.autocomplete = "off";
		input.spellcheck = false;
		input.setAttribute("autocorrect", "off");
		input.setAttribute("autocapitalize", "off");

		input.onkeydown = (e: KeyboardEvent) -> {
			if (e.repeat) {
				e.preventDefault();
				return;
			}
			// virtual keyboards do not report pressed chars in most cases
			// so we only redirect non-printable keys to canvas there
			if (e.key == null || e.key.length == 1)
				return;
			final keyEvent = copyKeyboardEventFrom(e);
			SystemImpl.khanvas.dispatchEvent(keyEvent);
		}
		input.onkeyup = (e: KeyboardEvent) -> {
			if (e.key == null || e.key.length == 1)
				return;
			final keyEvent = copyKeyboardEventFrom(e);
			SystemImpl.khanvas.dispatchEvent(keyEvent);
		}
		input.oninput = (e: InputEvent) -> {
			// IME-composition, key is not final yet
			if (e.isComposing)
				return;
			final str: String = (e : Dynamic).data ?? return;
			final kb = Keyboard.get() ?? return;
			for (code in str) {
				final char = String.fromCharCode(code);
				kb.sendPressEvent(char);
			}
			input.value = "";
		}
		return input;
	}

	static function copyKeyboardEventFrom(e: KeyboardEvent): KeyboardEvent {
		return new KeyboardEvent(e.type, {
			key: e.key,
			code: e.code,
			keyCode: e.keyCode,
			location: e.location,
			ctrlKey: e.ctrlKey,
			shiftKey: e.shiftKey,
			altKey: e.altKey,
			metaKey: e.metaKey,
			bubbles: true,
			cancelable: true
		});
	}

	override function hide(): Void {
		SystemImpl.khanvas.focus();
		input?.remove();
	}
}
