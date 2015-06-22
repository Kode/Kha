package kha.android;

import java.lang.Thread;
import android.view.SurfaceHolder;
import android.content.Context;
import android.view.KeyEvent;
import android.graphics.Canvas;

class DeprecatedGameThread extends Thread {
	var running : Bool = false;
	var surface : SurfaceHolder;
	var context : Context;
	var game : kha.Game;
	var width : Int;
	var height : Int;
	var p : Painter;
	
	public function new(surface : SurfaceHolder, context : Context, width : Int, height : Int) {
		//super();
		this.surface = surface;
		this.context = context;
		this.width = width;
		this.height = height;
	}

	override public function run(): Void {
		kha.Loader.init(new Loader(context));
		game = new StoryPublish();//GameInfo.createGame();
		Configuration.setScreen(new EmptyScreen(game.getWidth(), game.getHeight(), new Color(0, 0, 0)));
		kha.Loader.the().loadProject(loadFinished);
	}
	
	public function loadFinished(): Void {
		if (kha.Loader.the().getWidth() > 0 && kha.Loader.the().getHeight() > 0) {
			game.setWidth(kha.Loader.the().getWidth());
			game.setHeight(kha.Loader.the().getHeight());
		}
		kha.Loader.the().initProject();
		Configuration.setScreen(game);
		Configuration.screen().setInstance();
		game.loadFinished();
		
		while (running) {
			var c :Canvas = null;
			//try {
				c = surface.lockCanvas(null);
				p = new Painter(c, width, height);
				//synchronized (surface) {
					game.update();
					game.render(p);
				//}
			//}
			//finally {
				if (c != null) surface.unlockCanvasAndPost(c);
			//}
		}
	}

	public function setRunning(b : Bool) : Void {
		running = b;
	}

	public function setSurfaceSize(width : Int, height : Int) : Void {
		//synchronized (surface) {
			this.width = width;
			this.height = height;
		//}
	}

	public function keyDown(keyCode : Int) : Bool {
		//synchronized (surface) {
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
		//synchronized (surface) {
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
		//synchronized (surface) {
			game.mouseDown(Std.int(p.adjustXPosInv(x)), Std.int(p.adjustYPosInv(y)));
		//}
		return true;
	}
	
	public function mouseUp(x : Int, y : Int) : Bool {
		//synchronized (surface) {
			game.mouseUp(Std.int(p.adjustXPosInv(x)), Std.int(p.adjustYPosInv(y)));
		//}
		return true;
	}
	
	public function mouseMove(x : Int, y : Int) : Bool {
		//synchronized (surface) {
			game.mouseMove(Std.int(p.adjustXPosInv(x)), Std.int(p.adjustYPosInv(y)));
		//}
	    return true;
	}
}