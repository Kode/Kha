package com.ktxsoftware.kha;

import android.content.Context;
import android.opengl.GLES20;
import android.opengl.GLSurfaceViewRenderer;
import android.text.method.MetaKeyKeyListener;
import android.view.KeyCharacterMap;
import android.view.KeyEvent;
import java.lang.Runnable;
import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;
import kha.SystemImpl;

class KeyboardShowRunner implements Runnable {
	private var view: KhaView;
	
	public function new(view: KhaView) {
		this.view = view;
	}

	public function run(): Void {
		view.showKeyboard();
	}
}

class KeyboardHideRunner implements Runnable {
	private var view: KhaView;
	
	public function new(view: KhaView) {
		this.view = view;
	}

	public function run(): Void {
		view.hideKeyboard();
	}
}

class KhaRenderer implements GLSurfaceViewRenderer {
	private var context: Context;
	private var keyboardShown: Bool = false;
	private var keyMap: KeyCharacterMap;
	private var view: KhaView;
	
	public function new(context: Context, view: KhaView) {
		this.context = context;
		this.view = view;
		keyMap = KeyCharacterMap.load(-1);
	} 
	
	public function onSurfaceCreated(gl: GL10, config: EGLConfig): Void {
		SystemImpl.preinit(640, 480);
	}
	
	public function onDrawFrame(gl: GL10): Void {
		//GLES20.glClearColor(1.0, 1.0, 0.0, 1.0);
		//GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);
		
		SystemImpl.step();
		
		if (SystemImpl.keyboardShown()) {
			if (!keyboardShown) {
				keyboardShown = true;
				KhaActivity.the().runOnUiThread(new KeyboardShowRunner(view));
			}
		}
		else {
			if (keyboardShown) {
				keyboardShown = false;
				KhaActivity.the().runOnUiThread(new KeyboardHideRunner(view));
			}
		}
	}

	public function onSurfaceChanged(gl: GL10, width: Int, height: Int): Void {
		SystemImpl.setWidthHeight(width, height); // , context.getResources().getAssets(), context.getApplicationInfo().sourceDir, context.getFilesDir().toString());
	}
	
	public function key(keyCode: Int, down: Bool): Void {
		switch (keyCode) {
		case 59: // shift
			if (down) SystemImpl.keyDown(0x00000120);
			else SystemImpl.keyUp(0x00000120);
		case 66: // return
			if (down) SystemImpl.keyDown(0x00000104);
			else SystemImpl.keyUp(0x00000104);
		case 67: // backspace
			if (down) SystemImpl.keyDown(0x00000103);
			else SystemImpl.keyUp(0x00000103);
		case 0x00000004: //KeyEvent.KEYCODE_BACK
			if(down) SystemImpl.keyDown(KeyEvent.KEYCODE_BACK);
			else SystemImpl.keyUp(KeyEvent.KEYCODE_BACK);
		default:
			var code = keyMap.get(keyCode, MetaKeyKeyListener.META_SHIFT_ON);
			if (down) SystemImpl.keyDown(code);
			else SystemImpl.keyUp(code);
		}
	}
	
	public function touch(index: Int, x: Int, y: Int, action: Int): Void {
		SystemImpl.touch(index, x, y, action);
	}
	
	//public function accelerometer(x: Single, y: Single, z: Single): Void {
	//	KoreLib.accelerometerChanged(x, y, z);
	//}
	
	//public function gyro(x: Single, y: Single, z: Single): Void {
	//	KoreLib.gyroChanged(x, y, z);
	//}
}
