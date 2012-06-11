package kha.android;

import android.view.SurfaceView;
import android.view.SurfaceHolder;
import android.content.Context;
import android.view.MotionEvent;
import android.view.KeyEvent;
import java.lang.InterruptedException;

@:classContents('
	class Callback implements android.view.SurfaceHolder.Callback {
		private GameView view;
		
		public Callback(GameView view) {
			this.view = view;
		}
		
		@Override
		public void surfaceChanged(android.view.SurfaceHolder holder, int format, int width, int height) {
			view.surfaceChanged(holder, format, width, height);
		}

		@Override
		public void surfaceCreated(android.view.SurfaceHolder holder) {
			view.surfaceCreated(holder);
		}

		@Override
		public void surfaceDestroyed(android.view.SurfaceHolder holder) {
			view.surfaceDestroyed(holder);
		}
	}
')
class GameView extends SurfaceView {
	var thread : GameThread;
	//private int lastTouch;

	public function new(context : Context) {
		super(context);
		var holder : SurfaceHolder = getHolder();
		addCallback(holder);
		thread = new GameThread(holder, context, getWidth(), getHeight());
		setFocusable(true);
	}
	
	@:functionBody('
		holder.addCallback(new Callback(this));
	')
	function addCallback(holder : SurfaceHolder) {
		
	}

	public function onTouchEvent(event : MotionEvent) : Bool {
		switch (event.getAction()) {
		case MotionEvent.ACTION_DOWN:
			thread.mouseDown(Std.int(event.getX()), Std.int(event.getY()));
		case MotionEvent.ACTION_MOVE:
			thread.mouseMove(Std.int(event.getX()), Std.int(event.getY()));
		case MotionEvent.ACTION_UP:
			thread.mouseUp(Std.int(event.getX()), Std.int(event.getY()));
		}
		return true;
	}

	/*override*/ public function onKeyDown(keyCode : Int, msg : KeyEvent) : Bool {
		if (keyCode == KeyEvent.KEYCODE_BACK && msg.isAltPressed()) return true; //Circle button on Xperia Play
		return thread.keyDown(keyCode);
	}

	/*override*/ public function onKeyUp(keyCode : Int, msg : KeyEvent) : Bool {
		return thread.keyUp(keyCode);
	}

	/*override*/ public function onWindowFocusChanged(hasWindowFocus : Bool) {

	}

	public function surfaceChanged(holder : SurfaceHolder, format : Int, width : Int, height : Int) {
		thread.setSurfaceSize(width, height);
	}

	public function surfaceCreated(holder : SurfaceHolder) {
		thread.setRunning(true);
		thread.start();
	}
	
	@:functionBody('
		boolean retry = true;
		thread.setRunning(false);
		while (retry) {
			try {
				thread.join();
				retry = false;
			}
			catch (InterruptedException e) {

			}
		}
	')
	function joinThread() : Void {
		
	}

	public function surfaceDestroyed(holder : SurfaceHolder) {
		joinThread();
	}
}