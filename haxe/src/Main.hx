package ;

import com.ktxsoftware.kje.Game;
import com.ktxsoftware.kje.Key;
import com.ktxsoftware.kje.Loader;
import com.ktxsoftware.sml.SuperMarioLand;

#if flash

import com.ktxsoftware.kje.backend.flash.Painter;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.Lib;
import flash.display.MovieClip;
import flash.display.Sprite;

class Main extends MovieClip {
	var game : Game;
	var painter : Painter;
	
	public function new() {
		super();
		Loader.init(new com.ktxsoftware.kje.backend.flash.Loader(this));
		game = new SuperMarioLand();
		Loader.getInstance().load();
	}
	
	public function start() {
		game.init();
		painter = new Painter();
		Lib.current.addChild(this);
		stage.frameRate = 60;
		Lib.current.addEventListener(Event.ENTER_FRAME, draw);
		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
	}

	function draw(e : Event) {
		//game.update();
		game.update();
		painter.setGraphics(graphics);
		painter.begin();
		game.render(painter);
		painter.end();
	}
	
	function keyDownHandler(event : KeyboardEvent) {
		switch (event.keyCode) {
		case 38:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.UP, true));
		case 40:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.DOWN, true));
		case 37:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.LEFT, true));
		case 39:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.RIGHT, true));
		}
	}

	function keyUpHandler(event : KeyboardEvent) {
		switch (event.keyCode) {
		case 38:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.UP, false));
		case 40:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.DOWN, false));
		case 37:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.LEFT, false));
		case 39:
			game.key(new com.ktxsoftware.kje.KeyEvent(Key.RIGHT, false));
		}
	}
	
	static function main() {
		new Main();
	}
}

#end

#if js

import js.Lib;

class Main {
	static var game : Game;
	
	static function main() {
		Loader.init(new com.ktxsoftware.kje.backend.js.Loader());
		game = new SuperMarioLand();
		Loader.getInstance().load();
		
		var window : Dynamic = Lib.window;
		window.webkitRequestAnimationFrame(animate);
	}
	
	static function animate(timestamp) {
		var window : Dynamic = Lib.window;
		window.webkitRequestAnimationFrame(animate);
		var canvas : Dynamic = Lib.document.getElementById("haxvas");
		if (canvas.getContext){
			canvas = canvas.getContext('2d');
			canvas.clearRect(0, 0, 640, 560);
			canvas.fillStyle = "rgb(200,0,0)";
			canvas.fillRect(10, 10, 55, 55 );
		}
	}
}

/*class Main {
	static function main() {
		new SuperMarioLand();
	}
}*/
#end