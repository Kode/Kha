package kha.android;

import android.content.Context;
import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.egl.EGLConfig;
import android.opengl.GLSurfaceViewRenderer;
import android.view.KeyEvent;

class OpenGLES20Renderer implements GLSurfaceViewRenderer {
	var game : kha.Game;
	var painter : OpenGLPainter;
	
	public function new(context : Context) {
		kha.Loader.init(new Loader(context));
		game = new TPlayer(); //GameInfo.createGame();
		kha.Loader.getInstance().load();
		game.init();
	}

	public function onDrawFrame(glUnused : GL10) : Void {
		//synchronized (game) {
			game.update();
			painter.begin();
			game.render(painter);
			painter.end();
		//}
	}

	public function onSurfaceChanged(glUnused : GL10, width : Int, height : Int) {
		painter = new OpenGLPainter(width, height);
	}

	public function onSurfaceCreated(glUnused : GL10, config : EGLConfig) {

	}

	public function keyDown(keyCode : Int) : Bool {
		//synchronized (game) {
			switch (keyCode) {
			case KeyEvent.KEYCODE_DPAD_RIGHT:
				game.buttonDown(Button.RIGHT);
			case KeyEvent.KEYCODE_DPAD_LEFT:
				game.buttonDown(Button.LEFT);
			case KeyEvent.KEYCODE_DPAD_CENTER:
				game.buttonDown(Button.UP);
			case KeyEvent.KEYCODE_DPAD_DOWN:
				game.buttonDown(Button.DOWN);
			case 99:
				game.buttonDown(Button.BUTTON_1);
			case 100:
				game.buttonDown(Button.BUTTON_2);
			default:
				return false;	
			}
			return true;
		//}
	}

	public function keyUp(keyCode : Int) : Bool {
		//synchronized (game) {
			switch (keyCode) {
			case KeyEvent.KEYCODE_DPAD_RIGHT:
				game.buttonUp(Button.RIGHT);
			case KeyEvent.KEYCODE_DPAD_LEFT:
				game.buttonUp(Button.LEFT);
			case KeyEvent.KEYCODE_DPAD_CENTER:
				game.buttonUp(Button.UP);
			case KeyEvent.KEYCODE_DPAD_DOWN:
				game.buttonUp(Button.DOWN);
			case 99:
				game.buttonUp(Button.BUTTON_1);
			case 100:
				game.buttonUp(Button.BUTTON_2);
			default:
				return false;
			}
			return true;
		//}
	}
	
	public function mouseDown(x : Int, y : Int) : Bool {
	    //synchronized (game) {
	    	game.mouseDown(Std.int(painter.adjustXPosInv(x)), Std.int(painter.adjustYPosInv(y)));
	    //}
	    return true;
	}
	
	public function mouseUp(x : Int, y : Int) : Bool {
	    //synchronized (game) {
	    	game.mouseUp(Std.int(painter.adjustXPosInv(x)), Std.int(painter.adjustYPosInv(y)));
	    //}
	    return true;
	}
	
	public function mouseMove(x : Int, y : Int) : Bool {
	    //synchronized (game) {
	    	game.mouseMove(Std.int(painter.adjustXPosInv(x)), Std.int(painter.adjustYPosInv(y)));
	    //}
	    return true;
	}
}