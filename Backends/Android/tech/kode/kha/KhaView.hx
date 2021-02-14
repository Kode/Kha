package tech.kode.kha;

import android.content.Context;
import android.opengl.GLSurfaceView;
import android.view.inputmethod.InputMethodManager;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewOnTouchListener;
import java.lang.Runnable;

class OnTouchRunner implements Runnable {
	var renderer: KhaRenderer;
	var event: MotionEvent;
	var id: Int;
	var x: Single;
	var y: Single;
	var action: Int;

	public function new(renderer: KhaRenderer, id: Int, x: Single, y: Single, action: Int) {
		this.renderer = renderer;
		this.id = id;
		this.x = x;
		this.y = y;
		this.action = action;
	}

	public function run(): Void {
		renderer.touch(id, Math.round(x), Math.round(y), action);
	}
}

class OnKeyDownRunner implements Runnable {
	var renderer: KhaRenderer;
	var keyCode: Int;
	var char: String;

	public function new(renderer: KhaRenderer, keyCode: Int, char: String) {
		this.renderer = renderer;
		this.keyCode = keyCode;
		this.char = char;
	}

	public function run(): Void {
		renderer.key(keyCode, true, char);
	}
}

class OnKeyUpRunner implements Runnable {
	var renderer: KhaRenderer;
	var keyCode: Int;
	var char: String;

	public function new(renderer: KhaRenderer, keyCode: Int, char: String) {
		this.renderer = renderer;
		this.keyCode = keyCode;
		this.char = char;
	}

	public function run(): Void {
		renderer.key(keyCode, false, char);
	}
}

@:keep
class KhaView extends GLSurfaceView implements ViewOnTouchListener {
	var renderer: KhaRenderer;
	var inputManager: InputMethodManager;

	public function new(activity: KhaActivity) {
		super(activity);
		setFocusable(true);
		setFocusableInTouchMode(true);
		setPreserveEGLContextOnPause(true);
		setEGLContextClientVersion(2);
		setEGLConfigChooser(8, 8, 8, 8, 16, 8);
		setRenderer(renderer = new KhaRenderer(activity.getApplicationContext(), this));
		setOnTouchListener(this);
		initInputManager(activity);
		setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_STABLE | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_FULLSCREEN | View.SYSTEM_UI_FLAG_IMMERSIVE);
	}

	@:functionCode('inputManager = (android.view.inputmethod.InputMethodManager)activity.getSystemService(android.content.Context.INPUT_METHOD_SERVICE);')
	function initInputManager(activity: KhaActivity): Void {}

	// unused
	// @:overload public function new(context: Context) {
	//	super(context);
	// }

	public function showKeyboard(): Void {
		inputManager.toggleSoftInputFromWindow(getApplicationWindowToken(), InputMethodManager.SHOW_IMPLICIT, 0);
	}

	public function hideKeyboard(): Void {
		inputManager.hideSoftInputFromWindow(getApplicationWindowToken(), InputMethodManager.HIDE_NOT_ALWAYS);
	}

	public function onTouch(view: View, event: MotionEvent): Bool {
		var index = event.getActionIndex();
		var maskedAction = event.getActionMasked();
		var ACTION_DOWN = 0;
		var ACTION_MOVE = 1;
		var ACTION_UP = 2;
		var action = -1;
		action = (maskedAction == MotionEvent.ACTION_DOWN || maskedAction == MotionEvent.ACTION_POINTER_DOWN) ? ACTION_DOWN : -1;
		action = (action == -1 && maskedAction == MotionEvent.ACTION_MOVE) ? ACTION_MOVE : action;
		action = (action == -1
			&& (maskedAction == MotionEvent.ACTION_UP
				|| maskedAction == MotionEvent.ACTION_POINTER_UP
				|| maskedAction == MotionEvent.ACTION_CANCEL)) ? ACTION_UP : action;

		switch action {
			case 1: // ACTION_MOVE
				var pointerCount = event.getPointerCount();
				for (i in 0...pointerCount) {
					queueEvent(new OnTouchRunner(renderer, event.getPointerId(i), event.getX(i), event.getY(i), action));
				}

			default:
				queueEvent(new OnTouchRunner(renderer, event.getPointerId(index), event.getX(index), event.getY(index), action));
		}
		return true;
	}

	public function onKeyDown(keyCode: Int, event: KeyEvent): Bool {
		if (event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_DOWN
			|| event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_MUTE
			|| event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP) {
			return false;
		}

		/*if(event.getKeyCode() == KeyEvent.KEYCODE_BACK) {
			return true;
		}*/

		this.queueEvent(new OnKeyDownRunner(renderer, keyCode, String.fromCharCode(event.getUnicodeChar())));
		return true;
	}

	public function onKeyUp(keyCode: Int, event: KeyEvent): Bool {
		if (event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_DOWN
			|| event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_MUTE
			|| event.getKeyCode() == KeyEvent.KEYCODE_VOLUME_UP) {
			return false;
		}
		this.queueEvent(new OnKeyUpRunner(renderer, keyCode, '')); // doesn't make sense to send text
		return true;
	}

	// public function accelerometer(x: Single, y: Single, z: Single): Void {
	//	queueEvent(new Runnable() {
	//		@Override
	//		public void run() {
	//			renderer.accelerometer(x, y, z);
	//		}
	//	});
	// }
	// public function gyro(x: Single, y: Single, z: Single): Void {
	//	queueEvent(new Runnable() {
	//		@Override
	//		public void run() {
	//			renderer.gyro(x, y, z);
	//		}
	//	});
	// }
}
